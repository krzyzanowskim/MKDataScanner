//
//  MKDataScannerFileProvider.m
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 09/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#import "MKDataScannerFileProvider.h"

@interface MKDataScannerFileProvider ()
@property (copy) NSURL *fileURL;
@property (strong) NSInputStream *inputStream;
@property (assign) BOOL endReached;
@end

@implementation MKDataScannerFileProvider

- (instancetype) initWithFileURL:(NSURL *)fileURL
{
    NSParameterAssert(fileURL.fileURL);
    if (self = [self init]) {
        _fileURL = fileURL;
        [self resetStream];
    }
    return self;
}

- (void)dealloc
{
    [_inputStream close];
}

- (void) resetStream
{
    [self.inputStream close];
    self.inputStream = [NSInputStream inputStreamWithURL:self.fileURL];
    [self.inputStream open];
}

#pragma mark - MKDataProvider

- (NSData *)dataForRange:(NSRange)range
{
    uint8_t buffer[range.length];
    NSInteger result = [self.inputStream read:buffer maxLength:range.length];
    if (result < 0) {
        return nil;
    } else if (result == 0) {
        self.endReached = YES;
    } else if (result > 0) {
        NSData *readData = [NSData dataWithBytes:buffer length:result];
        return readData;
    }
    
    return nil;
}

- (NSInteger)offset
{
    NSNumber *value = [self.inputStream propertyForKey:NSStreamFileCurrentOffsetKey];
    NSAssert([value isKindOfClass:[NSNumber class]], @"Invalid class");
    return value.integerValue;
}

- (void)setOffset:(NSInteger)offset
{
    NSParameterAssert(offset >= 0);

    if (offset == [self offset]) {
        return;
    }
    
    if (offset < [self offset]) {
        [self resetStream];
    }

    BOOL ret = [self.inputStream setProperty:@(offset) forKey:NSStreamFileCurrentOffsetKey];
    NSAssert(ret, @"Can't set offset");
    if (ret) {
        self.endReached = NO;
    }
}

- (BOOL)isAtEnd
{
    return self.endReached;
}

@end
