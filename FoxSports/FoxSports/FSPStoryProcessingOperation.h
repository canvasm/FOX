//
//  FSPStoryProcessingOperation.h
//  FoxSports
//
//  Created by Laura Savino on 3/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPStory.h"
#import "FSPProcessingOperation.h"

@class FSPEvent;

/**
 * Processes details associated with an event's story.
 */

@interface FSPStoryProcessingOperation : FSPProcessingOperation

- (id)initWithEventId:(NSManagedObjectID *)eventId storyDictionary:(NSDictionary *)storyDictionary storyType:(FSPStoryType)storyType context:(NSManagedObjectContext *)context;

@end
