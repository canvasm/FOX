//
//  FSPManagedObjectCache.m
//  FoxSports
//
//  Created by greay on 8/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPManagedObjectCache.h"

@interface FSPManagedObjectCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) Class baseEntity;
@property (nonatomic, strong) NSString *primaryKey;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) NSNotificationCenter *center;
@property (nonatomic, assign) BOOL didFetchObjects;
@property (nonatomic, assign) BOOL cacheSubentities;

@end

@implementation FSPManagedObjectCache

+ (id)cacheForEntityName:(NSString *)entityName primaryKey:(NSString *)primaryKey cacheSubentities:(BOOL)cacheSubentities inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(primaryKey.length > 0);
    NSParameterAssert(entityName.length > 0);
    NSParameterAssert(context);

    return [[FSPManagedObjectCache alloc] initWithEntityName:entityName primaryKey:primaryKey cacheSubentities:cacheSubentities inContext:context];
}

+ (id)cacheForEntityName:(NSString *)entityName primaryKey:(NSString *)primaryKey inContext:(NSManagedObjectContext *)context {
    return [self cacheForEntityName:entityName primaryKey:primaryKey cacheSubentities:YES inContext:context];
}

+ (id)cacheForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    return [self cacheForEntityName:entityName primaryKey:@"uniqueIdentifier" inContext:context];
}

- (id)initWithEntityName:(NSString *)entityName primaryKey:(NSString *)key cacheSubentities:(BOOL)cacheSubentities
               inContext:(NSManagedObjectContext *)context {
	self = [super init];
	if (self) {
		_baseEntity = NSClassFromString(entityName);
        if (!_baseEntity) {
            return nil;
        }
		_managedObjectContext = context;
        _primaryKey = key;
        _didFetchObjects = NO;
        _cacheSubentities = cacheSubentities;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)performInitialFetch {
    if (!_didFetchObjects) {
        [self.managedObjectContext performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self.baseEntity)];
            request.includesSubentities = _cacheSubentities;
            NSError *error = nil;
            NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (error) {
                FSPLogCoreData(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
                return;
            }

            self.cache = [NSMutableDictionary dictionaryWithCapacity:objects.count];
            for (NSManagedObject *obj in objects) {
                NSString *uid = [obj valueForKey:self.primaryKey];
                if (!uid) {
                    FSPLogCoreData(@"ERROR. object (entityName:%@) does not have a unique identifier!", NSStringFromClass(self.baseEntity));
                    return;
                }
                if ([self.cache valueForKey:uid]) {
                    FSPLogCoreData(@"+ERROR: duplicate FSIDs:%@", uid);
                }
                [self.cache setObject:[obj objectID] forKey:uid];
            }

            _didFetchObjects = YES;
        }];
    }
}

- (id)lookupObjectByIdentifier:(NSString *)uniqueIdentifier
{
    if (!_didFetchObjects) {
        [self performInitialFetch];
    }
	NSManagedObjectID *objID = [self.cache valueForKey:uniqueIdentifier];
	if (objID) {
        return [self.managedObjectContext existingObjectWithID:objID error:nil];
	} else {
		return nil;
	}
}

- (NSArray *)allObjects
{
    if (!_didFetchObjects) {
        [self performInitialFetch];
    }
	NSArray *allIDs = [self.cache allValues];
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[allIDs count]];
	for (NSManagedObjectID *objID in allIDs) {
        id obj = [self.managedObjectContext existingObjectWithID:objID error:nil];
        if (obj) {
            [array addObject:obj];
        }
	}
	return array;
}

#pragma mark - Change observing

- (void)contextDidChange:(NSNotification *)notification
{
    if (!_didFetchObjects)
        return;

	NSManagedObjectContext *context = [notification object];
	[context performBlockAndWait:^{
		for (NSManagedObject *obj in [context deletedObjects]) {
            BOOL matchingObjectType = (_cacheSubentities ?
                                       [[obj class] isSubclassOfClass:self.baseEntity] :
                                       [obj isMemberOfClass:self.baseEntity]);
			if (matchingObjectType) {
				NSString *uid = [obj valueForKey:self.primaryKey];
                if (uid) {
                    [self.cache removeObjectForKey:uid];
                }
			}
		}
		for (NSManagedObject *obj in [context insertedObjects]) {
            BOOL matchingObjectType = (_cacheSubentities ?
                                       [[obj class] isSubclassOfClass:self.baseEntity] :
                                       [obj isMemberOfClass:self.baseEntity]);
			if (matchingObjectType) {
				NSString *uid = [obj valueForKey:self.primaryKey];
                NSManagedObjectID *cachedObjectID = [self.cache valueForKey:uid];
				if (cachedObjectID && ![cachedObjectID isEqual:[obj objectID]]) {
					FSPLogCoreData(@"-ERROR: inserted %@ with duplicate primary key: %@=%@", NSStringFromClass(self.baseEntity), self.primaryKey, uid);
                    [context performBlock:^{
                        FSPLogCoreData(@"Deleting duplicate %@ with primary key %@=%@", NSStringFromClass(self.baseEntity), self.primaryKey, uid);
                        [context deleteObject:obj];
                        [context processPendingChanges];
                    }];
				} else if (obj && uid) {
                    [self.cache setObject:[obj objectID] forKey:uid];
                }
			}
		}
	}];
}

@end
