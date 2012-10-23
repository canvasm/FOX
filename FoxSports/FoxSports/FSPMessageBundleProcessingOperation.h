//
//  FSPMessageBundleProcessingOperation.h
//  FoxSports
//
//  Created by Jason Whitford on 4/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPEvent;

@interface FSPMessageBundleProcessingOperation : FSPProcessingOperation
- (id)initWithEventId:(NSManagedObjectID *)eventId messageBundle:(NSDictionary *)aMessageBundle
        context:(NSManagedObjectContext *)context;
@end
