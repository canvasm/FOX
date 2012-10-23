//
//  NSDictionary+FSPExtensions.m
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "NSDictionary+FSPExtensions.h"

@implementation NSDictionary (FSPExtensions)

+ (id)fsp_dictionaryByRemovingInstancesOfNSNullFromDictionary:(NSDictionary *)dictionary;
{
    NSSet *keys = [dictionary keysOfEntriesPassingTest:^BOOL(id key, id val, BOOL *stop) {
        if ((NSNull *)val == [NSNull null])
            return YES;
        else
            return NO;
    }];
    
    // If there are no instances just return the same dictionary
    if ([keys count] == 0)
        return dictionary;
    
    NSMutableDictionary *mutableCopy = [dictionary mutableCopy];
    [mutableCopy removeObjectsForKeys:[keys allObjects]];
    
    return [NSDictionary dictionaryWithDictionary:mutableCopy];
}

- (id)objectForKey:(NSString *)key defaultObject:(id)defaultObject;
{
    id value;
    
    value = [self objectForKey:key];
    if (value)
        return value;
    return defaultObject;
}

- (NSSet *)jsonTypes {
    static NSSet *jsonTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsonTypes = [NSSet setWithObjects:NSString.class, NSDictionary.class, NSArray.class, NSNumber.class, nil];
    });
    return jsonTypes;
}

- (NSString *)prettyPrintClass:(Class)theClass {
    for (Class jsonType in self.jsonTypes) {
        if ([theClass isSubclassOfClass:jsonType]) {
            return NSStringFromClass(jsonType);
        }
    }
    return NSStringFromClass(theClass);
}

#ifdef DEBUG
- (void)fsp_validationFailedForKey:(NSString *)key expectedType:(NSString *)expectedType actualType:(NSString *)actualType;
{
#if 0
    static NSMutableSet *validationStackTracesSeen = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        validationStackTracesSeen = NSMutableSet.new;
    });
    NSArray *callStack = NSThread.callStackSymbols;
    NSString *thisEventDescription = [callStack componentsJoinedByString:@"\n"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![validationStackTracesSeen containsObject:thisEventDescription]) {
            NSLog(@"validation failed for key %@. expected %@; got %@.", key, expectedType, actualType);
            NSLog(@"abbreviated stack trace: ");
            BOOL systemSymbol = NO;
            for (NSString *frame in callStack) {
                NSRange fspOffset = [frame rangeOfString:@"-[FSP"];
                if (fspOffset.location == NSNotFound) {
                    if (!systemSymbol) {
                        NSLog(@"   ...");
                        systemSymbol = YES;
                    }
                } else if (systemSymbol) {
                    systemSymbol = NO;
                }
                if (!systemSymbol) {
                    NSLog(@"   %@", frame);
                }
            }
            [validationStackTracesSeen addObject:thisEventDescription];
        }
    });
#endif
}
#endif

- (BOOL)fsp_validateValue:(id<NSObject>)value keyNamed:(NSString *)key withDefaultValue:(id<NSObject>)defaultValue {
    for (Class jsonType in self.jsonTypes) {
        if ([defaultValue isKindOfClass:jsonType] && [value isKindOfClass:jsonType]) {
            return TRUE;
        }
    }
#ifdef DEBUG
    [self fsp_validationFailedForKey:key expectedType:[self prettyPrintClass:defaultValue.class] actualType:[self prettyPrintClass:value.class]];
#endif
    return FALSE;
}

- (BOOL)fsp_validateValue:(id<NSObject>)value keyNamed:(NSString *)key withExpectedClass:(Class)expectedClass {
    if ([value isKindOfClass:expectedClass]) {
        return TRUE;
    }
#ifdef DEBUG
    [self fsp_validationFailedForKey:key expectedType:[self prettyPrintClass:expectedClass] actualType:[self prettyPrintClass:value.class]];
#endif
    return FALSE;
}

- (id)defaultValueForClass:(Class)expectedClass {
    if (expectedClass == NSString.class) {
        return @"";
    } else if (expectedClass == NSArray.class) {
        return NSArray.new;
    } else if (expectedClass == NSDictionary.class) {
        return NSDictionary.new;
    } else if (expectedClass == NSNumber.class) {
        return @-1;
    } else {
        // TODO: error handling
        return nil;
    }
}

- (id)fsp_objectForKey:(id)aKey expectedClass:(Class)expectedClass {
     return [self fsp_objectForKey:aKey defaultValue:[self defaultValueForClass:expectedClass]];
}

- (id)fsp_objectForKey:(id)aKey defaultValue:(id<NSObject>)defaultValue;
{
    NSParameterAssert(defaultValue);
    NSParameterAssert(aKey);
    Class expectedClass = [defaultValue class];
    id returnedObject = [self objectForKey:aKey];
    if ((returnedObject == nil) || (returnedObject == [NSNull null]) ||
        ![self fsp_validateValue:returnedObject keyNamed:aKey withDefaultValue:defaultValue]) {
        if ([returnedObject isKindOfClass:NSString.class] && [expectedClass isSubclassOfClass:NSNumber.class]) {
			static NSNumberFormatter *formatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
            });
			returnedObject = [formatter numberFromString:returnedObject];
		} else if ([returnedObject isKindOfClass:NSNumber.class] && [expectedClass isSubclassOfClass:NSString.class]) {
			returnedObject = [returnedObject stringValue];
		} else {
			returnedObject = defaultValue;
		}
    }
    return returnedObject;
}

- (id)fsp_objectForKey:(id)aKey mappedByBlock:(id (^)(id obj))block;
{
    id obj = [self objectForKey:aKey];
    if (block)
        obj = block(obj);
    
    return obj;
}

@end
