//
//  MKDataScanner.m
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 09/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#import "MKDataScanner.h"
#import "MKDataProvider.h"
#import "MKDataScannerFileProvider.h"

@interface MKDataScanner ()
@property (strong) id <MKDataProvider> provider;
@end

@implementation MKDataScanner

- (instancetype) initWithFileURL:(NSURL *)fileURL
{
    NSParameterAssert(fileURL.fileURL);
    if (self = [self init]) {
        _provider = [[MKDataScannerFileProvider alloc] initWithFileURL:fileURL];
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

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue
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
            if (dataValue) {
                [self setScanLocation:[self scanLocation] - stopData.length]; //this will cause reopen stream which is not the best because of performance impact (check performance impact)
                *dataValue = [scannedData subdataWithRange:(NSRange){0,scannedData.length - stopData.length}];
            }
            return YES;
        }
        prevBlock = currentBlock;
    }
    
    return NO;
}

- (BOOL)scanData:(NSData *)stopData intoData:(NSData **)dataValue
{
    NSData *currentBlock = nil;
    
    while (![self.provider isAtEnd] && (currentBlock = [self.provider dataForRange:(NSRange){self.scanLocation,stopData.length}])) {
    }
    
    return NO;
}


+ (instancetype) scannerWithFileURL:(NSURL *)fileURL
{
    return [[MKDataScanner alloc] initWithFileURL:fileURL];
}

@end
