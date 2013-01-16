//
//  TSController.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 Kevin Wojniak. All rights reserved.
//

#import "TSMainController.h"
#import "TSDataController.h"
#import "TSProjectController.h"
#import "TSInfoController.h"
#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"
#import "NSStringXtras.h"
#import "TSEditTimesController.h"
#import "NSToolbarAdditions.h"
#import "TSUserDefaultKeys.h"


@interface TSMainController (PrivateMethods)
- (NSEntityDescription *)projectEntity;
- (void)updateDockIcon;
- (NSEnumerator *)tabViewItemsEnumerator;
@end

@implementation TSMainController

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:0.0], TS_DEFAULT_RATE_KEY,
							  [NSNumber numberWithFloat:0.0], TS_DEFAULT_TAX_KEY,
							  [NSNumber numberWithBool:NO], TS_USE_HHMMSS_FORMAT,
							  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)init
{
	if (self = [super initWithWindowNibName:@"ProjectsWindow" owner:self])
	{
		[self setDataController:nil];

		_timeousGray = [[NSImage imageNamed:@"Timeous"] retain];
		_timeousRed = [[NSImage imageNamed:@"Timeous red"] retain];
	}
	
	return self;
	
}

- (void)dealloc
{
	[self setDataController:nil];
	
	[_infoController release];
	[_editTimesController release];

	[_timeousGray release];
	[_timeousRed release];
	
	[_saveTimer release];
	
	[super dealloc];
}

- (void)selectProjectWithName:(NSString *)projectName
{
	NSEnumerator *tabItemsEnum = [[[tabBar tabView] tabViewItems] objectEnumerator];
	NSTabViewItem *tbi = nil;
	
	while (tbi = [tabItemsEnum nextObject])
	{
		NSObjectController *objContr = (NSObjectController *)[tbi identifier];
		TSProjectController *projContr = (TSProjectController *)[objContr content];
		TSProject *proj = [projContr project];
		
		if ([[proj valueForKey:TSProjectNameValue] isEqualToString:projectName])
		{
			[[tabBar tabView] selectTabViewItemWithIdentifier:objContr];
			break;
		}
	}
}

- (void)setupProjectTabs
{
	// create the tabs for each project
	NSArray *sortedProjects = [[[self dataController] loadData] sortedArrayUsingSelector:@selector(compare:)];
	NSEnumerator *projectsEnum = [sortedProjects objectEnumerator];
	TSProject *proj = nil;
	
	while (proj = [projectsEnum nextObject])
		[self newTabForProject:proj];
}

- (void)awakeFromNib
{
	// this must be stored before we create any new tabs!
	NSString *lastSelectedProject = [[NSUserDefaults standardUserDefaults] objectForKey:TS_LAST_PROJECT];
	
	// setup the toolbar
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:@"TSMainToolbar"] autorelease];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
    [toolbar setShowsBaselineSeparator:YES];
	[[self window] setToolbar:toolbar];
	
	// save the window position
	[[self window] setFrameAutosaveName:@"TSMainWindow"];

	// remove default tab view item (from nib)
	NSArray *tabViewItems = [[tabBar tabView] tabViewItems];
	if ([tabViewItems count])
	{
		NSTabViewItem *item = [tabViewItems objectAtIndex:0];
		[[tabBar tabView] removeTabViewItem:item];
	}
	
	// setup the tab bar's style and close alert
	[tabBar setStyleNamed:@"Unified"];
	[tabBar setDelegate:self];

	// setup the tabs
	[self setupProjectTabs];
	[self selectProjectWithName:lastSelectedProject];
	
	// always have 1 project open
	if ([[[tabBar tabView] tabViewItems] count] == 0)
		[self newTab:nil];

	[self updateDockIcon];
}

- (void)setDataController:(TSDataController *)dataController
{
	if (_dataController != dataController)
	{
		[_dataController release];
		_dataController = [dataController retain];
	}
}

- (TSDataController *)dataController
{
	return [[_dataController retain] autorelease];
}

- (void)saveData
{
	// save the tab index of each project
	NSEnumerator *tabItemsEnum = [[tabBar representedTabViewItems] objectEnumerator];
	NSTabViewItem *tbi = nil;
	unsigned tindex = 0;
	while (tbi = [tabItemsEnum nextObject])
	{
		id itemIdent = [tbi identifier];
		if ([itemIdent isKindOfClass:[NSObjectController class]])
		{
			TSProject *project = [[(NSObjectController *)itemIdent content] project];
			[project setValue:[NSNumber numberWithInt:tindex++] forKey:TSProjectSortIDValue];
		}
	}
	
	[[self dataController] saveData];
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

- (void)updateStartStopButton
{
	NSToolbarItem *item = [[[self window] toolbar] toolbarItemWithIdentifier:@"TSStartStop"];
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

- (NSEnumerator *)tabViewItemsEnumerator
{
	return [[tabBar representedTabViewItems] objectEnumerator];
}

- (unsigned int)numberOfActiveProjects
{
	unsigned int count = 0;
	NSEnumerator *projectsEnum = [self tabViewItemsEnumerator];
	NSTabViewItem *item = nil;
	while (item = [projectsEnum nextObject])
	{
		id itemIdent = [item identifier];
		if ([itemIdent isKindOfClass:[NSObjectController class]])
		{
			TSProject *project = [[(NSObjectController *)itemIdent content] project];
			if ([project currentPeriod] != nil)
			{
				count++;
			}
		}
	}
	
	return count;
}

- (void)updateDockIcon
{
	BOOL timerOn = ([self numberOfActiveProjects] > 0);
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
		TSPeriod *period = [[self dataController] newPeriod];
		
		[period setDay:day];
		[project addPeriod:period toDay:day];
		
		[[controller outlineView] reloadData];
		[[controller outlineView] expandItem:day];
		
		[project setCurrentPeriod:period];
		
		[controller startTimer];
		
		// if no other projects are currently running, start saveTimer
		if (_saveTimer == nil)
		{
			_saveTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0
														   target:self
														 selector:@selector(saveData)
														 userInfo:nil
														  repeats:YES] retain];
		}
	}
	else
	{
		[project setCurrentPeriod:nil];
		[controller stopTimer];
		[[controller outlineView] reloadData];
		
		// if no projects are running, stop the saveTimer
		if ([self numberOfActiveProjects] == 0)
		{
			if (_saveTimer)
			{
				[_saveTimer invalidate];
				[_saveTimer release];
			}
			_saveTimer = nil;
		}
	}
	
	[self saveData];
	
	[self updateStartStopButton];
	[self updateDockIcon];
}

- (IBAction)deletePeriod:(id)sender
{
	NSBeginAlertSheet(@"Confirm Delete",@"OK",@"Cancel",nil,[self window],self,@selector(deleteSheetDidEnd:returnCode:contextInfo:),nil,NULL,@"Are you sure you want to delete the currently selected times?");
}

- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSCancelButton)
		return;

    NSIndexSet *rows = [[[self currentController] outlineView] selectedRowIndexes];
    [rows enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop){
		TSPeriod *period = [[[self currentController] outlineView] itemAtRow:idx];
		
		if ([[self currentProject] currentPeriod] == period) // stop timer
			[NSApp sendAction:@selector(startStop:) to:self from:[[[self window] toolbar] toolbarItemWithIdentifier:@"TSStartStop"]];
		
		// remove period from PeriodDay and Project (Core Data)
		[[[period day] periods] removeObject:period];
		
		[[self dataController] deleteObject:period];
	}];
	
	NSEnumerator *daysEnum = [[[self currentProject] periodDays] objectEnumerator];
	TSPeriodDay *day;
	while (day = [daysEnum nextObject])
		if ([[day periods] count] == 0)
			[[[self currentProject] periodDays] removeObject:day];
	
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
	   modalForWindow:[self window]
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
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(projectWindowDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)projectWindowDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[[self currentController] updateEarningsField];
	[[[tabBar tabView] selectedTabViewItem] setLabel:[[self currentProject] valueForKey:TSProjectNameValue]];
	[self saveData];
}

#pragma mark -
#pragma mark Project Creation

- (TSProjectController *)newTabForProject:(TSProject *)project
{
	TSProjectController *controller = [[[TSProjectController alloc] initWithProject:project] autorelease];

	NSTabView *tabView = [tabBar tabView];
	NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:[controller controller]] autorelease];
	NSString *projectName = [project valueForKey:TSProjectNameValue];
	if (projectName == nil)
		projectName = @"Untitled";
	[item setLabel:projectName];
	[item setView:[controller contentView]];
	[tabView addTabViewItem:item];
	[tabView selectTabViewItem:item];
	
	[controller setupGUI];
	
	return controller;
}

- (void)newTab:(id)sender
{
	TSProject *project = [[self dataController] newProject];
	[project setValue:[[NSUserDefaults standardUserDefaults] objectForKey:TS_DEFAULT_RATE_KEY] forKey:TSProjectRateValue];
	[project setValue:[[NSUserDefaults standardUserDefaults] objectForKey:TS_DEFAULT_TAX_KEY] forKey:TSProjectTaxValue];

	[self newTabForProject:project];
}

#pragma mark -
#pragma mark Export

- (NSString *)exportCurrentProjectAsText
{
	NSMutableString *text = [NSMutableString string];
	
	TSProject *project = [self currentProject];
	NSEnumerator *projectDaysEnum = [[project periodDays] objectEnumerator];
	TSPeriodDay *day;
	while (day = [projectDaysEnum nextObject])
	{
		[text appendFormat:@"%@\n", [[[day start] dateWithCalendarFormat:nil timeZone:nil] descriptionWithCalendarFormat:@"%A, %B %e"]];
		
		NSEnumerator *periodsEnum = [[day periods] objectEnumerator];
		TSPeriod *period;
		while (period = [periodsEnum nextObject])
		{
			[text appendFormat:@"\t%@\tto %@\t%0.1f\t%@\n",
				[[[period start] dateWithCalendarFormat:nil timeZone:nil] descriptionWithCalendarFormat:@"%I:%M:%S %p"],
				[[[period end] dateWithCalendarFormat:nil timeZone:nil] descriptionWithCalendarFormat:@"%I:%M:%S %p"],
				//[NSString stringByFormattingSeconds3:[period totalSeconds]],
				[period totalSeconds]/60.0,
				([period notes] != nil && [[period notes] length] > 0 ? [NSString stringWithFormat:@"(%@)", [period notes]] : @"")
				];
		}
	}
	
	unsigned long long totalSeconds = [project totalSeconds];
	NSString *formattedSecs = [NSString stringByFormattingSeconds:totalSeconds
														   atRate:[[project valueForKey:TSProjectRateValue] floatValue]
														  withTax:[[project valueForKey:TSProjectTaxValue] floatValue]];
	[text appendFormat:@"\nTotal: %@ = %@", [NSString stringByFormattingSeconds3:totalSeconds], formattedSecs];

	return text;
}

- (void)exportText:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    [savePanel setNameFieldStringValue:[[self currentProject] valueForKey:TSProjectNameValue]];
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *projectText = [self exportCurrentProjectAsText];
            NSError *err = nil;
            [projectText writeToURL:[savePanel URL] atomically:YES encoding:NSUTF8StringEncoding error:&err];
            if (err)
                [NSApp presentError:err];
        }
    }];
}

#pragma mark -
#pragma mark Toolbar

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
		[item setLabel:@"New Project"];
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

#pragma mark -
#pragma mark TabView

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self updateStartStopButton];
	
	NSString *lastProjectName = [[[[tabViewItem identifier] content] project] valueForKey:TSProjectNameValue];
	[[NSUserDefaults standardUserDefaults] setObject:lastProjectName forKey:TS_LAST_PROJECT];
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self saveData]; // just to be sure
	NSAlert *closeAlert = [NSAlert alertWithMessageText:@"Are you sure you want to remove this project?"
										  defaultButton:@"Cancel"
										alternateButton:@"Remove"
											otherButton:nil
							  informativeTextWithFormat:@"Removing a project will delete all associated data and cannot be undone."];
	[closeAlert setAlertStyle:NSCriticalAlertStyle];
    if ([closeAlert runModal] == NSAlertAlternateReturn) {
        return YES;
    }
    return NO;
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
	// project was removed via the close tab. let's delete it from Core Data
	[[self dataController] deleteObject:[[[tabViewItem identifier] content] project]];
	
	[self saveData];
}

@end
