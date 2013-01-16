//
//  TSProject.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"

NSString *const TSProjectNameValue		= @"name";
NSString *const TSProjectRateValue		= @"rate";
NSString *const TSProjectTaxValue		= @"tax";
NSString *const TSProjectPeriodsValue	= @"periods";
NSString *const TSProjectSortIDValue	= @"sortID";


@implementation TSProject

- (void)didTurnIntoFault
{
	[self setCurrentPeriod:nil];
	[self setPeriodDays:nil];
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setCurrentPeriod:nil];
	[self setPeriodDays:[NSMutableArray array]];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	
	[self setCurrentPeriod:nil];
	[self setPeriodDays:[NSMutableArray array]];
	
	NSEnumerator *periodsEnum = [[self valueForKey:TSProjectPeriodsValue] objectEnumerator];
	TSPeriod *period = nil;
	while (period = [periodsEnum nextObject])
	{
		TSPeriodDay *day = [self periodDayForDate:[period start]];
		[period setDay:day];
		[[day periods] addObject:period];

		// sort periods within day
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
		[[day periods] sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		[sort release];
	}
	
	[[self periodDays] sortUsingSelector:@selector(compare:)];
}

- (NSMutableArray *)periodDays
{
	return _periodDays;
}

- (void)setPeriodDays:(NSMutableArray *)periodDays
{
	if (_periodDays != periodDays)
	{
		[_periodDays release];
		_periodDays = [periodDays retain];
	}
}

- (TSPeriod *)currentPeriod
{
	return _currentPeriod;
}

- (void)setCurrentPeriod:(TSPeriod *)period
{
	if (_currentPeriod != period)
	{
		[_currentPeriod release];
		_currentPeriod = [period retain];
	}
}

- (unsigned long long)totalSeconds
{
	unsigned long long total = 0;
	NSEnumerator *periodsEnum = [[self periodDays] objectEnumerator];
	TSPeriod *day = nil;
	while (day = [periodsEnum nextObject])
		total += [day totalSeconds];
	return total;
}

- (TSPeriodDay *)periodDayForToday
{
	return [self periodDayForDate:[[NSDate date] dateWithCalendarFormat:nil timeZone:nil]];
}

- (TSPeriodDay *)periodDayForDate:(NSDate *)date
{
	NSCalendarDate *calDate = [date dateWithCalendarFormat:nil timeZone:nil];
	NSCalendarDate *today = [NSCalendarDate dateWithYear:[calDate yearOfCommonEra]
												   month:[calDate monthOfYear]
													 day:[calDate dayOfMonth]
													hour:0
												  minute:0
												  second:0
												timeZone:[calDate timeZone]];
	NSEnumerator *daysEnum = [[self periodDays] objectEnumerator];
	TSPeriodDay *day = nil;

	while (day = [daysEnum nextObject])
	{
		NSCalendarDate *calStart = [[day start] dateWithCalendarFormat:nil timeZone:nil];
		if ([calStart dayOfMonth] == [today dayOfMonth] && 
			[calStart monthOfYear] == [today monthOfYear] && 
			[calStart yearOfCommonEra] == [today yearOfCommonEra])
			return day;
	}
	
	// got here because no new day exists, so create one
	day = [[TSPeriodDay alloc] initWithProject:self];
	[[self periodDays] addObject:day];
	[day release];
	return day;
}

- (void)addPeriod:(TSPeriod *)period toDay:(TSPeriodDay *)day
{
	[[day periods] addObject:period];
	[[self valueForKey:TSProjectPeriodsValue] addObject:period];
}

@end


@implementation TSProject (Sorting)
- (NSComparisonResult)compare:(id)aProject
{
	NSNumber *num1 = [self valueForKey:TSProjectSortIDValue];
	NSNumber *num2 = [aProject valueForKey:TSProjectSortIDValue];
	if (num1 == nil)
		return NSOrderedDescending;
	else if (num2 == nil)
		return NSOrderedAscending;
	return [num1 compare:num2];
}
@end
