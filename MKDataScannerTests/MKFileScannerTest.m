//
//  MKFileScannerTest.m
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 10/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MKDataScanner.h"

@interface MKFileScannerTest : XCTestCase
@end

@implementation MKFileScannerTest

- (id)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation]) {
    }
    return self;
}

- (NSString *)tmpFilePath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.file.data"];
}
   

- (void)setUp {
    [super setUp];
    
    uint8_t bytes[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
    [[NSData dataWithBytes:bytes length:sizeof(bytes)] writeToFile:[self tmpFilePath] atomically:YES];
}

- (void)tearDown {
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:[self tmpFilePath] error:nil];
}

- (void) testScanUpTo1
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];

    uint8_t bytes[] = {0x03, 0x04, 0x05, 0x06};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:nil]);
}

- (void) testScanUpTo2
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];

    NSData *scanned = nil;
    uint8_t bytes1[] = {0x01};
    uint8_t expectedBytes1[] = {0x00};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:&scanned]);
    XCTAssert([[NSData dataWithBytes:expectedBytes1 length:sizeof(expectedBytes1)] isEqualToData:scanned], @"Invalid scanned value");

    uint8_t bytes2[] = {0x04};
    uint8_t expectedBytes2[] = {0x01, 0x02, 0x03};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes2 length:sizeof(bytes2)] intoData:&scanned]);
    XCTAssert([[NSData dataWithBytes:expectedBytes2 length:sizeof(expectedBytes2)] isEqualToData:scanned], @"Invalid scanned value");
    NSLog(@"scanned %@",scanned);
}

- (void) testScanUpTo3
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    
    uint8_t bytes1[] = {0x05};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:nil]);
    uint8_t bytes2[] = {0x06};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes2 length:sizeof(bytes2)] intoData:nil]);
}

- (void) testScanUpTo4
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    uint8_t bytes1[] = {0x06};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:nil]);
    uint8_t bytes2[] = {0x05};
    XCTAssertFalse([dataScanner scanUpToData:[NSData dataWithBytes:bytes2 length:sizeof(bytes2)] intoData:nil]);
}

- (void) testSetScanLocation
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    uint8_t bytes1[] = {0x06};
    [dataScanner setScanLocation:7];
    XCTAssertFalse([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:nil]);
    [dataScanner setScanLocation:1];
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:nil]);
}

- (void) testScanUpToNotExists
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    
    uint8_t bytes[] = {0x08, 0x09};
    XCTAssertFalse([dataScanner scanUpToData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:nil]);
}

- (void) testScanData1
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    
    NSData *scanned = nil;
    uint8_t bytes[] = {0x00, 0x01};
    XCTAssertTrue([dataScanner scanData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:&scanned]);
    [dataScanner setScanLocation:1];
    XCTAssertFalse([dataScanner scanData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:&scanned]);
}

@end
