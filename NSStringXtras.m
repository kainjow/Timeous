//
//  NSStringXtras.m
//  Timeous
//
//  Created by Kevin Wojniak on 9/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSStringXtras.h"

@implementation NSString (TSFormats)

+ (NSString *)stringByFormattingSeconds:(unsigned long long)secondsValue
{
	int second = 1;
	int minute = second * 60;
	int hour = minute * 60;
	//int day = hour * 24;
	
	NSMutableString *output = [NSMutableString string];
	unsigned long long leftover = secondsValue;
	BOOL useIt = NO;
	
	/*int days = (leftover / day);
	if (days > 0)
	{
		[output appendFormat:@"%d day%@ ", days, (days == 1 ? @"" : @"s")];
		leftover = (leftover % day);
		useIt = YES;
	}*/
	
	int hours = (leftover / hour);
	if (hours > 0 || useIt)
	{
		[output appendFormat:@"%d hour%@ ", hours, (hours == 1 ? @"" : @"s")];
		leftover = (leftover % hour);
		useIt = YES;
	}
	
	int minutes = (leftover / minute);
	if (minutes > 0 || useIt)
	{
		[output appendFormat:@"%d minute%@ ", minutes, (minutes == 1 ? @"" : @"s")];
		leftover = (leftover % minute);
		useIt = YES;
	}
	
	int seconds = (leftover / second);
	if (seconds >= 0 || useIt)
	{
		[output appendFormat:@"%d second%@ ", seconds, (seconds == 1 ? @"" : @"s")];
		leftover = (leftover % second);
		useIt = YES;
	}
	
	return [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)stringByFormattingSeconds2:(unsigned long long)secondsValue
{
	/*int second = 1;
	int minute = second * 60;
	int hour = minute * 60;
	
	NSMutableString *output = [NSMutableString string];
	unsigned long long leftover = secondsValue;
	BOOL useIt = NO;
	
	int hours = (leftover / hour);
	if (hours > 0 || useIt)
	{
		[output appendFormat:@"%02d", hours];
		leftover = (leftover % hour);
		useIt = YES;
	}
	
	int minutes = (leftover / minute);
	if (minutes > 0 || useIt)
	{
		[output appendFormat:@":%02d", minutes];
		leftover = (leftover % minute);
		useIt = YES;
	}
	
	int seconds = (leftover / second);
	if (seconds >= 0 || useIt)
	{
		[output appendFormat:@"%d second%@ ", seconds, (seconds == 1 ? @"" : @"s")];
		leftover = (leftover % second);
		useIt = YES;
	}
	
	
	return [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];*/
	
	unsigned long long seconds = secondsValue;
	//float second = 1.0;
	//float minute = second * 60;
	//float hour = minute * 60;
	//float day = hour * 24;
	
	/*if (seconds < minute)
	{
		return [NSString stringWithFormat:@"0:%02d", (long)seconds];
	}
	else if (seconds < hour)
	{
		return [NSString stringWithFormat:@"%d:%02d", (long)seconds/60, (long)seconds%60];
	}
	else
	{*/
		return [NSString stringWithFormat:@"%02d:%02d:%02d", (long)seconds/(60*60), (long)seconds/60%60, (long)seconds%60];
	//}
	
	return nil;
}

+ (NSString *)stringByFormattingSeconds3:(unsigned long long)secondsValue
{
	int second = 1;
	int minute = second * 60;
	int hour = minute * 60;
	//int day = hour * 24;
	
	NSMutableString *output = [NSMutableString string];
	unsigned long long leftover = secondsValue;
	BOOL useIt = NO;
	
	/*int days = (leftover / day);
	if (days > 0)
	{
		[output appendFormat:@"%d day%@ ", days, (days == 1 ? @"" : @"s")];
		leftover = (leftover % day);
		useIt = YES;
	}*/
	
	int hours = (leftover / hour);
	if (hours > 0 || useIt)
	{
		[output appendFormat:@"%d hour%@ ", hours, (hours == 1 ? @"" : @"s")];
		leftover = (leftover % hour);
		useIt = YES;
	}
	
	int minutes = (leftover / minute);
	if (minutes > 0 || useIt)
	{
		[output appendFormat:@"%d min%@ ", minutes, (minutes == 1 ? @"" : @"s")];
		leftover = (leftover % minute);
		useIt = YES;
	}
		
	return [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)stringByFormattingSeconds:(unsigned long long)seconds atRate:(float)rate withTax:(float)tax
{
	float hours = ((seconds / 60.0) / 60.0);
	float earnings = (hours * rate) * (1.0 - (tax / 100.0));
	
	static NSTextField *textField = nil;
	
	if (textField == nil)
	{
		textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setGeneratesDecimalNumbers:YES];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[textField setFormatter:numberFormatter];
		[numberFormatter release];
	}
	
	[textField setFloatValue:earnings];
	return [textField stringValue];
	
	//return [NSString stringWithFormat:@"$%.2f", earnings];
}

@end
