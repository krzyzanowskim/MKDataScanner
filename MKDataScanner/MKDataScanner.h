//
//  MKDataScanner.h
//  MKDataScanner
//
//  Created by Marcin Krzyzanowski on 09/01/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDataScanner : NSObject
@property NSUInteger scanLocation;
@property (getter=isAtEnd, readonly) BOOL atEnd;

- (instancetype) initWithFileURL:(NSURL *)fileURL;
- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue;
- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue;
- (BOOL)scanInteger:(NSInteger *)value;
@end
