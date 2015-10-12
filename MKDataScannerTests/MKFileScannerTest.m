//
//  MKFileScannerTest.m
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 10/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

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

- (void) testScanUpToBytes
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    UInt8 searchBytes[] = {0x01};
    XCTAssertTrue([dataScanner scanUpToBytes:&searchBytes length:sizeof(searchBytes) intoData:nil]);
    XCTAssertEqual(dataScanner.scanLocation, 1);
}

- (void) testScanUpToBytes2
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    UInt8 searchBytes[] = {0x03, 0x04, 0x05, 0x06};
    XCTAssertTrue([dataScanner scanUpToBytes:&searchBytes length:sizeof(searchBytes) intoData:nil]);
    XCTAssertEqual(dataScanner.scanLocation, 3);
}

- (void) testScanUpTo1
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    uint8_t searchBytes[] = {0x04, 0x05};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:searchBytes length:sizeof(searchBytes)] intoData:nil]);
    XCTAssertEqual(dataScanner.scanLocation, 4);
}

- (void) testScanUpTo2
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];

    NSData *scanned = nil;
    uint8_t bytes1[] = {0x01};
    uint8_t expectedBytes1[] = {0x00};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)] intoData:&scanned]);
    XCTAssert([[NSData dataWithBytes:expectedBytes1 length:sizeof(expectedBytes1)] isEqualToData:scanned], @"Invalid scanned value");
    XCTAssertEqual(dataScanner.scanLocation, 1);

    uint8_t bytes2[] = {0x04};
    uint8_t expectedBytes2[] = {0x01, 0x02, 0x03};
    XCTAssertTrue([dataScanner scanUpToData:[NSData dataWithBytes:bytes2 length:sizeof(bytes2)] intoData:&scanned]);
    XCTAssert([[NSData dataWithBytes:expectedBytes2 length:sizeof(expectedBytes2)] isEqualToData:scanned], @"Invalid scanned value");
    XCTAssertEqual(dataScanner.scanLocation, 4);
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
    NSUInteger beforeLocation = dataScanner.scanLocation;
    XCTAssertTrue([dataScanner scanData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:&scanned]);
    XCTAssertEqual(dataScanner.scanLocation, beforeLocation + sizeof(bytes));

    [dataScanner setScanLocation:1];
    XCTAssertFalse([dataScanner scanData:[NSData dataWithBytes:bytes length:sizeof(bytes)] intoData:&scanned]);
}

- (void) testScanInteger
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    [dataScanner setScanLocation:0];
    NSInteger scannedInteger;
    XCTAssertTrue([dataScanner scanInteger:&scannedInteger]);
    XCTAssertEqual(scannedInteger, 506097522914230528);
}

- (void) testScanByte
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    [dataScanner setScanLocation:3];
    Byte scannedByte;
    XCTAssertTrue([dataScanner scanByte:&scannedByte]);
    XCTAssertEqual(scannedByte, 0x03);
}

- (void) testScanBytes
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    [dataScanner setScanLocation:3];
    Byte scannedBytes[6];
    XCTAssertTrue([dataScanner scanBytes:scannedBytes length:6]);
    XCTAssertFalse([dataScanner scanBytes:scannedBytes length:9]);
    XCTAssertEqual(scannedBytes[0], 0x03);
}

- (void) testscanUpToBytesFromSet
{
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithFileURL:[NSURL fileURLWithPath:[self tmpFilePath]]];
    NSData *scanned;
    [dataScanner scanUpToBytesFromSet:[NSSet setWithArray:@[@(0x02),@(0x02),@(0x03),@(0x04)]] intoData:&scanned];
    XCTAssertEqual(dataScanner.scanLocation, 2);
    [dataScanner scanUpToBytesFromSet:[NSSet setWithArray:@[@(0x08),@(0x07)]] intoData:&scanned];
    XCTAssertEqual(dataScanner.scanLocation, 7);
}

- (void) testScanFloat32FromDataSet
{
    // write a well known float32 to NSData
    Float32 wellKnownValue = 12345678.0f;
    Float32 wellKnownValue2 = 98765432.0;
    NSUInteger float32Size = sizeof(Float32);
    
    NSMutableData * prefabFloatData = [NSMutableData dataWithCapacity:0];
    [prefabFloatData appendBytes:&wellKnownValue length:float32Size];
    [prefabFloatData appendBytes:&wellKnownValue2 length:float32Size];
    
    // initialise the scanner with the Data
    MKDataScanner *dataScanner = [[MKDataScanner alloc] initWithData:prefabFloatData];

    Float32 checkWellKnownFloatValue = 0.0f, checkWellKnownFloatValue2 = 0.0f;
    // retrieve the first one
    [dataScanner scanHexFloat:&checkWellKnownFloatValue];
    XCTAssertEqual(checkWellKnownFloatValue, wellKnownValue);
    // retrieve the first one
    [dataScanner scanHexFloat:&checkWellKnownFloatValue2];
    XCTAssertEqual(checkWellKnownFloatValue2, wellKnownValue2);
}

@end
