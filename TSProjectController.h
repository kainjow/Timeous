//
//  TSProjectController.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSDataController, TSProject;

@interface TSProjectController : NSObject
{
	IBOutlet NSView *contentView;
	IBOutlet NSOutlineView *periodsOutlineView;
	IBOutlet NSTextField *earningsField;
	
	TSDataController *_dataController;

	TSProject *_project;
	NSTimer *_periodTimer;
	
	NSObjectController *_objectController;
	NSImage *_icon;
}

- (id)initWithProject:(TSProject *)project;

- (void)setDataController:(TSDataController *)dataController;
- (TSDataController *)dataController;

- (TSProject *)project;
- (void)setProject:(TSProject *)project;
- (NSOutlineView *)periodsOutlineView;

- (void)startTimer;
- (void)stopTimer;
- (BOOL)timerIsActive;

- (void)setupGUI;
- (NSView *)contentView;
- (NSOutlineView *)outlineView;

- (void)setIcon:(NSImage *)icon;
- (NSImage *)icon;
- (NSObjectController *)controller;

- (void)updateEarningsField;

@end
