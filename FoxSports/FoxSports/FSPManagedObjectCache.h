//
//  FSPManagedObjectCache.h
//  FoxSports
//
//  Created by greay on 8/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
*
* Usage notes:
*
* - This cache is primarily intended for fast lookups in cases where you'd otherwise need to execute a fetch request for each
*   of many, many lookups (e.g. linking relations between two large sets of entities.) In most cases, a fetch request is more
*   appropriate; use this class with care.
*
* - FSPManagedObjectCache listens for changes to the context, and the cache is updated on these notifications. As a result,
*   it's important to call -processPendingChanges on the context after adding or deleting objects, so that the cache doesn't
*   become stale.
*
*/

@interface FSPManagedObjectCache : NSObject

+ (id)cacheForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;
+ (id)cacheForEntityName:(NSString *)entityName primaryKey:(NSString *)primaryKey inContext:(NSManagedObjectContext *)context;
+ (id)cacheForEntityName:(NSString *)entityName primaryKey:(NSString *)primaryKey cacheSubentities:(BOOL)cacheSubentities inContext:(NSManagedObjectContext *)context;
- (id)lookupObjectByIdentifier:(NSString *)uniqueIdentifier;
- (NSArray *)allObjects;

@end
