//
//  FSPProcessingOperation.h
//  FoxSports
//
//  Created by Ed McKenzie on 8/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPProcessingOperation : NSOperation

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

// Designated initializer.
- (id)initWithContext:(NSManagedObjectContext *)context;

@end
