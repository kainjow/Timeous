//
//  TSPeriodDay.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import "TSPeriodDay.h"
#import "TSPeriod.h"

@implementation TSPeriodDay

- (id)initWithProject:(TSProject *)project
{
	if (self = [super init])
	{
		_project = [project retain];
		[self setPeriods:[NSMutableArray array]];
	}
	
	return self;
}

- (void)dealloc
{
	[self setPeriods:nil];
	[_project release];

	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (TSProject *)project
{
	return _project;
}

- (void)setPeriods:(NSMutableArray *)periods
{
	if (_periods != periods)
	{
		[_periods release];
		_periods = [periods retain];
	}
}

- (NSMutableArray *)periods
{
	return _periods;
}

- (NSDate *)start
{
	NSDate *date = nil;
	
	NSArray *periods = [self periods];
	if ([periods count])
	{
		TSPeriod *period = [periods objectAtIndex:0];
		date = [period start];
	}
	
	if (date == nil)
		return nil;
	
	NSCalendarDate *calDate = [date dateWithCalendarFormat:nil timeZone:nil];
	return (NSDate *)[NSCalendarDate dateWithYear:[calDate yearOfCommonEra]
											month:[calDate monthOfYear]
											  day:[calDate dayOfMonth]
											 hour:0
										   minute:0
										   second:0
										 timeZone:[calDate timeZone]];
}

#pragma mark -
#pragma mark Utilities

- (int)numberOfItems
{
	return (int)[[self periods] count];
}

- (unsigned long long)totalSeconds
{
	unsigned long long total = 0;
	NSEnumerator *periodsEnum = [[self periods] objectEnumerator];
	TSPeriod *period = nil;
	while (period = [periodsEnum nextObject])
		total += [period totalSeconds];
	return total;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%lu periods", (unsigned long)[[self periods] count]];
}

@end


@implementation TSPeriodDay (Sorting)

- (NSComparisonResult)compare:(TSPeriodDay *)anotherPeriodDay
{
	NSDate *val1 = [self start];
	NSDate *val2 = [anotherPeriodDay start];
	if (val1 == nil)
		return NSOrderedDescending;
	else if (val2 == nil)
		return NSOrderedAscending;
	return [val1 compare:val2];	
}

@end