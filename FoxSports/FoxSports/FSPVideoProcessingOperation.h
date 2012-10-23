//
//  FSPVideoProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 4/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPVideoProcessingOperation : FSPProcessingOperation

- (id)initWithVideos:(NSDictionary *)videos forOrgIDs:(NSArray *)orgIds
       context:(NSManagedObjectContext *)context;

- (id)initWithVideos:(NSDictionary *)videos forEventID:(NSManagedObjectID *)eventId
       context:(NSManagedObjectContext *)context;

@end
