//
//  TSEarnings.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSInfoController.h"
#import "TSProject.h"


@implementation TSInfoController

- (id)init
{
	if (self = [super initWithWindowNibName:@"ProjectInfo" owner:self])
	{
		_project = nil;		
	}
	
	return self;
}

- (void)dealloc
{
	[_project release];
	[super dealloc];
}

- (void)setProject:(TSProject *)project
{
	if (_project != project)
	{
		[_project release];
		_project = [project retain];
	}

	[nameField setStringValue:[_project valueForKey:TSProjectNameValue]];
	[rateField setFloatValue:[[_project valueForKey:TSProjectRateValue] floatValue]];
	[taxField setFloatValue:[[_project valueForKey:TSProjectTaxValue] floatValue]];
}

- (IBAction)close:(id)sender
{
	[_project setValue:[nameField stringValue] forKey:TSProjectNameValue];
	[_project setValue:[NSNumber numberWithFloat:[rateField floatValue]] forKey:TSProjectRateValue];
	[_project setValue:[NSNumber numberWithFloat:[taxField floatValue]] forKey:TSProjectTaxValue];
	[NSApp endSheet:[self window]];
	[self close];
}

@end
