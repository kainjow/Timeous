//
//  TSEarnings.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSProject;

@interface TSInfoController : NSWindowController
{
	IBOutlet NSTextField *rateField, *taxField, *nameField;
	
	TSProject *_project;	
}

- (void)setProject:(TSProject *)project;
- (IBAction)close:(id)sender;

@end
