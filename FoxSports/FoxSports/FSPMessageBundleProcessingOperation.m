//
//  FSPMessageBundleProcessingOperation.m
//  FoxSports
//
//  Created by Jason Whitford on 4/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMessageBundleProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPRacingEvent.h"
#import "FSPPGAEvent.h"
#import "FSPGamePeriod.h"
#import "FSPGamePlayByPlayItem.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPPlayer.h"
#import "FSPBasketballPlayer.h"
#import "FSPCoreDataManager.h"

@interface FSPMessageBundleProcessingOperation()
- (FSPPlayer *)findPlayerWithID:(NSNumber *)playerID fromGame:(FSPGame *)game;
- (FSPPlayer *)findPlayerWithID:(NSNumber *)playerID fromEvent:(FSPEvent *)event;
- (void)gameProcessingWithGame:(FSPGame *)game context:(NSManagedObjectContext *)context;
- (void)eventProcessingWithEvent:(FSPEvent *)event context:(NSManagedObjectContext *)context;
@end

@implementation FSPMessageBundleProcessingOperation {
    NSDictionary *messageBundle;
    NSManagedObjectID *eventManagedObjectID;
}

- (id)initWithEventId:(NSManagedObjectID *)eventId messageBundle:(NSDictionary *)aMessageBundle
              context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context]) {
        messageBundle = [NSDictionary dictionaryWithDictionary:aMessageBundle];
        eventManagedObjectID = eventId;
    }
    
    return self;
}

- (void)main
{
    if (self.isCancelled) return;
    
    [self.managedObjectContext performBlockAndWait:^{
        FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventManagedObjectID error:nil];
        
        if (!event)
            return;
        
        if ([event isKindOfClass:[FSPGame class]]) {
            FSPGame *game = (FSPGame *)event;
            [self gameProcessingWithGame:game context:self.managedObjectContext];
        } else {
            [self eventProcessingWithEvent:event context:self.managedObjectContext];
        }
    }];
}

- (void)gameProcessingWithGame:(FSPGame *)game context:(NSManagedObjectContext *)context;
{
    //LINE SCORE
    NSArray *gameStates = [messageBundle objectForKey:@"GS"];
    if (gameStates) {
        
        NSDictionary *currentGameState = [gameStates lastObject];
        
        NSArray *lineScores = [currentGameState objectForKey:@"PERS"];
        if (lineScores)
        {
            game.periods = nil;
            
            NSMutableOrderedSet *newPeriodScores = [NSMutableOrderedSet orderedSet];
            
            NSUInteger count = [lineScores count];
            for (NSUInteger i = 0; i < count; i++) {
                NSDictionary *periodScore = [lineScores objectAtIndex:i];
                
                FSPGamePeriod *period = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGamePeriod" inManagedObjectContext:context];
                period.game = game;
                //TODO: change this when feeds get updated to correct types
                period.period = @(i+1);
                period.homeTeamScore = [periodScore objectForKey:@"H"];
                period.awayTeamScore = [periodScore objectForKey:@"A"];
                
                [newPeriodScores addObject:period];
            }
            game.periods = [NSOrderedSet orderedSetWithOrderedSet:newPeriodScores];
        }
        
        //update game segment info (time)
        [game populateSegmentInformationWithDictionary:currentGameState];
        
        if (!game.eventCompleted.boolValue) {
            NSDictionary *home = [currentGameState objectForKey:@"H"];
            NSDictionary *away = [currentGameState objectForKey:@"A"];
            //Total Score
            NSNumber *homeScore = [home fsp_objectForKey:@"TS" defaultValue:game.homeTeamScore];
            if (homeScore)
                game.homeTeamScore = homeScore;
            NSNumber *awayScore = [away fsp_objectForKey:@"TS" defaultValue:game.awayTeamScore];
            if (awayScore)
                game.awayTeamScore = awayScore;
            
            //Timeouts
            NSNumber *homeTimeouts = [home fsp_objectForKey:@"TR" defaultValue:game.homeTimeoutsRemaining];
            if (homeTimeouts)
                game.homeTimeoutsRemaining = homeTimeouts;
            NSNumber *awayTimeouts = [away fsp_objectForKey:@"TR" defaultValue:game.awayTimeoutsRemaining];
            if (awayTimeouts)
                game.awayTimeoutsRemaining = awayTimeouts;
        }
    }
    
    //Box Score
    NSArray *playersStats = [messageBundle objectForKey:@"PS"];
    if (playersStats) {
        for (NSDictionary *playerStat in playersStats) {
            NSNumber *playerID = [playerStat objectForKey:@"ID"];
            FSPPlayer *player = [self findPlayerWithID:playerID fromGame:game];
            if (player)
                [player updateStatsFromDictionary:playerStat withContext:context];
        }
    }
    
    //Team Stats
    NSArray *teamStats = [messageBundle objectForKey:@"TS"];
    if (teamStats) {
        for (NSDictionary *teamStat in teamStats) {
            NSNumber * teamID = [teamStat objectForKey:@"ID"];
            if (teamID && ([game.homeTeamLiveEngineID isEqualToNumber:teamID] || [game.awayTeamLiveEngineID isEqualToNumber:teamID])) {
                [game populateWithLiveTeamStatsDictionary:teamStat];
            }
        }
    }
    
    //PLAY BY PLAY
    NSArray *playByPlayArray = [messageBundle objectForKey:@"PP"];
    NSArray *gameEventArray = [messageBundle objectForKey:@"GE"];
    
#ifdef DEBUG0
    NSParameterAssert(playByPlayArray.count == gameEventArray.count);
    NSParameterAssert(playByPlayArray.count == gameStates.count);
#endif
    
    if (playByPlayArray) {
        

        NSMutableOrderedSet *currentPlays = [NSMutableOrderedSet orderedSetWithOrderedSet:game.playByPlayItems];
        
        NSUInteger playIndex = 0;
        for (playIndex = 0; playIndex < [playByPlayArray count]; playIndex++) {
            NSDictionary *playByPlayEvent = [playByPlayArray objectAtIndex:playIndex];
            
            NSNumber *sequenceNumber = [playByPlayEvent fsp_objectForKey:@"SN" defaultValue:@(FSPLiveEngineDefault)];
            NSNumber *correction = [playByPlayEvent fsp_objectForKey:@"C" defaultValue:@(NO)];
            NSNumber *deletion = [playByPlayEvent fsp_objectForKey:@"D" defaultValue:@(NO)];
            
            NSDictionary *gameEventDict = nil;
            NSDictionary *EL = [gameEventArray objectAtIndex:playIndex];
            NSArray *ELArray = [EL objectForKey:@"EL"];
            if ([ELArray count]) {
                gameEventDict = [ELArray objectAtIndex:0];
            }
            
            NSDictionary *gameStateDict = [gameStates objectAtIndex:gameStates.count == 1 ? 0 : playIndex];
            
            if (![sequenceNumber isEqualToNumber:@(FSPLiveEngineDefault)]) {
                
                FSPGamePlayByPlayItem *playByPlay = nil;
                for (FSPGamePlayByPlayItem *existingItem in currentPlays) {
                    // TODO: this could get slow, but not that slow
                    if ([existingItem.sequenceNumber isEqualToNumber:sequenceNumber])
                        playByPlay = existingItem;
                }

                if (!playByPlay) {
                    playByPlay = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGamePlayByPlayItem" inManagedObjectContext:context];
                    playByPlay.sequenceNumber = sequenceNumber;
                    [currentPlays addObject:playByPlay];
                    correction = @(YES);
                }
                
                //if we get a play that has the same SN as one we already have but the correct flag is not set, it will not be updated
                if (correction.boolValue) {
                    [playByPlay populateWithDictionary:playByPlayEvent withGame:game];
                }
                
                if (gameEventDict && ([game.branch isEqualToString:FSPMLBEventBranchType] || [game.branch isEqualToString:FSPSoccerEventBranchType]))
                    [playByPlay populateWithGameEventDictionary:gameEventDict inContext:context];
                
                if (gameStateDict && [game.branch isEqualToString:FSPNFLEventBranchType]) {
                    [playByPlay populateWithGameStateDictionary:gameStateDict];
                    
                    if (playIndex > 0) {
#ifdef DEBUG
                        NSParameterAssert(playIndex > 0);
#endif
                        FSPGamePlayByPlayItem *previousPBP = [currentPlays objectAtIndex:playIndex - 1];
                        if ([previousPBP.possessionIdentifier isEqualToNumber:playByPlay.possessionIdentifier]) {
                            playByPlay.adjustedPeriodValue = [previousPBP adjustedPeriod];
                        } else {
                            playByPlay.adjustedPeriodValue = @([previousPBP adjustedPeriod].intValue + 1);
                        }
                    } else {
                        playByPlay.adjustedPeriodValue = @1;
                    }
                }
                
                
                if (deletion.boolValue) {
                    // if this is a deletion then we need to look up the item for the sequence number, and remove that
                    for (FSPGamePlayByPlayItem *itemToDelete in currentPlays) {
                        if ([itemToDelete.sequenceNumber isEqualToNumber:sequenceNumber])
                            [currentPlays removeObject:itemToDelete];
                    }
                } // delete
            }
        }
        game.playByPlayItems = currentPlays;
    }
}

- (void)eventProcessingWithEvent:(FSPEvent *)event context:(NSManagedObjectContext *)context;
{
    NSArray *gameStateArray = [messageBundle objectForKey:@"GS"];
    if ([gameStateArray count]) {
        [event populateSegmentInformationWithDictionary:[gameStateArray lastObject]];
    }
    
    NSArray *playersStats = [messageBundle objectForKey:@"PS"];
    if ([playersStats count]) {
        for (NSDictionary *playerStat in playersStats) {
            NSNumber *playerID = [playerStat objectForKey:@"ID"];
            FSPPlayer *player = [self findPlayerWithID:playerID fromEvent:event];
            if (player) {
                [player updateStatsFromDictionary:playerStat withContext:context];
			}
        }
    }
}

- (FSPPlayer *)findPlayerWithID:(NSNumber *)playerID fromEvent:(FSPEvent *)event;
{
    FSPPlayer *foundPlayer;
    //Racing Players only for now
    if ([event isKindOfClass:[FSPRacingEvent class]]) {
        FSPRacingEvent *racingEvent = (FSPRacingEvent *)event;
        for (FSPPlayer *player in racingEvent.racers) {
            if ([player.liveEngineID isEqualToNumber:playerID]) {
                foundPlayer = player;
                break;
            }
        }
    } else if ([event isKindOfClass:[FSPPGAEvent class]]) {
        FSPPGAEvent *PGAEvent = (FSPPGAEvent *)event;
        for (FSPPlayer *player in PGAEvent.golfers) {
            if ([player.liveEngineID isEqualToNumber:playerID]) {
                foundPlayer = player;
                break;
            }
        }
    }
    return foundPlayer;
}

//TODO: find a faster way to do this
- (FSPPlayer *)findPlayerWithID:(NSNumber *)playerID fromGame:(FSPGame *)game;
{
    FSPPlayer *foundPlayer;
    for (FSPPlayer *player in game.homeTeamPlayers) {
        if ([player.liveEngineID isEqualToNumber:playerID]) {
            foundPlayer = player;
            break;
        }
    }
    if (!foundPlayer) {
        for (FSPPlayer *player in game.awayTeamPlayers) {
            if ([player.liveEngineID isEqualToNumber:playerID]) {
                foundPlayer = player;
                break;
            }
        }
    }
    return foundPlayer;
}
@end
