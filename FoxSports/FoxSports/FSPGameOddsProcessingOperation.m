//
//  FSPGameOddsProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 3/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameOddsProcessingOperation.h"
#import "FSPGame.h"
#import "FSPGameOdds.h"
#import "FSPGameOddsValidator.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPLogging.h"
#import "FSPCoreDataManager.h"

NSString * const FSPOddsMoneyLineKey = @"moneyLine";
NSString * const FSPOddsPointSpreadKey = @"pointSpread";
NSString * const FSPOddsPSMoneyLineKey = @"psMoneyLine";

@interface FSPGameOddsProcessingOperation ()
@property (nonatomic, copy) NSArray *oddsArray;
@property (nonatomic, copy) NSString *gameIdentifier;
@property (nonatomic, strong) NSManagedObjectID *gameMOID;

@end

@implementation FSPGameOddsProcessingOperation
@synthesize oddsArray = _oddsArray;
@synthesize gameIdentifier = _gameIdentifier;
@synthesize gameMOID = _gameMOID;

- (id)initWithGameId:(NSManagedObjectID *)gameID oddsArray:(NSArray *)oddsArray context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.oddsArray = oddsArray;
        self.gameMOID = gameID;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        self.managedObjectContext.undoManager = nil;
        
        // get the event
        
        FSPGame *game = (id)[self.managedObjectContext existingObjectWithID:self.gameMOID error:nil];
        
        if (!game)
            return;
        
        FSPGameOddsValidator *validator = [[FSPGameOddsValidator alloc] init];
        NSArray *validatedOddsArray = [validator validOddsArray:self.oddsArray forGame:game];
        if(!validatedOddsArray)
            return;
        
        FSPGameOdds *odds = game.odds;
        // If it doesn't have an odds object make one
        if (!odds) {
            odds = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGameOdds"
                                                 inManagedObjectContext:self.managedObjectContext];
            odds.game = game;
        }
        
        for (NSDictionary *oddsDict in validatedOddsArray) {
            if ([oddsDict isKindOfClass:[NSDictionary class]]) {
                NSString *teamId = [oddsDict objectForKey:@"fsId"];
                if ([teamId isEqualToString:game.homeTeamIdentifier]) {
                    odds.homeTeamMoneyLine = [oddsDict fsp_objectForKey:FSPOddsMoneyLineKey defaultValue:@""];
                    odds.homeTeamPointSpread = [oddsDict fsp_objectForKey:FSPOddsPointSpreadKey defaultValue:@""];
                    odds.homeTeamPSMoneyLine = [oddsDict fsp_objectForKey:FSPOddsPSMoneyLineKey defaultValue:@""];
                } else if ([teamId isEqualToString:game.awayTeamIdentifier]) {
                    odds.awayTeamMoneyLine = [oddsDict fsp_objectForKey:FSPOddsMoneyLineKey defaultValue:@""];
                    odds.awayTeamPointSpread = [oddsDict fsp_objectForKey:FSPOddsPointSpreadKey defaultValue:@""];
                    odds.awayTeamPSMoneyLine = [oddsDict fsp_objectForKey:FSPOddsPSMoneyLineKey defaultValue:@""];
                } else {
                    FSPLogDataCoordination(@"Unable to match odds dictionary to a team in this event %@", oddsDict);
                }
            }
        }
    }];
}

@end
