//
//  TSPeriodDay.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSProject;

@interface TSPeriodDay : NSObject
{
	NSMutableArray *_periods;
	
	TSProject *_project;
}

- (id)initWithProject:(TSProject *)project;
- (TSProject *)project;

- (void)setPeriods:(NSMutableArray *)periods;
- (NSMutableArray *)periods;

- (NSDate *)start;

- (int)numberOfItems;
- (unsigned long long)totalSeconds;

@end


@interface TSPeriodDay (Sorting)
- (NSComparisonResult)compare:(TSPeriodDay *)anotherPeriodDay;
@end