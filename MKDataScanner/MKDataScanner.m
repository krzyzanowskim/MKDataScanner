//
//  MKDataScanner.m
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 09/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#import "MKDataScanner.h"
#import "MKDataProvider.h"
#import "MKDataScannerStreamFileProvider.h"
#import "MKDataScannerDispatchIOFileProvider.h"
#import "MKDataScannerDataProvider.h"

@interface MKDataScanner ()
@property (strong) id <MKDataProvider> provider;
@end

@implementation MKDataScanner

- (instancetype) initWithFileURL:(NSURL *)fileURL provider:(MKDataFileHandlerType)providerType;
{
    NSParameterAssert(fileURL.fileURL);
    if (!fileURL) {
        return nil;
    }
    
    if (self = [self init]) {
        switch (providerType) {
            case MKDataFileDispatchIOProvider:
                _provider = [[MKDataScannerDispatchIOFileProvider alloc] initWithFileURL:fileURL];
                break;
            case MKDataFileStreamProvider:
                _provider = [[MKDataScannerStreamFileProvider alloc] initWithFileURL:fileURL];
                break;
            default:
                _provider = [[MKDataScannerDispatchIOFileProvider alloc] initWithFileURL:fileURL];
                break;
        }
    }
    return self;
}

- (instancetype) initWithFileURL:(NSURL *)fileURL
{
    if (self = [self initWithFileURL:fileURL provider:MKDataFileDefaultProvider]) {
        
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data
{
    NSParameterAssert(data);
    if (!data) {
        return nil;
    }
    
    if (self = [self init]) {
        _provider = [[MKDataScannerDataProvider alloc] initWithData:data];
    }
    return self;
}

- (NSUInteger)scanLocation
{
    return [self.provider offset];
}

- (void)setScanLocation:(NSUInteger)scanLocation
{
    [self.provider setOffset:scanLocation];
}

- (BOOL)isAtEnd
{
    return [self.provider isAtEnd];
}

- (BOOL)scanUpToBytes:(const void *)bytes length:(int)length intoData:(NSData * __autoreleasing *)dataValue
{
    NSData *data = [NSData dataWithBytes:bytes length:length];
    return [self scanUpToData:data intoData:dataValue];
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData * __autoreleasing *)dataValue
{
    NSParameterAssert(stopData);

    NSMutableData *scannedData = [NSMutableData data];
    NSData *currentBlock = nil;
    NSData *prevBlock = nil;
    // scan block by block
    while (![self.provider isAtEnd] && (currentBlock = [self.provider dataForRange:(NSRange){self.scanLocation,stopData.length}])) {
        NSMutableData *searchBlock = [NSMutableData data];
        if (prevBlock) {
            [searchBlock appendData:prevBlock];
        }
        [searchBlock appendData:currentBlock];

        if (dataValue) {
            [scannedData appendData:currentBlock];
        }
        // scan prev+current block
        NSRange range = [searchBlock rangeOfData:stopData options:0 range:(NSRange){0,searchBlock.length}];
        if (range.location != NSNotFound) {
            [self setScanLocation:[self scanLocation] - stopData.length];
            if (dataValue) {
                // this will cause reopen stream which is not the best because of performance impact (check performance impact)
                // check is better is read byte by byte, by blocks with resets
                *dataValue = [scannedData subdataWithRange:(NSRange){0,scannedData.length - stopData.length}];
            }
            return YES;
        }
        prevBlock = currentBlock;
    }
    
    return NO;
}

- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue
{
    NSData *scannedBlock = nil;
    if (![self.provider isAtEnd] && (scannedBlock = [self.provider dataForRange:(NSRange){self.scanLocation,data.length}])) {
        if ([scannedBlock isEqualToData:data]) {
            if (dataValue) {
                *dataValue = scannedBlock;
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)scanInteger:(NSInteger *)value
{
    NSData *scannedBlock = nil;
    if (![self.provider isAtEnd] && (scannedBlock = [self.provider dataForRange:(NSRange){self.scanLocation,sizeof(NSInteger)}])) {
        if (scannedBlock.length != sizeof(NSInteger)) {
            if (value) {
                *value = scannedBlock.length > sizeof(NSInteger) ? INT_MAX : INT_MIN;
            }
            return NO;
        }
        NSInteger scannedValue;
        [scannedBlock getBytes:&scannedValue length:scannedBlock.length];
        if (value) {
            *value = scannedValue;
        }
        return YES;
    }
    return NO;
}

+ (instancetype) scannerWithFileURL:(NSURL *)fileURL
{
    return [[MKDataScanner alloc] initWithFileURL:fileURL];
}

+ (instancetype) scannerWithData:(NSData *)data
{
    return [[MKDataScanner alloc] initWithData:data];
}

@end
