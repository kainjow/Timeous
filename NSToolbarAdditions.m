//
//  NSToolbarAdditions.m
//  Timeous
//
//  Created by Kevin Wojniak on 6/24/07.
//  Copyright 2007 Kevin Wojniak. All rights reserved.
//

#import "NSToolbarAdditions.h"


@implementation NSToolbar (NSToolbarAdditions)

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
{
	NSEnumerator *e = [[self items] objectEnumerator];
	NSToolbarItem *item; while (item = [e nextObject])
		if ([[item itemIdentifier] isEqualToString:identifier])
			return item;
	return nil;
}

@end
