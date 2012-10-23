//
//  FSPProcessingOperation.m
//  FoxSports
//
//  Created by Ed McKenzie on 8/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPProcessingOperation.h"
#import "FSPCoreDataManager.h"

@implementation FSPProcessingOperation

- (id)init {
    return [self initWithContext:nil];
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    if ((self = [super init])) {
        _managedObjectContext = context;
    }
    return self;
}

@end
