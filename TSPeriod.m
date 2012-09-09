//
//  TSPeriod.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSPeriod.h"


@implementation TSPeriod

/*- (id)init
{
	if (self = [super init])
	{
		[self setStart:[NSCalendarDate calendarDate]];
		[self setEnd:nil];
		[self setNotes:nil];

		[self setDay:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[self setStart:nil];
	[self setEnd:nil];
	[self setNotes:nil];

	[self setDay:nil];

	[super dealloc];
}*/

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setStart:[NSDate date]];
	[self setDay:nil];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	
	[self setDay:nil];
}

- (void)didTurnIntoFault
{
	[self setDay:nil];
}

#pragma mark -
#pragma mark Accessors

- (NSDate *)start
{
	NSDate *ret = nil;
	[self willAccessValueForKey:@"start"];
	ret = [self primitiveValueForKey:@"start"];
	[self didAccessValueForKey:@"start"];
	return ret;
	//return _start;
}

- (void)setStart:(NSDate *)date
{
	[self willChangeValueForKey:@"start"];
	[self setPrimitiveValue:date forKey:@"start"];
	[self didChangeValueForKey:@"start"];
	/*if (_start != date)
	{
		[_start release];
		_start = [date copy];
	}*/
}

- (NSDate *)end
{
	NSDate *ret = nil;
	[self willAccessValueForKey:@"end"];
	ret = [self primitiveValueForKey:@"end"];
	[self didAccessValueForKey:@"end"];
	return ret;
	//return _end;
}

- (void)setEnd:(NSDate *)date
{
	[self willChangeValueForKey:@"end"];
	[self setPrimitiveValue:date forKey:@"end"];
	[self didChangeValueForKey:@"end"];
	
	/*if (_end != date)
	{
		[_end release];
		_end = [date copy];
	}*/
}

- (NSString *)notes
{
	NSString *ret = nil;
	[self willAccessValueForKey:@"notes"];
	ret = [self primitiveValueForKey:@"notes"];
	[self didAccessValueForKey:@"notes"];
	return ret;
	//return _notes;
}

- (void)setNotes:(NSString *)notes
{
	[self willChangeValueForKey:@"notes"];
	[self setPrimitiveValue:notes forKey:@"notes"];
	[self didChangeValueForKey:@"notes"];
	/*if (_notes != notes)
	{
		[_notes release];
		_notes = [notes copy];
	}*/
}

#pragma mark -
#pragma mark Utilities

- (int)numberOfItems
{
	return 0;
}

- (unsigned long long)totalSeconds
{
	return (unsigned long long)[[self end] timeIntervalSinceDate:[self start]];
}

- (TSPeriodDay *)day
{
	return _day;
}

- (void)setDay:(TSPeriodDay *)day
{
	// weak link
	_day = day;
}

@end
