//
//  FSPProcessingOperationQueue.m
//  FoxSports
//
//  Created by Ed McKenzie on 8/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPProcessingOperationQueue.h"
#import "FSPCoreDataManager.h"

@interface FSPProcessingOperationQueue ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@interface FSPProcessingOperationQueueSaveOperation : NSOperation

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSSet *callbacks;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context callbacks:(NSSet *)callbacks;

@end

@implementation FSPProcessingOperationQueue

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
                createChildContext:(BOOL)createChild {
    NSParameterAssert(context);
    if ((self = [super init])) {
        if (createChild) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _managedObjectContext.parentContext = context;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mergeChanges:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:context];
        } else {
            _managedObjectContext = context;
        }
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addSaveOperationWithCallback:(FSPProcessingOperationSaveCallback)callback {
    NSMutableSet *allCallbacks = [NSMutableSet set];
    if (callback) {
        [allCallbacks addObject:callback];
    }
    for (NSOperation *operation in self.operations) {
        if ([operation isKindOfClass:[FSPProcessingOperationQueueSaveOperation class]]) {
            [operation cancel];
            if ([operation isKindOfClass:FSPProcessingOperationQueueSaveOperation.class] && !operation.isExecuting) {
                FSPProcessingOperationQueueSaveOperation *fspOperation = (id)operation;
                [allCallbacks addObjectsFromArray:fspOperation.callbacks.allObjects];
            }
        }
    }
    [self addOperation:[[FSPProcessingOperationQueueSaveOperation alloc] initWithManagedObjectContext:self.managedObjectContext callbacks:allCallbacks]];
}

- (void)addSaveOperation {
    [self addSaveOperationWithCallback:nil];
}

- (void)mergeChanges:(NSNotification *)notification {
    if (notification.object != self.managedObjectContext) {
        [self addOperationWithBlock:^{
            [self.managedObjectContext performBlockAndWait:^{
                [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        }];
    }
}

@end

@implementation FSPProcessingOperationQueueSaveOperation

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context callbacks:(NSSet *)callbacks {
    if ((self = [super init])) {
        _managedObjectContext = context;
        _callbacks = callbacks;
    }
    return self;
}

- (void)main {
    if (!self.isCancelled) {
        [self.managedObjectContext performBlockAndWait:^{
            if (!self.isCancelled) {
#ifdef DEBUG_emckenzie
                NSLog(@"Saving context in %@", NSStringFromClass(self.class));
#endif
                NSError *error;
                if ([self.managedObjectContext save:&error]) {
                    [[FSPCoreDataManager sharedManager] synchronizeSavingWithCallback:^{
                        for (FSPProcessingOperationSaveCallback callback in _callbacks) {
                            callback(TRUE);
                        }
                    }];
                } else {
                    NSLog(@"error saving context: %@", error.description);
                    [[[FSPCoreDataManager sharedManager] GUIObjectContext] performBlock:^{
                        for (FSPProcessingOperationSaveCallback callback in _callbacks) {
                            callback(FALSE);
                        }
                    }];
                }
            }
        }];
    }
}

@end