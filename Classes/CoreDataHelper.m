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
        _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
    }
    return self;
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
    
}

- (void)save:(NSError *__autoreleasing *)err
{
    
}

@end
