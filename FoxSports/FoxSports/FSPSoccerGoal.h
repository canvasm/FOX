//
//  FSPSoccerGoal.h
//  FoxSports
//
//  Created by Matthew Fay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPSoccerGame, FSPSoccerPlayer, FSPTeam;

@interface FSPSoccerGoal : NSManagedObject

@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * sequenceNumber;
@property (nonatomic, retain) NSNumber * goalType;
@property (nonatomic, retain) NSString * fieldArea;
@property (nonatomic, retain) FSPSoccerPlayer *goalScorer;
@property (nonatomic, retain) FSPSoccerPlayer *assistPlayer;
@property (nonatomic, retain) FSPSoccerGame *homeGame;
@property (nonatomic, retain) FSPSoccerGame *awayGame;
@property (nonatomic, retain) FSPTeam *soccerTeam;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
