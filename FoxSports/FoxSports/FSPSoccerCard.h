//
//  FSPSoccerCard.h
//  FoxSports
//
//  Created by Matthew Fay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPSoccerGame, FSPSoccerPlayer, FSPTeam;

extern NSString * const FSPYellowCard;
extern NSString * const FSPRedCard;

@interface FSPSoccerCard : NSManagedObject

@property (nonatomic, retain) NSNumber * sequenceNumber;
@property (nonatomic, retain) NSString * cardType;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) FSPTeam *soccerTeam;
@property (nonatomic, retain) FSPSoccerPlayer *player;
@property (nonatomic, retain) FSPSoccerGame *homeGame;
@property (nonatomic, retain) FSPSoccerGame *awayGame;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
