//
//  FSPEventStreamabilityProcessingOperation.m
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventStreamabilityProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPCoreDataManager.h"

@interface FSPEventStreamabilityProcessingOperation ()
@property (nonatomic, copy) NSDictionary *streamabilityInfo;
@property (nonatomic, copy) NSArray *events;
@end

@implementation FSPEventStreamabilityProcessingOperation

@synthesize streamabilityInfo=_evenstreamabilityInfo;
@synthesize events=_events;

- (id)initWithStreamabilityInfo:(NSDictionary *)streamabilityInfo events:(NSArray *)events
                        context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context]) {
        self.streamabilityInfo = streamabilityInfo;
        self.events = events;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPEvent"];
        NSArray *eventIds = [self.events valueForKeyPath:FSPEventUniqueIdKey];
		if (eventIds) {
			fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier IN %@", eventIds];
			NSArray *existingEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
			for (FSPEvent *event in existingEvents) {
				NSDictionary *streamability = [self.streamabilityInfo objectForKey:event.uniqueIdentifier];
				event.streamable = [streamability objectForKey:FSPEventIsStreamableKey];
			}
		}
    }];
}

@end
