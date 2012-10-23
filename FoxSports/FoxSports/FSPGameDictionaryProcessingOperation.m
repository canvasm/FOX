//
//  FSPGameDictionaryProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 4/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDictionaryProcessingOperation.h"
#import "FSPOrganization.h"
#import "FSPEvent.h"
#import "FSPRacingEvent.h"
#import "FSPPGAEvent.h"
#import "FSPGame.h"
#import "FSPTeamPlayer.h"
#import "FSPPlayer.h"
#import "FSPBasketballPlayer.h"
#import "FSPBaseballPlayer.h"
#import "FSPSoccerPlayer.h"
#import "FSPHockeyPlayer.h"
#import "FSPGolfer.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPCoreDataManager.h"

@interface FSPGameDictionaryProcessingOperation ()

- (NSString *)playerEntityNameForEvent:(FSPEvent *)event;
- (FSPPlayer *)createPlayerFromDictionary:(NSDictionary *)playerDictionary withURL:(NSString *)playerURL withEntityName:(NSString *)playerEntityName withContext:(NSManagedObjectContext *)context;

@end

@implementation FSPGameDictionaryProcessingOperation {
    NSDictionary *gameDictionary;
    NSManagedObjectID *eventManagedObjectID;
}

- (id)initWithEventId:(NSManagedObjectID *)eventId gameDictionary:(NSDictionary *)aGameDictionary
              context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        gameDictionary = [aGameDictionary copy];
        eventManagedObjectID = eventId;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        // Get the event
        FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventManagedObjectID error:nil];
        if (!event)
            return;
        
        event.liveEngineIdentifier = [gameDictionary fsp_objectForKey:@"eventNativeID" expectedClass:NSNumber.class];
        event.seasonState = [gameDictionary fsp_objectForKey:@"seasonState" defaultValue:@""];
        event.season = [gameDictionary fsp_objectForKey:@"season" defaultValue:@0];
        event.eventYear = [gameDictionary fsp_objectForKey:@"gameYear" defaultValue:@0];
        event.eventTimeTBA = [gameDictionary fsp_objectForKey:@"gameTimeTba" defaultValue:@(NO)];
        event.minPollingInterval = [gameDictionary fsp_objectForKey:@"minPollingInterval" defaultValue:@180];
        event.liveDataURL = [gameDictionary fsp_objectForKey:@"liveDataURL" defaultValue:@""];
        event.playerBaseURL = [gameDictionary fsp_objectForKey:@"playerBaseURL" defaultValue:@""];
        
        NSString *playerEntityName = [self playerEntityNameForEvent:event];
        
        BOOL isGame = [event isKindOfClass:[FSPGame class]];
        BOOL isRace = [event isKindOfClass:[FSPRacingEvent class]];
        BOOL isGolf = [event isKindOfClass:[FSPPGAEvent class]];
        
        // Game specific events
        if (isGame) {
            FSPGame *game = (FSPGame *)event;
            
            NSDictionary *homeTeamDictionary = [gameDictionary objectForKey:@"homeTeam"];
            NSDictionary *awayTeamDictionary = [gameDictionary objectForKey:@"visitingTeam"];
            
            game.homeTeamLiveEngineID = [homeTeamDictionary fsp_objectForKey:@"nativeID" defaultValue:@0];
            game.awayTeamLiveEngineID = [awayTeamDictionary fsp_objectForKey:@"nativeID" defaultValue:@0];
            
            // setup the home players.
            NSArray *homePlayers = [homeTeamDictionary objectForKey:@"players"];
            NSArray *awayPlayers = [awayTeamDictionary objectForKey:@"players"];
            
            game.homeTeamPlayers = nil;
            game.awayTeamPlayers = nil;
            
            for (NSDictionary *player in homePlayers) {
                FSPPlayer *newHomePlayer = [self createPlayerFromDictionary:player withURL:game.playerBaseURL withEntityName:playerEntityName withContext:self.managedObjectContext];
                [game addHomeTeamPlayersObject:(FSPTeamPlayer *)newHomePlayer];
            }
            
            for (NSDictionary *player in awayPlayers) {
                FSPPlayer *newAwayPlayer = [self createPlayerFromDictionary:player withURL:game.playerBaseURL withEntityName:playerEntityName withContext:self.managedObjectContext];
                [game addAwayTeamPlayersObject:(FSPTeamPlayer *)newAwayPlayer];
            }
        } else if (isRace) {
            FSPRacingEvent *racingEvent = (FSPRacingEvent *)event;
            racingEvent.racers = nil;
            for (NSDictionary *racer in [gameDictionary objectForKey:@"players"]) {
                FSPPlayer *player = [self createPlayerFromDictionary:racer withURL:racingEvent.playerBaseURL withEntityName:playerEntityName withContext:self.managedObjectContext];
                [racingEvent addRacersObject:(FSPRacingPlayer *)player];
            }
        } else if (isGolf) {
            FSPPGAEvent *golfEvent = (FSPPGAEvent *)event;
            golfEvent.golfers = nil;
            for (NSDictionary *golferDict in [gameDictionary objectForKey:@"players"]) {
                FSPPlayer *player = [self createPlayerFromDictionary:golferDict withURL:golfEvent.playerBaseURL withEntityName:playerEntityName withContext:self.managedObjectContext];
                [golfEvent addGolfersObject:(FSPGolfer *)player];
            }
        }
        
        event.gameDictionaryCreated = @(YES);
    }];
}
    
- (FSPPlayer *)createPlayerFromDictionary:(NSDictionary *)playerDictionary withURL:(NSString *)playerURL withEntityName:(NSString *)playerEntityName withContext:(NSManagedObjectContext *)context;
{
    //TODO:fix so a lookup of existing players is made
    FSPPlayer *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:playerEntityName inManagedObjectContext:context];
    newPlayer.firstName = [playerDictionary fsp_objectForKey:@"playerFirstName" defaultValue:@""];
    newPlayer.lastName = [playerDictionary fsp_objectForKey:@"playerLastName" defaultValue:@""];
    newPlayer.uniqueIdentifier = [playerDictionary fsp_objectForKey:@"playerID" defaultValue:@""];
    newPlayer.liveEngineID = [playerDictionary fsp_objectForKey:@"playerNativeID" defaultValue:@0];
    
    // Create the photo
    NSString *rule;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        rule = @"iphone";
    } else {
        rule = @"ipad";
    }
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        rule = [rule stringByAppendingString:@"_r"];
    }
    
    newPlayer.photoURL = [NSString stringWithFormat:@"%@%@.jpg%@.jpg", playerURL, newPlayer.uniqueIdentifier, rule];
    
    if ([newPlayer isKindOfClass:[FSPTeamPlayer class]]) {
        NSString *playerPosition = [playerDictionary fsp_objectForKey:@"playerPosition" defaultValue:@""];
        [(FSPTeamPlayer *)newPlayer setPosition:playerPosition];
        
        NSNumber *starter = [playerDictionary fsp_objectForKey:@"playerStartStatus" defaultValue:@(NO)];
        [(FSPTeamPlayer *)newPlayer setStarter:starter];
        
        if ([newPlayer isKindOfClass:[FSPBaseballPlayer class]] && starter.boolValue) {
            [(FSPBaseballPlayer *)newPlayer setBattingOrder:[playerDictionary fsp_objectForKey:@"playerBattingOrder" defaultValue:@0]];
        }
    } else if ([newPlayer isKindOfClass:[FSPRacingPlayer class]]) {
        FSPRacingPlayer *racingPlayer = (FSPRacingPlayer *)newPlayer;
        racingPlayer.playerNumber = [playerDictionary fsp_objectForKey:@"playerNumber" defaultValue:@-1];
        racingPlayer.raceStartPosition = [playerDictionary fsp_objectForKey:@"racingStartPosition" defaultValue:@-1];
        racingPlayer.vehicleDescription = [playerDictionary fsp_objectForKey:@"racingVehicleDescription" defaultValue:@""];
    } else if ([newPlayer isKindOfClass:[FSPGolfer class]]) {
//        FSPGolfer *golfer = (FSPGolfer *)newPlayer;
    }
    
    return newPlayer;
}

- (NSString *)playerEntityNameForEvent:(FSPEvent *)event;
{
    static NSDictionary *lookupDict = nil;
    id key = [event baseBranch] ?: @"";
    
    if (!lookupDict) {
        // TODO: Find a less brittle way to handle this since any new team sport that gets chips in the feed will break unless we add something here for each
        // Fixed bug: https://ubermind.jira.com/browse/FSTOGOIOS-1035 - Crash occurs when you tap on a MLB or NHL chip -abrooks
        lookupDict = @{FSPNBAEventBranchType: @"FSPBasketballPlayer",
                      FSPNHLEventBranchType: @"FSPHockeyPlayer",
                      FSPMLBEventBranchType: @"FSPBaseballPlayer",
                      FSPNCAABasketballEventBranchType: @"FSPBasketballPlayer",
                      FSPNCAAWBasketballEventBranchType: @"FSPBasketballPlayer",
                      FSPNFLEventBranchType: @"FSPFootballPlayer",
					  FSPNCAAFootballEventBranchType: @"FSPFootballPlayer",
                      FSPSoccerEventBranchType: @"FSPSoccerPlayer",
                      FSPNASCAREventBranchType: @"FSPRacingPlayer",
                      @"GOLF" : @"FSPGolfer"};
    }
    return [lookupDict fsp_objectForKey:key defaultValue:@"FSPPlayer"];
}

@end
