//
//  TSDataController.m
//  Timeous
//
//  Created by Kevin Wojniak on 12/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TSDataController.h"
#import "TSProject.h"
#import "TSPeriod.h"


@interface TSDataController (PrivateMethods)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
@end


@implementation TSDataController

- (void)dealloc
{
	[_managedObjectContext release];
	_managedObjectContext = nil;
    [_persistentStoreCoordinator release];
	_persistentStoreCoordinator = nil;
    [_managedObjectModel release];
	_managedObjectModel = nil;

	[super dealloc];
}

- (NSEntityDescription *)projectEntity
{
	return [[[self managedObjectModel] entitiesByName] objectForKey:@"Project"];
}

- (NSEntityDescription *)periodEntity
{
	return [[[self managedObjectModel] entitiesByName] objectForKey:@"Period"];
}

- (TSProject *)newProject
{
	TSProject *project = [[TSProject alloc] initWithEntity:[self projectEntity]
							insertIntoManagedObjectContext:[self managedObjectContext]];
	return [project autorelease];
}

- (TSPeriod *)newPeriod
{
	TSPeriod *period = [[TSPeriod alloc] initWithEntity:[self periodEntity]
						 insertIntoManagedObjectContext:[self managedObjectContext]];
	return [period autorelease];
}

- (void)deleteObject:(id)object
{
	[[self managedObjectContext] deleteObject:object];
}

/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "CoreDataTest" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Timeous"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle and all of the 
 framework bundles.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Projects.xml"]];
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
	
    return _persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (void)saveData
{
	//NSLog(@"SAVE DATA"); return;
	
	NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error])
	{
		NSBeep();
		NSLog(@"Error while saving: %@", [error localizedDescription]);
    }

	/*NSMutableArray *projects = [NSMutableArray array];
	 
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
	 
	 [projects writeToFile:DATA_PATH atomically:YES];*/	
}

- (NSArray *)loadData
{
	NSFetchRequest *projectsFetch = [[[NSFetchRequest alloc] init] autorelease];
	[projectsFetch setEntity:[self projectEntity]];
	NSError *error = nil;
	NSArray *projects = [[self managedObjectContext] executeFetchRequest:projectsFetch error:&error];
	NSEnumerator *projectsEnum = [projects objectEnumerator];
	TSProject *proj = nil;
	NSMutableArray *projs = [NSMutableArray array];
	
	while (proj = [projectsEnum nextObject])
	{
		[projs addObject:proj];
	}
	
	if ([projs count])
		return projs;

	return nil;
}


@end
