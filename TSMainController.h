//
//  TSController.h
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PSMTabBarControl, TSDataController, TSProject, TSProjectController, TSInfoController, TSEditTimesController;

@interface TSMainController : NSWindowController <NSToolbarDelegate>
{
	IBOutlet PSMTabBarControl *tabBar;
	
	TSDataController *_dataController;
	
	TSInfoController *_infoController;
	TSEditTimesController *_editTimesController;
	
	NSImage *_timeousGray, *_timeousRed;
	
	NSTimer *_saveTimer;
}

- (void)setDataController:(TSDataController *)dataController;
- (TSDataController *)dataController;

- (void)saveData;

- (TSProjectController *)currentController;
- (TSProject *)currentProject;

- (TSProjectController *)newTabForProject:(TSProject *)project;
- (void)newTab:(id)sender;

- (unsigned int)numberOfActiveProjects;

@end
