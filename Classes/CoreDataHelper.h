//
//  CoreDataHelper.h
//  Pods
//
//  Created by 臧金晓 on 1/27/16.
//
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, copy) NSString *modelName;

+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(CoreDataHelper *)instance;

- (instancetype)initWithModelName:(NSString *)inModelName;

- (void)save;
- (void)save:(NSError **)err;

@end
