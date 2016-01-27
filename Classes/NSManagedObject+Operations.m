//
//  NSManagedObject+Operations.m
//  Pods
//
//  Created by 臧金晓 on 1/27/16.
//
//

#import "NSManagedObject+Operations.h"
#import "CoreDataHelper.h"

@implementation NSManagedObject (Operations)

- (void)save
{
    if (self.managedObjectContext.hasChanges) {
        [self.managedObjectContext save:nil];
    }
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
}

+ (void)deleteAll
{
    [[self all] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj delete];
    }];
}

+ (id)create
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:[CoreDataHelper sharedInstance].managedObjectContext];
}

+ (id)create:(NSDictionary *)attributes
{
    NSManagedObject *result = [self create];
    [result update:attributes];
    return result;
}

- (void)update:(NSDictionary *)attributes
{
    if ((id)attributes == [NSNull null] || self == nil) {
        return;
    }
    
    NSDictionary *normalAttributes = self.entity.attributesByName;
    NSDictionary *relationShips = self.entity.relationshipsByName;
    
    [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([normalAttributes objectForKey:key]) {
            [self willChangeValueForKey:key];
            [self setSafeValue:value forKey:key];
            [self didChangeValueForKey:key];
        } else if ([relationShips objectForKey:key]) {
            NSRelationshipDescription *relation = [relationShips objectForKey:key];
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [NSClassFromString(relation.destinationEntity.name) create:value];
            } else if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *newValue = [NSMutableArray arrayWithCapacity:[value count]];
                for (NSUInteger i = 0; i < [value count]; i ++) {
                    id object = value[i];
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        object = [NSClassFromString(relation.destinationEntity.name) create:object];
                    }
                    [newValue addObject:object];
                }
                value = newValue;
                
                if (relation.ordered) {
                    value = [[NSOrderedSet alloc] initWithArray:value];
                } else {
                    value = [NSSet setWithArray:value];
                }
            }
            
            [self setSafeValue:value forKey:key];
        }
    }];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key
{
    if (value == nil || value == [NSNull null]) {
        [self setNilValueForKey:key];
    } else {
        NSAttributeType attributeType = [self.entity.attributesByName[key] attributeType];
        if (attributeType == NSStringAttributeType && [value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        } else if ([value isKindOfClass:[NSString class]]) {
            switch (attributeType) {
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                    value = [NSNumber numberWithInteger:[value integerValue]];
                    break;
                case NSBooleanAttributeType:
                    value = [NSNumber numberWithBool:[value boolValue]];
                    break;
                case NSDoubleAttributeType:
                    value = [NSNumber numberWithDouble:[value doubleValue]];
                    break;
                case NSFloatAttributeType:
                    value = [NSNumber numberWithFloat:[value floatValue]];
                    break;
                default:
                    break;
            }
        }
        [self setValue:value forKey:key];
    }
}

+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    
    if (condition) {
        fetchRequest.predicate = [self processCondition:condition arguments:NULL];
    }
    
    if (order) {
        fetchRequest.sortDescriptors = [self processOrder:order];
    }
    
    if (limit) {
        fetchRequest.fetchLimit = [limit integerValue];
    }
    
    return [[CoreDataHelper sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

+ (NSArray *)where:(id)condition order:(id)order
{
    return [self where:condition order:order limit:nil];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit
{
    return [self where:condition order:nil limit:limit];
}

+ (NSArray *)where:(id)condition, ...
{
    va_list va_arguments;
    va_start(va_arguments, condition);
    NSPredicate *predicate = [self processCondition:condition arguments:va_arguments];
    va_end(va_arguments);
    return [self where:predicate order:nil limit:nil];
}

+ (NSArray *)all
{
    return [self where:nil];
}

+ (NSArray *)allWithOrder:(id)order
{
    return [self where:nil order:order limit:nil];
}

+ (NSUInteger)countWhere:(id)condition, ...
{
    va_list va_arguments;
    va_start(va_arguments, condition);
    NSPredicate *predicate = [self processCondition:condition arguments:va_arguments];
    va_end(va_arguments);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    request.predicate = predicate;
    
    return [[CoreDataHelper sharedInstance].managedObjectContext countForFetchRequest:request error:nil];
}

+ (NSUInteger)count
{
    return [self countWhere:nil];
}

#pragma mark - private

+ (NSArray *)processOrder:(id)order
{
    if ([order isKindOfClass:[NSString class]]) {
        order = [order componentsSeparatedByString:@","];
    }
    
    if ([order isKindOfClass:[NSArray class]]) {
        NSMutableArray *newValue = [NSMutableArray arrayWithCapacity:[order count]];
        [order enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [newValue addObject:[self sortDescriptorFromObject:obj]];
        }];
        return newValue;
    } else {
        return @[[self sortDescriptorFromObject:order]];
    }
}

+ (NSSortDescriptor *)sortDescriptorFromObject:(id)order {
    if ([order isKindOfClass:[NSSortDescriptor class]])
        return order;
    
    if ([order isKindOfClass:[NSString class]])
        return [self sortDescriptorFromString:order];
    
    if ([order isKindOfClass:[NSDictionary class]])
        return [self sortDescriptorFromDictionary:order];
    
    return nil;
}

+ (NSSortDescriptor *)sortDescriptorFromString:(NSString *)order {
    NSArray *components = [order componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *key = [components firstObject];
    NSString *value = [components count] > 1 ? components[1] : @"ASC";
    
    return [self sortDescriptorFromDictionary:@{key: value}];
}

+ (NSSortDescriptor *)sortDescriptorFromDictionary:(NSDictionary *)dict {
    BOOL isAscending = ![[dict.allValues.firstObject uppercaseString] isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:dict.allKeys.firstObject
                                         ascending:isAscending];
}

+ (NSPredicate *)processCondition:(id)condition arguments:(va_list)arguments
{
    if ([condition isKindOfClass:[NSPredicate class]]) {
        return condition;
    }
    
    if ([condition isKindOfClass:[NSString class]]) {
        if (arguments == NULL) {
            return [NSPredicate predicateWithFormat:condition];
        } else {
            return [NSPredicate predicateWithFormat:condition arguments:arguments];
        }
    }
    
    if ([condition isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:[[condition allKeys] count]];
        [condition enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, obj]];
        }];
        return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    }
    
    return nil;
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

@end
