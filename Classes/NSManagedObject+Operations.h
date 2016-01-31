//
//  NSManagedObject+Operations.h
//  Pods
//
//  Created by 臧金晓 on 1/27/16.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Operations)

- (void)save;
- (void)delete;
+ (void)deleteAll;

+ (id)create;
+ (id)create:(NSDictionary *)attributes;
+ (id)create:(NSDictionary *)attributes search:(BOOL)search;
- (void)update:(NSDictionary *)attributes;
- (void)update:(NSDictionary *)attributes search:(BOOL)search;

+ (NSArray *)all;
+ (NSArray *)allWithOrder:(id)order;
+ (NSArray *)where:(id)condition, ...;
+ (NSArray *)where:(id)condition order:(id)order;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit;
+ (NSUInteger)count;
+ (NSUInteger)countWhere:(id)condition, ...;

+ (NSString *)entityName;

@end
