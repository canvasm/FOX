//
//  FSPGameOddsProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 3/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPGame;

@interface FSPGameOddsProcessingOperation : FSPProcessingOperation

- (id)initWithGameId:(NSManagedObjectID *)gameId oddsArray:(NSArray *)oddsArray
       context:(NSManagedObjectContext *)context;

@end
