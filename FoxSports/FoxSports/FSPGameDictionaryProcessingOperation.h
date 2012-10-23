//
//  FSPGameDictionaryProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 4/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPEvent;

@interface FSPGameDictionaryProcessingOperation : FSPProcessingOperation

- (id)initWithEventId:(NSManagedObjectID *)eventid gameDictionary:(NSDictionary *)gameDictionary
        context:(NSManagedObjectContext *)context;

@end
