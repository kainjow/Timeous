//
//  TSEditTimesController.h
//  Timeous
//
//  Created by Kevin Wojniak on 10/29/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSPeriod;

@interface TSEditTimesController : NSWindowController
{
	IBOutlet NSDatePicker *startDatePicker, *endDatePicker;
	IBOutlet NSTextField *textField;
	TSPeriod *_period;
}

- (void)setPeriod:(TSPeriod *)period;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)update:(id)sender;

@end
