//
//  NSDictionary+FSPExtensions.h
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FSPExtensions)

+ (id)fsp_dictionaryByRemovingInstancesOfNSNullFromDictionary:(NSDictionary *)dictionary;

- (id)objectForKey:(NSString *)key defaultObject:(id)defaultObject;

/**
 Checks the dictionary to see if it contains aKey.  If the value does not contain aKey
 the default value is returned.  
 
 If the object returned by aKey is [NSNull null] the defaultValue is also returned.
 
 defaultValue is also returned if its type is unrelated to the value found in the dictionary.
 */
- (id)fsp_objectForKey:(id)aKey defaultValue:(id<NSObject>)defaultValue;

/**
 Gets the object from the dictionary. If not found or the value isn't of the given type,
 a default value of the given type is returned.
 */
- (id)fsp_objectForKey:(id)aKey expectedClass:(Class)expectedClass;

/**
 Returns the value returned by block.  obj is the value of objectForKey: being
 invoked on the dictionary.
 */
- (id)fsp_objectForKey:(id)aKey mappedByBlock:(id (^)(id obj))block;

@end
