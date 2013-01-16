//
//  NSStringXtras.h
//  Timeous
//
//  Created by Kevin Wojniak on 9/9/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (TSFormats)

+ (NSString *)stringByFormattingSeconds:(unsigned long long)seconds;
+ (NSString *)stringByFormattingSeconds2:(unsigned long long)seconds;
+ (NSString *)stringByFormattingSeconds3:(unsigned long long)seconds;

+ (NSString *)stringByFormattingSeconds:(unsigned long long)seconds atRate:(float)rate withTax:(float)tax;

@end
