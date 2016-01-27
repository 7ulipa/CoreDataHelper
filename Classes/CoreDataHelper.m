//
//  CoreDataHelper.m
//  Pods
//
//  Created by 臧金晓 on 1/27/16.
//
//

#import "CoreDataHelper.h"
#import <CoreData/CoreData.h>

static id sharedInstance = nil;

@implementation CoreDataHelper

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (instancetype)initWithModelName:(NSString *)inModelName
{
    if (self = [self init]) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.momd", inModelName ?: @"CoreDataModels"]]];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self URLForStore] options:nil error:nil];
        _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
    }
    return self;
}

- (NSURL *)URLForStore
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"CoreData.sql"]];
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

+ (void)setSharedInstance:(CoreDataHelper *)instance
{
    sharedInstance = instance;
}

- (void)save
{
    [self save:nil];
}

- (void)save:(NSError *__autoreleasing *)err
{
    if (_managedObjectContext.hasChanges) {
        [_managedObjectContext save:err];
    }
}

@end
