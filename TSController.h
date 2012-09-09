//
//  TSController.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSProject, TSProjectController, PSMTabBarControl, TSInfoController, TSEditTimesController;

@interface TSController : NSObject
{
	IBOutlet NSWindow *mainWindow;
	IBOutlet PSMTabBarControl *tabBar;
	TSInfoController *_infoController;
	TSEditTimesController *_editTimesController;
	
	NSImage *_timeousGray, *_timeousRed;
}

- (IBAction)import:(id)sender;
- (IBAction)sendFeedback:(id)sender;

- (void)saveData;
- (void)loadData;

- (TSProjectController *)currentController;
- (TSProject *)currentProject;

- (TSProjectController *)newTabForProject:(TSProject *)project;
- (void)newTab:(id)sender;

@end
