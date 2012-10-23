//
//  FSPGolfStandingsProcessingOperation.h
//  FoxSports
//
//  Created by greay on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsProcessingOperation.h"

@interface FSPGolfStandingsProcessingOperation : FSPStandingsProcessingOperation
- (id)initWithStandings:(NSArray *)standings branch:(NSString *)aBranch context:(NSManagedObjectContext *)context;
@end
