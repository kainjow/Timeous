//
//  TSAppController.m
//  Timeous
//
//  Created by Kevin Wojniak on 12/8/07.
//  Copyright 2007 Kevin Wojniak. All rights reserved.
//

#import "TSAppController.h"
#import "TSMainController.h"
#import "TSDataController.h"
#import "TSProjectController.h"
#import "TSProject.h"


@implementation TSAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_dataController = [[TSDataController alloc] init];
	
	_mainController = [[TSMainController alloc] init];
	[_mainController setDataController:_dataController];
	[_mainController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[_dataController saveData];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// see if any projects are running, and if so, display a dialog
	unsigned int numberOfActiveProjects = [_mainController numberOfActiveProjects];
	if (numberOfActiveProjects)
	{
		NSInteger result = NSRunAlertPanel(@"Are you sure you want to quit?", @"There are one or more projects currently running. Quitting now still stop the timer. Are you sure you still want to quit?", @"Quit", @"Cancel", nil);
		if (result == NSCancelButton)
			return NSTerminateCancel;
	}
	
	return NSTerminateNow;
}	

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)sendFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:kainjow@kainjow.com?subject=Timeous%20Feedback"]];
}

- (IBAction)showPrefs:(id)sender
{
	if (_prefsController == nil)
		_prefsController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
	[_prefsController showWindow:self];
}

@end
