//
//  FSPRacingStandingsProcessingOperation.h
//  FoxSports
//
//  Created by greay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsProcessingOperation.h"

@interface FSPRacingStandingsProcessingOperation : FSPStandingsProcessingOperation

- (id)initWithStandings:(NSArray *)standings branch:(NSString *)aBranch
                context:(NSManagedObjectContext *)context;

@end
