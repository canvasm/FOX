//
//  FSPCoreDataManager.m
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import "FSPCoreDataManager.h"
#import "NSURL+CommonDirectories.h"
#import "FSPTeam.h"
#import "FSPPollingCenter.h"
#import "FSPAppDelegate.h"
#import "FSPDataCoordinator.h"
#import "FSPSettingsBundleHelper.h"

@interface FSPCoreDataManager ()

@property (nonatomic, weak) id saveAction;
@property (nonatomic, strong) NSMutableDictionary *lastKnownDataSourceState;
@property (nonatomic, strong) NSTimer *databaseSaveTimer;
@property (nonatomic, assign) BOOL pendingSave;
@property (nonatomic, assign) BOOL isSaving;
@property (nonatomic, assign) dispatch_queue_t workQueue;
@property (nonatomic, strong) NSMutableSet *saveCallbacks;

@end

// Throttle database saves to the rate of once per this many seconds, max
static const NSTimeInterval FSPCoreDataManagerMinimumSaveInterval = 3.0;

@implementation FSPCoreDataManager
@synthesize GUIObjectContext = _GUIObjectContext;
@synthesize masterContext = _masterContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize saveAction = _saveAction;

static FSPCoreDataManager *sharedInstance = nil;

+ (FSPCoreDataManager *)sharedManager {
    @synchronized (FSPCoreDataManager.class) {
        if (!sharedInstance) {
            sharedInstance = [[FSPCoreDataManager alloc] init];
        }
        return sharedInstance;
    }
}

- (id)init {
    if ((self = [super init])) {
        _databaseSaveTimer = [NSTimer scheduledTimerWithTimeInterval:FSPCoreDataManagerMinimumSaveInterval
                                                              target:self
                                                            selector:@selector(internalSynchronizeSaving)
                                                            userInfo:nil
                                                             repeats:YES];
        _pendingSave = NO;
        _isSaving = NO;
        _workQueue = dispatch_queue_create("com.foxsports.CoreDataManager", DISPATCH_QUEUE_SERIAL);
        _saveCallbacks = NSMutableSet.set;
#ifdef DEBUG
        [self setupSettingsBundleWatcher];
#endif
    }
    return self;
}

- (void)dealloc;
{
    [_databaseSaveTimer invalidate];
    dispatch_release(_workQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utility methods
- (BOOL)databaseExists;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *URL = [self storeURL];
    
    return [fileManager fileExistsAtPath:[URL path]];
}

static NSString *FSPStoreNameDatabaseKey = @"FSPStoreName";
static NSString *FSPAbandonedStoresKey = @"FSPAbandonedStores";

#ifdef DEBUG

- (void)abandonDatabase {
    NSArray *abandonedStores = [[NSUserDefaults standardUserDefaults] valueForKey:FSPAbandonedStoresKey];
    if (!abandonedStores) {
        abandonedStores = @[];
    }
    abandonedStores = [abandonedStores arrayByAddingObject:self.storeURL.absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"FoxSports-%08lx.sqlite", clock()]
                                              forKey:FSPStoreNameDatabaseKey];
    [[NSUserDefaults standardUserDefaults] setObject:abandonedStores
                                              forKey:FSPAbandonedStoresKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#endif

- (NSURL *)storeURL;
{
    NSString *storeName = [[NSUserDefaults standardUserDefaults] valueForKey:FSPStoreNameDatabaseKey];
    if (storeName) {
        return [[NSURL fsp_applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
    } else {
        return [[NSURL fsp_applicationDocumentsDirectory] URLByAppendingPathComponent:@"FoxSports.sqlite"];
    }
}

#pragma mark - Contexts

- (NSManagedObjectContext *)GUIObjectContext {
    @synchronized (self) {
        if (!_GUIObjectContext) {
            NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
            NSManagedObjectContext *masterMOC = self.masterContext;

            _GUIObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _GUIObjectContext.persistentStoreCoordinator = psc;
            _GUIObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

            FSPLogCoreData(@"GUIObjectContext is %p", _GUIObjectContext);

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidFinishSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:masterMOC];
        }
        return _GUIObjectContext;
    }
}

- (NSManagedObjectContext *)masterContext {
    @synchronized (self) {
        if (!_masterContext) {
            NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;

            if (psc) {
                _masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                _masterContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
                _masterContext.persistentStoreCoordinator = psc;
            } else {
                FSPLogCoreData(@"no coordinator available! can't go on :(");
                abort();
            }

            FSPLogCoreData(@"masterContext is %p", _masterContext);
        }
        return _masterContext;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized (self) {
        if (!_persistentStoreCoordinator) {
            NSURL *storeURL = [self storeURL];

            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FoxSports" withExtension:@"momd"];
            NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

            NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)};

            NSError *error = nil;

            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
            {
                FSPLogCoreData(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        return _persistentStoreCoordinator;
    }
}

- (void)internalSynchronizeSaving {
    dispatch_async(_workQueue, ^{
        if (_pendingSave && !_isSaving) {
            _isSaving = YES;
            FSPLogCoreData(@" *** *** Entering synchronize *** *** ");
            
            NSManagedObjectContext *GUIMOC = self.GUIObjectContext;
            [GUIMOC performBlock:^{
                [GUIMOC processPendingChanges];
                
                FSPLogCoreData(@"Saving objects changed on GUI context");
                NSError *error;
                if (![GUIMOC save:&error]) {
                    FSPLogCoreData(@"Unable to save GUI context: ERROR %@", [error localizedDescription]);
                }
                FSPLogCoreData(@"GUI context synchronous save complete");
                
            }];
            
            NSManagedObjectContext *masterMOC = self.masterContext;
            [masterMOC performBlock:^{
                [masterMOC processPendingChanges];
                
                // Check if we have changes.
                if ([masterMOC hasChanges]) {
                    FSPLogCoreData(@"Perfoming asynchronous save on master Context");
                    NSError *masterError;
                    if (![masterMOC save:&masterError]) {
                        FSPLogCoreData(@"Unable to save master context: ERROR %@", [masterError localizedDescription]);
                        FSPLogCoreData(@"(userInfo was %@)", [masterError userInfo]);
                    }
                    FSPLogCoreData(@"master context asynchronous save complete");
                } else {
                    FSPLogCoreData(@"master context has no changes... Skipping save");
                }
            }];
            
            [GUIMOC performBlock:^{
                FSPLogCoreData(@"trampoline: gui");
                [masterMOC performBlock:^{
                    FSPLogCoreData(@"trampoline: master");
                    dispatch_async(_workQueue, ^{
                        FSPLogCoreData(@" *** done synchronizing *** ");
                        _pendingSave = NO;
                        _isSaving = NO;
                        [self invokeSaveCallbacks];
                    });
                }];
            }];
        }
    });
}

- (void)synchronizeSaving {
    [self synchronizeSavingWithCallback:nil];
}

- (void)synchronizeSavingWithCallback:(FSPCoreDataSynchronizedSaveCallback)callback {
    dispatch_async(_workQueue, ^{
        _pendingSave = YES;
        if (callback) {
            [_saveCallbacks addObject:callback];
        }
    });
}

- (void)invokeSaveCallbacks {
    for (FSPCoreDataSynchronizedSaveCallback callback in _saveCallbacks) {
        callback();
    }
    [_saveCallbacks removeAllObjects];
}

- (void)synchronizeSavingAndWait;
{
    dispatch_async(_workQueue, ^{
        FSPLogCoreData(@"Entering synchronizeSavingAndWait");
        
        if (_pendingSave) {
            // If we're currently waiting for synchronizeSaving to complete, it's not safe to proceed;
            // the app will likely deadlock on resume. TODO: figure out how to do this safely
            return;
        }

        NSManagedObjectContext *GUIMOC = self.GUIObjectContext;
        [GUIMOC performBlockAndWait:^{
            if ([GUIMOC hasChanges]) {
                FSPLogCoreData(@"Saving objects changed on GUI context");
                NSError *error;
                if (![GUIMOC save:&error]) {
                    FSPLogCoreData(@"Unable to save GUI context: ERROR %@", [error localizedDescription]);
                }
                FSPLogCoreData(@"GUI context synchronous save complete");
            }
        }];
        
        NSManagedObjectContext *masterMOC = self.masterContext;
        [masterMOC performBlockAndWait:^{
            
            if ([masterMOC hasChanges]) {
                FSPLogCoreData(@"Perfoming synchronous save on master Context");
                NSError *masterError;
                if (![masterMOC save:&masterError]) {
                    FSPLogCoreData(@"Unable to save master context: ERROR %@", [masterError localizedDescription]);
                }
                FSPLogCoreData(@"master context synchronous save complete");
            } else {
                FSPLogCoreData(@"master context has no changes... Skipping save");
            }
            
        }];

        [self invokeSaveCallbacks];

        FSPLogCoreData(@"Exiting synchronizeSavingAndWait");
    });
}

- (void)contextDidFinishSave:(NSNotification *)notification {
    NSManagedObjectContext *masterMOC = self.masterContext;
    NSManagedObjectContext *GUIMOC = self.GUIObjectContext;
    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    if (notification.object == masterMOC) {
        dispatch_async(_workQueue, ^{
            [GUIMOC performBlock:^{
                if (psc == [[notification object] persistentStoreCoordinator]) {
                    [psc lock];
                    [GUIMOC processPendingChanges];
                    [GUIMOC mergeChangesFromContextDidSaveNotification:notification];
                    [psc unlock];
                    FSPLogCoreData(@"GUI context %p updated from context %p: %d objects inserted, %d deleted, %d updated",
                                   GUIMOC, notification.object,
                                   [(NSSet *)[notification.userInfo objectForKey:NSInsertedObjectsKey] count],
                                   [(NSSet *)[notification.userInfo objectForKey:NSDeletedObjectsKey] count],
                                   [(NSSet *)[notification.userInfo objectForKey:NSUpdatedObjectsKey] count]);
                }
            }];
        });
    }
}

#pragma mark - settings bundle watcher

#ifdef DEBUG
- (void)setupSettingsBundleWatcher {
    // Get the current values of environment keys that trigger a reset
    _lastKnownDataSourceState = NSMutableDictionary.new;
    for (NSString *key in [self keysTriggeringReload]) {
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (value) {
            [_lastKnownDataSourceState setObject:value
                                          forKey:key];
        } else {
            [_lastKnownDataSourceState setObject:@"" forKey:key];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsBundleDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    // Delete databases abandoned in the previous run of the app
    NSArray *previouslyAbandonedStores = [[NSUserDefaults standardUserDefaults] valueForKey:FSPAbandonedStoresKey];
    if (previouslyAbandonedStores) {
        for (NSString *abandonedStorePath in previouslyAbandonedStores) {
            NSError *error;
            NSLog(@"Removing abandoned database: %@", abandonedStorePath);
            if (![[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:abandonedStorePath]
                                                           error:&error]) {
                FSPLogCoreData(@"Failed to delete abandoned data store. Error was %@", [error description]);
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FSPAbandonedStoresKey];
}

- (NSArray *)keysTriggeringReload {
    return @[FSPSettingsBundleAppEnvironmentKey];
}

- (void)settingsBundleDidChange:(NSNotification *)notification {
    @synchronized (FSPCoreDataManager.class) {
        BOOL keysChanged = NO;
        for (NSString *key in [self keysTriggeringReload]) {
            NSString *oldValue = [self.lastKnownDataSourceState valueForKey:key];
            NSString *newValue = [[NSUserDefaults standardUserDefaults] valueForKey:key];
            if (newValue && oldValue && ![newValue isEqualToString:oldValue]) {
                keysChanged = YES;
                FSPLogCoreData(@"Key %@ changed: \"%@\" -> \"%@\"", key, oldValue, newValue);
                if (newValue) {
                    [self.lastKnownDataSourceState setValue:newValue forKey:key];
                }
            }
        }
        if (keysChanged) {
            FSPLogCoreData(@"Reloading environment");
            [self.lastKnownDataSourceState removeAllObjects];
            [self abandonDatabase];

            // Reset the FSPCoreDataManager singleton.
            sharedInstance = nil;

            [FSPDataCoordinator resetCoordinator];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FSPAppDidResetEnvironmentConfigurationNotification
                                                                object:nil];
        }
    }
}
#endif

@end
     
