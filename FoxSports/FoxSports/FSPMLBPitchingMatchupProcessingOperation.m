//
//  FSPMLBPitchingMatchupProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 6/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPitchingMatchupProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPBaseballGame.h"
#import "FSPBaseballPlayer.h"
#import "FSPCoreDataManager.h"
#import "NSDictionary+FSPExtensions.h"

@interface FSPMLBPitchingMatchupProcessingOperation()

- (void)updateBaseballGame:(FSPBaseballGame *)game withPitcher:(NSDictionary *)pitcher withContext:(NSManagedObjectContext *)context;

@end

@implementation FSPMLBPitchingMatchupProcessingOperation {
    NSDictionary *pitchers;
    NSManagedObjectID *eventManagedObjectID;
}

- (id)initWithEventId:(NSManagedObjectID *)eventId pitchers:(NSDictionary *)pitchersDictionary
              context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context])
    {
        pitchers = [pitchersDictionary copy];
        eventManagedObjectID = eventId;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventManagedObjectID error:nil];
        
        if (!event || ![event isKindOfClass:[FSPBaseballGame class]])
            return;
        
        if (pitchers) {
            FSPBaseballGame * baseballGame = (FSPBaseballGame *)event;
            
            //TODO: validate pitchers dictionary
            NSDictionary * pitcher;
            pitcher = [pitchers objectForKey:@"pitcher1"];
            [self updateBaseballGame:baseballGame withPitcher:pitcher withContext:self.managedObjectContext];
            
            pitcher = [pitchers objectForKey:@"pitcher2"];
            [self updateBaseballGame:baseballGame withPitcher:pitcher withContext:self.managedObjectContext];
        }
    }];
}

- (void)updateBaseballGame:(FSPBaseballGame *)game withPitcher:(NSDictionary *)pitcher withContext:(NSManagedObjectContext *)context;
{
    if ([pitcher objectForKey:@"teamFsId"]) {
        FSPBaseballPlayer *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"FSPBaseballPlayer" inManagedObjectContext:context];
        
        //TODO: need to have the feed never give us a null for team Ids
        newPlayer.uniqueIdentifier = [pitcher fsp_objectForKey:@"teamFsId" defaultValue:@"FAKE"];
        newPlayer.wins = [pitcher fsp_objectForKey:@"wins" defaultValue:@(-1)];
        newPlayer.losses = [pitcher fsp_objectForKey:@"losses" defaultValue:@(-1)];
        newPlayer.seasonERA = [pitcher fsp_objectForKey:@"era" defaultValue:@(-1)];
        newPlayer.seasonWHIP = [pitcher fsp_objectForKey:@"whip" defaultValue:@(-1)];
        newPlayer.firstName = [pitcher fsp_objectForKey:@"firstName" defaultValue:@"--"];
        newPlayer.lastName = [pitcher fsp_objectForKey:@"lastName" defaultValue:@"--"];
        newPlayer.photoURL = (NSString *)[pitcher objectForKey:@"photoUrl"];
        
        if ([game.homeTeamIdentifier isEqualToString:[pitcher objectForKey:@"teamFsId"]]) {
            game.homeTeamStartingPitcher = nil;
            newPlayer.homeBaseballGame = game;
            newPlayer.homeGame = game;
            game.homeTeamStartingPitcher = newPlayer;
            
        } else if ([game.awayTeamIdentifier isEqualToString:[pitcher objectForKey:@"teamFsId"]]) {
            game.awayTeamStartingPitcher = nil;
            newPlayer.awayBaseballGame = game;
            newPlayer.awayGame = game;
            game.awayTeamStartingPitcher = newPlayer;
        }
    }
}

@end
