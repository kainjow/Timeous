//
//  TSEditTimesController.m
//  Timeous
//
//  Created by Kevin Wojniak on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSEditTimesController.h"
#import "TSPeriod.h"
#import "NSStringXtras.h"


@implementation TSEditTimesController

- (id)init
{
	if (self = [super initWithWindowNibName:@"EditTimes" owner:self])
	{
		_period = nil;
	}
	
	return self;
}

- (void)dealloc
{
	_period = nil;
	[super dealloc];
}

- (void)setPeriod:(TSPeriod *)period
{
	_period = period;
	
	[startDatePicker setDateValue:[period start]];
	[endDatePicker setDateValue:[period end]];
	
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	NSDate *startDate = [startDatePicker dateValue], *endDate = [endDatePicker dateValue];
	if ([endDate earlierDate:startDate] == startDate)
		[textField setStringValue:[NSString stringByFormattingSeconds:[endDate timeIntervalSinceDate:startDate]]];
	else
		[textField setStringValue:@""];		
}

- (IBAction)ok:(id)sender
{
	NSDate *startDate = [startDatePicker dateValue], *endDate = [endDatePicker dateValue];
	if ([endDate earlierDate:startDate] == endDate)
	{
		NSBeep();
		NSRunAlertPanel(@"Error",@"End date is before start date!",@"Oops",nil,nil);
	}
	else
	{
		[_period setStart:[startDate dateWithCalendarFormat:nil timeZone:nil]];
		[_period setEnd:[endDate dateWithCalendarFormat:nil timeZone:nil]];
		
		[NSApp endSheet:[self window]];
		[self close];
	}
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

@end
