//
//  TSDataController.h
//  Timeous
//
//  Created by Kevin Wojniak on 12/8/07.
//  Copyright 2007 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSProject, TSPeriod;


@interface TSDataController : NSObject
{
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	
}

- (void)saveData;
- (NSArray *)loadData;

- (TSProject *)newProject;
- (TSPeriod *)newPeriod;

- (void)deleteObject:(id)object;

@end
