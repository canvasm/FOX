//
//  FSPProcessingOperationQueue.h
//  FoxSports
//
//  Created by Ed McKenzie on 8/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FSPProcessingOperationSaveCallback)(BOOL success);

@interface FSPProcessingOperationQueue : NSOperationQueue

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
                createChildContext:(BOOL)createChild;

// Add an operation to this queue that saves the context. If any saves are pending, they are canceled, so it's
// safe to call this often. Optionally, a callback can be invoked after the save completes.
- (void)addSaveOperation;
- (void)addSaveOperationWithCallback:(FSPProcessingOperationSaveCallback)callback;

@end
