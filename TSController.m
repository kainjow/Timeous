//
//  TSController.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSController.h"
#import "TSProjectController.h"
#import "TSInfoController.h"
#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"
#import <PSMTabBarControl/PSMTabBarControl.h>
#import "NSStringXtras.h"
#import "TSEditTimesController.h"


@interface NSToolbar (TSXtras)
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier;
@end
@implementation NSToolbar (TSXtras)
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
{
	NSEnumerator *e = [[self items] objectEnumerator];
	NSToolbarItem *item; while (item = [e nextObject])
		if ([[item itemIdentifier] isEqualToString:identifier])
			return item;
	return nil;
}
@end

@interface TSController (priv)
- (void)updateDockIcon;
- (void)assignNewUIDToProject:(TSProject *)project;
@end

@implementation TSController

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:0.0], @"TSDefaultRate",
		nil]];
}

- (id)init
{
	if (self = [super init])
	{
		srandom(time(NULL));

		_timeousGray = [[NSImage imageNamed:@"Timeous"] retain];
		_timeousRed = [[NSImage imageNamed:@"Timeous red"] retain];
	}
	
	return self;
	
}

- (void)dealloc
{
	[_infoController release];
	[_editTimesController release];
	[_timeousGray release];
	[_timeousRed release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:@"TSMainToolbar"] autorelease];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	if ([toolbar respondsToSelector:@selector(setShowsBaselineSeparator:)])
		[toolbar setShowsBaselineSeparator:YES];
	[mainWindow setToolbar:toolbar];
	
	// remove all tab view items in nib
	while ([[[tabBar tabView] tabViewItems] count] > 0)
		[[tabBar tabView] removeTabViewItem:[[tabBar tabView] tabViewItemAtIndex:0]];
	
	[mainWindow setFrameAutosaveName:@"TSMainWindow"];
	[tabBar setStyleNamed:@"Unified"];
	
	[self loadData];
	[self updateDockIcon];
}

#pragma mark -

- (NSEnumerator *)tabViewItemEnumerator
{
	return [[[tabBar tabView] tabViewItems] objectEnumerator];
}

#define DATA_PATH [@"~/Library/Application Support/Timeous/data.plist" stringByStandardizingPath]

- (void)saveData
{
	NSMutableArray *projects = [NSMutableArray array];
	
	NSEnumerator *projectsEnum = [self tabViewItemEnumerator];
	NSTabViewItem *item;
	while (item = [projectsEnum nextObject])
	{
		TSProject *project = [[[item identifier] content] project];
		
		NSMutableDictionary *d = [NSMutableDictionary dictionary];
		[d setObject:([project name] ? [project name] : @"Untitled") forKey:@"Name"];
		[d setObject:[NSNumber numberWithFloat:[project rate]] forKey:@"Rate"];
		[d setObject:[NSNumber numberWithFloat:[project tax]] forKey:@"Tax"];
		[d setObject:[NSNumber numberWithInt:[project uid]] forKey:@"UID"];
		
		NSMutableArray *periods = [NSMutableArray array];
		NSEnumerator *daysEnum = [[project days] objectEnumerator];
		TSPeriodDay *day; while (day = [daysEnum nextObject])
		{
			NSEnumerator *periodsEnum = [[day periods] objectEnumerator];
			TSPeriod *period; while (period = [periodsEnum nextObject])
				[periods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					[period start], @"Start",
					[period end], @"End",
					([period notes] ? [period notes] : @""), @"Notes",
					nil]];
		}
		[d setObject:periods forKey:@"Periods"];
		[projects addObject:d];
	}

	// build path
	system([[NSString stringWithFormat:@"mkdir -p \"%@\"", [DATA_PATH stringByDeletingLastPathComponent]] UTF8String]);
	
	[projects writeToFile:DATA_PATH atomically:YES];
}

- (void)loadData
{
	NSArray *projects = [NSMutableArray arrayWithContentsOfFile:DATA_PATH];
	NSEnumerator *projectsEnum = [projects objectEnumerator];
	NSDictionary *d; while (d = [projectsEnum nextObject])
	{
		TSProject *project = [[[TSProject alloc] init] autorelease];
		[project setName:([d objectForKey:@"Name"] ? [d objectForKey:@"Name"] : @"Untitled")];
		[project setRate:[[d objectForKey:@"Rate"] floatValue]];
		[project setTax:[[d objectForKey:@"Tax"] floatValue]];
		
		NSNumber *uid = [d objectForKey:@"UID"];
		if (uid)
			[project setUID:[uid intValue]];
		else
			[self assignNewUIDToProject:project];
		
		NSArray *periods = [d objectForKey:@"Periods"];
		NSEnumerator *periodsEnum = [periods objectEnumerator];
		NSDictionary *p; while (p = [periodsEnum nextObject])
		{
			NSCalendarDate *start = [NSCalendarDate dateWithString:[[p objectForKey:@"Start"] description]];
			NSCalendarDate *end = [NSCalendarDate dateWithString:[[p objectForKey:@"End"] description]];

			TSPeriod *period = [[TSPeriod alloc] init];
			[period setStart:start];
			[period setEnd:end];
			[period setNotes:[p objectForKey:@"Notes"]];
			
			TSPeriodDay *day = [project periodDayForDate:[period start]];
			[period setDay:day];
			[[day periods] addObject:period];
			[period release];
			
		}
		
		[project setCurrentPeriod:nil];
		
		[self newTabForProject:project];
	}
}

- (TSProjectController *)currentController
{
	NSTabViewItem *item = [[tabBar tabView] selectedTabViewItem];
	if (item == nil)
		return nil;
	id identifier = [item identifier];
	//if (identifier != nil && [identifier isKindOfClass:[TSProjectController class]])
	if (identifier != nil && [identifier isKindOfClass:[NSObjectController class]])
		return [(NSObjectController *)identifier content];
	return nil;
}

- (TSProject *)currentProject
{
	return [[self currentController] project];
}

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[NSApp setApplicationIconImage:_timeousGray];
	
	
	NSEnumerator *projectsEnum = [self tabViewItemEnumerator];
	NSTabViewItem *item;
	while (item = [projectsEnum nextObject])
	{
		TSProjectController *controller = [[item identifier] content];
		NSOutlineView *ov = [controller periodsOutlineView];
		int i;
		for (i=0; i<[ov numberOfRows]; i++)
			[ov collapseItem:[ov itemAtRow:i]];
	}
	
	[self saveData];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)importTimeCardPlist:(NSString *)path
{
	NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:path];
	if (!d || [d count] == 0)
		return;
	
	NSArray *days = [d objectForKey:@"days"];
	if (!days || [days count] == 0)
		return;
	
	NSEnumerator *daysEnum = [days objectEnumerator];
	NSDictionary *day = nil;
	while (day = [daysEnum nextObject])
	{
		if ([day isKindOfClass:[NSDictionary class]] == NO)
			continue;
		
		NSEnumerator *periodsEnum = [[day objectForKey:@"periods"] objectEnumerator];
		NSDictionary *p;
		while (p = [periodsEnum nextObject])
		{
			NSCalendarDate *start = [NSCalendarDate dateWithString:[[p objectForKey:@"start"] description]];
			NSCalendarDate *end = [NSCalendarDate dateWithString:[[p objectForKey:@"end"] description]];
			
			TSPeriodDay *day = [[self currentProject] periodDayForDate:start];
			TSPeriod *period = [[TSPeriod alloc] init];
			[period setStart:start];
			[period setEnd:end];
			[period setDay:day];
			[[day periods] addObject:period];
			[period release];
		}
	}
	
	[[[self currentController] outlineView] reloadData];
	[[self currentController] updateEarningsField];
}

- (IBAction)import:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:NO];
	[op setCanChooseFiles:YES];
	[op setCanCreateDirectories:NO];
	[op setAllowsMultipleSelection:NO];
	[op beginSheetForDirectory:nil
						  file:nil
						 types:[NSArray arrayWithObject:@"plist"]
				modalForWindow:mainWindow
				 modalDelegate:self
				didEndSelector:@selector(importPanelDidEnd:returnCode:contextInfo:)
				   contextInfo:NULL];
}

- (void)importPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[self importTimeCardPlist:[panel filename]];
	}
}

- (IBAction)sendFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:kainjow@kainjow.com?subject=Timeous%20Feedback"]];
}

- (void)updateStartStopButton
{
	NSToolbarItem *item = [[mainWindow toolbar] toolbarItemWithIdentifier:@"TSStartStop"];
	if ([[self currentProject] currentPeriod] == nil)
	{
		[item setImage:[NSImage imageNamed:@"Start"]];
		[item setLabel:@"Start"];
		[[self currentController] setIcon:nil];
	}
	else
	{
		[item setImage:[NSImage imageNamed:@"circle_block"]];
		[item setLabel:@"Stop"];
		[[self currentController] setIcon:[NSImage imageNamed:@"clock_red"]];
	}
}

- (void)updateDockIcon
{
	BOOL timerOn = NO;
	NSEnumerator *projectsEnum = [self tabViewItemEnumerator];
	NSTabViewItem *item;
	while (item = [projectsEnum nextObject])
	{
		TSProject *project = [[[item identifier] content] project];
		if ([project currentPeriod] != nil)
		{
			timerOn = YES;
			break;
		}
	}
	
	if (timerOn)
		[NSApp setApplicationIconImage:_timeousRed];
	else
		[NSApp setApplicationIconImage:_timeousGray];
}

- (IBAction)startStop:(id)sender
{
	TSProjectController *controller = [self currentController];
	TSProject *project = [self currentProject];
	
	if ([project currentPeriod] == nil) // start
	{
		TSPeriodDay *day = [project periodDayForToday];
		TSPeriod *period = [project startPeriodForDay:day];
		[[controller outlineView] reloadData];
		[[controller outlineView] expandItem:day];
		
		[project setCurrentPeriod:period];
		
		[controller startTimer];
	}
	else
	{
		[project setCurrentPeriod:nil];
		[controller stopTimer];
		[[controller outlineView] reloadData];
	}
	
	[self updateStartStopButton];
	[self updateDockIcon];
}

- (IBAction)deletePeriod:(id)sender
{
	NSBeginAlertSheet(@"Confirm Delete",@"OK",@"Cancel",nil,mainWindow,self,@selector(deleteSheetDidEnd:returnCode:contextInfo:),nil,NULL,@"Are you sure you want to delete the currently selected times?");
}

- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSCancelButton)
		return;
	
	NSEnumerator *rows = [[[[[self currentController] outlineView] selectedRowEnumerator] allObjects] reverseObjectEnumerator];
	NSNumber *row;
	while (row = [rows nextObject])
	{
		TSPeriod *period = [[[self currentController] outlineView] itemAtRow:[row intValue]];
		
		if ([[self currentProject] currentPeriod] == period) // stop timer
			[NSApp sendAction:@selector(startStop:) to:self from:[[mainWindow toolbar] toolbarItemWithIdentifier:@"TSStartStop"]];
		
		[[[period day] periods] removeObject:period];
	}
	
	NSEnumerator *daysEnum = [[[self currentProject] days] objectEnumerator];
	TSPeriodDay *day;
	while (day = [daysEnum nextObject])
		if ([[day periods] count] == 0)
			[[[self currentProject] days] removeObject:day];
	
	[[self currentController] updateEarningsField];
	[[[self currentController] outlineView] reloadData];
}

- (IBAction)editTimes:(id)sender
{
	if (_editTimesController == nil)
		_editTimesController = [[TSEditTimesController alloc] init];
	NSWindow *win = [_editTimesController window];
	
	TSPeriod *selectedPeriod = [[[self currentController] outlineView] itemAtRow:[[[self currentController] outlineView] selectedRow]];
	[_editTimesController setPeriod:selectedPeriod];
	[NSApp beginSheet:win
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(editTimesWindowDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)editTimesWindowDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[[[self currentController] outlineView] reloadData];
	[[self currentController] updateEarningsField];
	[self saveData];
}

- (IBAction)projectInfo:(id)sender
{
	if (_infoController == nil)
		_infoController = [[TSInfoController alloc] init];
	NSWindow *win = [_infoController window];
	[_infoController setProject:[self currentProject]];
	[NSApp beginSheet:win
	   modalForWindow:mainWindow
		modalDelegate:self
	   didEndSelector:@selector(projectWindowDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)projectWindowDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[[self currentController] updateEarningsField];
	[[[tabBar tabView] selectedTabViewItem] setLabel:[[self currentProject] name]];
	[self saveData];
}

- (void)assignNewUIDToProject:(TSProject *)project
{
	int uid = random();
	[project setUID:uid];
}

- (TSProjectController *)newTabForProject:(TSProject *)project
{
	TSProjectController *controller = [[[TSProjectController alloc] init] autorelease];
	if (project != nil)
		[controller setProject:project];
	
	NSTabView *tabView = [tabBar tabView];
	NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:[controller controller]] autorelease];
	[item setLabel:([project name] ? [project name] : @"Untitled")];
	[item setView:[controller contentView]];
	[tabView addTabViewItem:item];
	[tabView selectTabViewItem:item];
	
	if ([project uid] == -1)
		[self assignNewUIDToProject:project];

	[controller setupGUI];
	
	return controller;
}

- (void)newTab:(id)sender
{
	[self newTabForProject:nil];
}

- (NSString *)exportCurrentProjectAsText
{
	NSMutableString *text = [NSMutableString string];
	
	TSProject *project = [self currentProject];
	NSEnumerator *projectDaysEnum = [[project days] objectEnumerator];
	TSPeriodDay *day;
	while (day = [projectDaysEnum nextObject])
	{
		[text appendFormat:@"%@\n", [[day start] descriptionWithCalendarFormat:@"%A, %B %e"]];
		
		NSEnumerator *periodsEnum = [[day periods] objectEnumerator];
		TSPeriod *period;
		while (period = [periodsEnum nextObject])
		{
			[text appendFormat:@"\t%@\tto %@\t%0.1f\t%@\n",
				[[period start] descriptionWithCalendarFormat:@"%I:%M:%S %p"],
				[[period end] descriptionWithCalendarFormat:@"%I:%M:%S %p"],
				//[NSString stringByFormattingSeconds3:[period totalSeconds]],
				[period totalSeconds]/60.0,
				([period notes] != nil && [[period notes] length] > 0 ? [NSString stringWithFormat:@"(%@)", [period notes]] : @"")
				];
		}
	}
	
	unsigned long long totalSeconds = [project totalSeconds];
	[text appendFormat:@"\nTotal: %@ = %@",
		[NSString stringByFormattingSeconds3:totalSeconds],
		[NSString stringByFormattingSeconds:totalSeconds atRate:[project rate] withTax:[project tax]]
		];
	return text;
}

- (void)exportText:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType:@"txt"];
	[savePanel beginSheetForDirectory:nil
								 file:[[self currentProject] name]
					   modalForWindow:mainWindow
						modalDelegate:self
					   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
		[[self exportCurrentProjectAsText] writeToFile:[sheet filename] atomically:YES];
}

#pragma mark -

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];

	[item setTarget:self];

	if ([itemIdentifier isEqualToString:@"TSStartStop"])
	{
		[item setLabel:@"Start"];
		[item setImage:[NSImage imageNamed:@"Start"]];
		[item setAction:@selector(startStop:)];
	}
	else if ([itemIdentifier isEqualToString:@"TSDelete"])
	{
		[item setLabel:@"Delete"];
		[item setImage:[NSImage imageNamed:@"Delete"]];
		[item setAction:@selector(deletePeriod:)];
	}
	else if ([itemIdentifier isEqualToString:@"TSNewTab"])
	{
		[item setLabel:@"New Tab"];
		[item setImage:[NSImage imageNamed:@"circle_add"]];
		[item setAction:@selector(newTab:)];
	}
	else if ([itemIdentifier isEqualToString:@"TSProjectInfo"])
	{
		[item setLabel:@"Project Info"];
		[item setImage:[NSImage imageNamed:@"GetInfo"]];
		[item setAction:@selector(projectInfo:)];
	}
	else if ([itemIdentifier isEqualToString:@"TSText"])
	{
		[item setLabel:@"Export to Text"];
		[item setImage:[NSImage imageNamed:@"text"]];
		[item setAction:@selector(exportText:)];
	}
	else if ([itemIdentifier isEqualToString:@"TSEditTimes"])
	{
		[item setLabel:@"Edit"];
		[item setImage:[NSImage imageNamed:@"EditTimesButton"]];
		[item setAction:@selector(editTimes:)];
	}
	
	[item setPaletteLabel:[item label]];
	
	return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		@"TSStartStop",
		@"TSDelete",
		@"TSProjectInfo",
		@"TSNewTab",
		@"TSText",
		@"TSEditTimes",
		NSToolbarSpaceItemIdentifier,
		NSToolbarSeparatorItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		@"TSStartStop",
		NSToolbarSeparatorItemIdentifier,
		@"TSDelete",
		@"TSEditTimes",
		NSToolbarSpaceItemIdentifier,
		@"TSNewTab",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"TSText",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"TSProjectInfo",
		nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	if ([theItem action] == @selector(deletePeriod:))
		return ([[[self currentController] outlineView] numberOfSelectedRows] != 0);
	else if ([theItem action] == @selector(editTimes:))
	{
		TSPeriod *selectedPeriod = [[[self currentController] outlineView] itemAtRow:[[[self currentController] outlineView] selectedRow]];
		return ([[[self currentController] outlineView] numberOfSelectedRows] == 1 && [[self currentProject] currentPeriod] != selectedPeriod);
	}
		
	return YES;
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self updateStartStopButton];
}

@end
