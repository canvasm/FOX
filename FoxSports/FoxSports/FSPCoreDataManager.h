//
//  FSPCoreDataManager.h
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FSPCoreDataSynchronizedSaveCallback)(void);

/**
 * A shared manager to simplify the accessing of core data resources.
 */
@interface FSPCoreDataManager : NSObject


/**
 * The shared manager object.
 */
+ (FSPCoreDataManager *)sharedManager;

/** 
 Checks to see if the database file exists that backs the project.
 */
- (BOOL)databaseExists;

/**
 The URL for the persistent store.
 */
- (NSURL *)storeURL;

/**
 * Returns the managed object context for the application UI.
 *
 * This context is initialized with the NSMainQueueConcurrency policy
 * so it can be safely accessed from the main thread and background 
 * threads can use the block based API.
 *
 * FSPCoreDataManager listens for masterContext saves (see synchronizeSaving)
 * and merges them to this context; clients should treat this as a mostly
 * read-only context, and save any changes as soon as possible.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *GUIObjectContext;

/**
 * Returns the master context for the application.  This context 
 * is initialized as an NSPrivateQueueConcurrency type so it must
 * be accessed using the block based API.  This context is the parent
 * context of the GUIObjectContext.  It has no parent context itself.
 *
 * CoreData clients that wish to modify the database should create their
 * own contexts with this context as the parent. Changes are merged to the
 * GUI context on save.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *masterContext;

/**
 * Returns the persistentStoreCoordinator for the application.
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Save changes made in the master context. This triggers a notification that merges changes to
 * the GUI context, where they are reflected in the UI. FSPProcessingOperation automatically calls
 * this on completion so that changes show up in the interface.
 *
 * Note that the save may not happen immediately; saves are throttled to a rate of once per few
 * seconds for performance. The callback version of this method is provided for clients that need
 * to be sure the save has completed before proceeding.
 */
- (void)synchronizeSaving;
- (void)synchronizeSavingWithCallback:(FSPCoreDataSynchronizedSaveCallback)callback;

/**
 This method is just like calling synchronize but it blocks the current thread until it completes.
 
 This method should only be called in rare situations, like application termination.  This method
 calls perfomBlockAndWait: on the managed contexts.  If the application does something with the 
 contexts that needs to aquire a lock this method will deadlock.  For example, if the application
 issues a fetch request while this method is executing a deadlock will occur.
 */
- (void)synchronizeSavingAndWait;
@end
