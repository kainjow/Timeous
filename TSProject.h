//
//  TSProject.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSPeriod, TSPeriodDay;

extern NSString *const TSProjectNameValue;
extern NSString *const TSProjectRateValue;
extern NSString *const TSProjectTaxValue;
extern NSString *const TSProjectPeriodsValue;
extern NSString *const TSProjectSortIDValue;


@interface TSProject : NSManagedObject
{
	NSMutableArray *_periodDays;
	TSPeriod *_currentPeriod;
}

- (NSMutableArray *)periodDays;
- (void)setPeriodDays:(NSMutableArray *)periodDays;

- (TSPeriod *)currentPeriod;
- (void)setCurrentPeriod:(TSPeriod *)period;

- (unsigned long long)totalSeconds;

- (TSPeriodDay *)periodDayForToday;
- (TSPeriodDay *)periodDayForDate:(NSDate *)date;
- (void)addPeriod:(TSPeriod *)period toDay:(TSPeriodDay *)day;

@end


@interface TSProject (Sorting)
- (NSComparisonResult)compare:(id)aProject;
@end
