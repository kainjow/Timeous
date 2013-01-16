//
//  TSPeriod.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSPeriodDay;

@interface TSPeriod : NSManagedObject
{
	//NSCalendarDate *_start, *_end;
	//NSString *_notes;
	
	TSPeriodDay *_day;
}

- (NSDate *)start;
- (void)setStart:(NSDate *)date;
- (NSDate *)end;
- (void)setEnd:(NSDate *)date;
- (NSString *)notes;
- (void)setNotes:(NSString *)notes;


- (int)numberOfItems;
- (unsigned long long)totalSeconds;

- (TSPeriodDay *)day;
- (void)setDay:(TSPeriodDay *)day;

@end
