//
//  FSPTennisPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPPlayer.h"

@class FSPTennisSeasonStats;

@interface FSPTennisPlayer : FSPPlayer

@property (nonatomic, retain) NSSet *seasons;
@end

@interface FSPTennisPlayer (CoreDataGeneratedAccessors)

- (void)addSeasonsObject:(FSPTennisSeasonStats *)value;
- (void)removeSeasonsObject:(FSPTennisSeasonStats *)value;
- (void)addSeasons:(NSSet *)values;
- (void)removeSeasons:(NSSet *)values;

@end
