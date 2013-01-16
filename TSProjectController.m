//
//  TSProjectController.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSProjectController.h"
#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"
#import "ImageAndTextCell.h"
#import "TSDataController.h"
#import "NSStringXtras.h"
#import "TSUserDefaultKeys.h"


@interface NSDate (TSFormats)
- (NSString *)timeDescription;
- (NSString *)dateDescription;
@end
@implementation NSDate (TSFormats)
- (NSString *)timeDescription
{
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:kCFDateFormatterNoStyle];
	[dateFormatter setTimeStyle:kCFDateFormatterShortStyle];
	NSString *formattedString = [dateFormatter stringFromDate:self];
	[dateFormatter release];
	return formattedString;
	
	//return [[self dateWithCalendarFormat:nil timeZone:nil] descriptionWithCalendarFormat:@"%I:%M:%S %p"];
}

- (NSString *)dateDescription
{
	return [[self dateWithCalendarFormat:nil timeZone:nil] descriptionWithCalendarFormat:@"%A, %B %e"];
}
@end


@implementation TSProjectController

- (id)initWithProject:(TSProject *)project
{
	if (self = [super init])
	{
		[self setDataController:nil];
		[self setProject:project];
		
		_objectController = [[NSObjectController alloc] initWithContent:self];
		_icon = nil;
		
		[NSBundle loadNibNamed:@"ProjectView" owner:self];
	}
	
	return self;
}

- (void)dealloc
{
	[self setDataController:nil];

	[_project release];
	[_periodTimer release];
	
	[_objectController release];
	[_icon release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	NSTableColumn *tc = [periodsOutlineView tableColumnWithIdentifier:@"Start"];
	ImageAndTextCell *cell = [[[ImageAndTextCell alloc] init] autorelease];
	[cell setFont:[[tc dataCell] font]];
	[tc setDataCell:cell];
	
	[periodsOutlineView setAutosaveTableColumns:YES];
	[periodsOutlineView setAutosaveName:[[self project] valueForKey:TSProjectNameValue]];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TS_USE_HHMMSS_FORMAT] options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[periodsOutlineView reloadData];
}

- (void)setDataController:(TSDataController *)dataController
{
	_dataController = dataController;
}

- (TSDataController *)dataController
{
	return _dataController;
}

- (TSProject *)project
{
	return _project;
}

- (void)setProject:(TSProject *)project
{
	if (_project != project)
	{
		[_project release];
		_project = [project retain];
	}
}

- (NSOutlineView *)periodsOutlineView
{
	return periodsOutlineView;
}

- (void)setupGUI
{
	[periodsOutlineView reloadData];
	[self updateEarningsField];

	// expand last item..
	NSUInteger c = [[_project periodDays] count];
	if (c > 0)
		[periodsOutlineView expandItem:[[_project periodDays] objectAtIndex:c-1]];
}

- (NSView *)contentView
{
	return contentView;
}

- (NSOutlineView *)outlineView
{
	return periodsOutlineView;
}

- (int)objectCount
{
    return 0;//[[[self project] currentPeriod] totalSeconds];
}

- (void)setIcon:(NSImage *)icon
{
	if (_icon != icon)
	{
		[_icon release];
		_icon = [icon retain];
	}
}
- (NSImage *)icon
{
	return _icon;
}

- (NSObjectController *)controller
{
	return _objectController;
}

- (void)updateEarningsField
{
	if ([_project totalSeconds] == 0)
	{
		[earningsField setStringValue:[NSString stringByFormattingSeconds:[_project totalSeconds]]];
	}
	else
	{
		NSString *formattedSecs = [NSString stringByFormattingSeconds:[_project totalSeconds]
															   atRate:[[_project valueForKey:TSProjectRateValue] floatValue]
															  withTax:[[_project valueForKey:TSProjectTaxValue] floatValue]];
		[earningsField setStringValue:[NSString stringWithFormat:@"%@: %@",
									   [NSString stringByFormattingSeconds:[_project totalSeconds]], formattedSecs]];
	}
}

- (void)timerAction
{
	[[_project currentPeriod] setEnd:[NSDate date]];
	if ([periodsOutlineView editedRow] == -1)
		[periodsOutlineView reloadData];
	[self updateEarningsField];
}

- (void)startTimer
{
	_periodTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5
													 target:self
												   selector:@selector(timerAction)
												   userInfo:nil
													repeats:YES] retain];
	[self timerAction]; // call immediately
}

- (void)stopTimer
{
	[_periodTimer invalidate];
	[_periodTimer release];
	_periodTimer = nil;
	
	[[self dataController] saveData];
}

- (BOOL)timerIsActive
{
	return ((_periodTimer != nil) && ([_periodTimer isValid]));
}

#pragma mark -

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		return [[_project periodDays] count];
	return [(TSPeriodDay *)item numberOfItems];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item == nil)
		return [[_project periodDays] objectAtIndex:index];
	return [[(TSPeriodDay *)item periods] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return ([item isKindOfClass:[TSPeriodDay class]]);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSString *identifier = [tableColumn identifier];
	if ([identifier isEqualToString:@"Start"])
	{
		if ([item isKindOfClass:[TSPeriodDay class]])
			return [[(TSPeriodDay *)item start] dateDescription];
		return [[(TSPeriod *)item start] timeDescription];
	}
	else if ([identifier isEqualToString:@"End"])
	{
		if ([item isKindOfClass:[TSPeriod class]])
			return [[item end] timeDescription];
	}
	else if ([identifier isEqualToString:@"Time"])
	{
		NSString *s = nil;
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:TS_USE_HHMMSS_FORMAT])
			s = [NSString stringByFormattingSeconds2:[item totalSeconds]];
		else
			s = [NSString stringByFormattingSeconds:[item totalSeconds]];
		
		if ((TSPeriod *)item == [_project currentPeriod])
		{
			NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				[[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:13.0], NSFontAttributeName,
				nil];
			return [[[NSAttributedString alloc] initWithString:s attributes:attrs] autorelease];
		}
		else
			return s;
	}
	else if ([identifier isEqualToString:@"Notes"])
	{
		if ([item isKindOfClass:[TSPeriod class]])
			return [item notes];
	}
	
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSString *identifier = [tableColumn identifier];
	if ([identifier isEqualToString:@"Notes"])
	{
		[item setNotes:object];
		
		[[self dataController] saveData];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return (![item isKindOfClass:[TSPeriodDay class]]);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"Start"])
	{
		if ([item isKindOfClass:[TSPeriodDay class]])
			[cell setImage:[NSImage imageNamed:@"time"]];
		else
		{
			TSPeriod *per = (TSPeriod *)item;
			if (per == [_project currentPeriod])
				[cell setImage:[NSImage imageNamed:@"clock_red"]];
			else
				[cell setImage:[NSImage imageNamed:@"clock"]];
		}
	}
	else
		[cell setImage:nil];
}

@end
