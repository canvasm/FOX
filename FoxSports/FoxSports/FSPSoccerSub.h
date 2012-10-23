//
//  FSPSoccerSub.h
//  FoxSports
//
//  Created by Matthew Fay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPSoccerPlayer, FSPTeam, FSPGame, FSPSoccerGame;

@interface FSPSoccerSub : NSManagedObject

@property (nonatomic, retain) NSNumber * sequenceNumber;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) FSPTeam *soccerTeam;
@property (nonatomic, retain) FSPSoccerPlayer *inPlayer;
@property (nonatomic, retain) FSPSoccerPlayer *outPlayer;
@property (nonatomic, retain) FSPSoccerGame *homeGame;
@property (nonatomic, retain) FSPSoccerGame *awayGame;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
