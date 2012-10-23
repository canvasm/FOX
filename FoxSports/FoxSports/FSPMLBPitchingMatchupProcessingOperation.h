//
//  FSPMLBPitchingMatchupProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 6/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPEvent;

@interface FSPMLBPitchingMatchupProcessingOperation : FSPProcessingOperation

- (id)initWithEventId:(NSManagedObjectID *)eventId pitchers:(NSDictionary *)pitchers
        context:(NSManagedObjectContext *)context;

@end
