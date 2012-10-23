//
//  FSPGamePlayByPlayItem.m
//  FoxSports
//
//  Created by Matthew Fay on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGamePlayByPlayItem.h"
#import "FSPGame.h"
#import "FSPBaseballGame.h"
#import "FSPTeam.h"
#import "FSPPitchEvent.h"
#import "FSPBaseballPlayer.h"
#import "FSPSoccerGame.h"
#import "FSPSoccerSub.h"
#import "FSPSoccerGoal.h"
#import "FSPSoccerCard.h"

#import "NSDictionary+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"
#import "FSPLogging.h"

@implementation FSPGamePlayByPlayItem

@dynamic awayScore;
@dynamic correction;
@dynamic homeScore;
@dynamic minute;
@dynamic period;
@dynamic adjustedPeriodValue;
@dynamic isPlaceholder;
@dynamic pointsScored;
@dynamic possessionIdentifier;
@dynamic second;
@dynamic sequenceNumber;
@dynamic summaryPhrase;
@dynamic abbreviatedSummary;

@dynamic game;
@dynamic team;

@dynamic possessionChange;
@dynamic possessionChangePhrase;
@dynamic down;
@dynamic yardsToGo;
@dynamic yardsFromGoal;

@dynamic baseRunners;
@dynamic outOccured;
@dynamic outs;
@dynamic topBottom;
@dynamic currentPlayerAway;
@dynamic currentPlayerHome;
@dynamic pitches;

@dynamic eventCode;
@dynamic battingSlot;
@dynamic batType;
@dynamic distanceHit;
@dynamic directionHit;
@dynamic inningHits;
@dynamic inningRuns;
@dynamic inningErrors;

@dynamic substitution;

@dynamic penalty;

- (void)populateWithDictionary:(NSDictionary *)playByPlayDict withGame:(FSPGame *)game
{
    //NHL specific
    self.penalty = [playByPlayDict fsp_objectForKey:@"PTY" defaultValue:@(NO)];
    
    //MLB specific
    NSNumber *baseRunners = [playByPlayDict fsp_objectForKey:@"BR" defaultValue:@-1];
    if (baseRunners.intValue == 3)
        baseRunners = @4;
    else if (baseRunners.intValue == 4)
        baseRunners = @3;
    self.baseRunners = baseRunners;
    
    self.outOccured = [playByPlayDict fsp_objectForKey:@"OO" defaultValue:@(FSPLiveEngineDefault)];
    self.outs = [playByPlayDict fsp_objectForKey:@"O" defaultValue:@(FSPLiveEngineDefault)];
    self.topBottom = [playByPlayDict fsp_objectForKey:@"TB" defaultValue:@""];
    
    //All Games
    self.game = game;
    self.homeScore = [playByPlayDict fsp_objectForKey:@"HS" defaultValue:@(FSPLiveEngineDefault)];
    
    self.awayScore = [playByPlayDict fsp_objectForKey:@"AS" defaultValue:@(FSPLiveEngineDefault)];
    
    self.pointsScored = [playByPlayDict fsp_objectForKey:@"PS" defaultValue:@0];
    if ([self.pointsScored isEqualToNumber:@0]) {
        //how MLB passes if there is a scoring play
        self.pointsScored = [playByPlayDict fsp_objectForKey:@"S" defaultValue:@0];
    }
    
    self.summaryPhrase = [playByPlayDict fsp_objectForKey:@"SP" defaultValue:@"--"];
    //right now this is only for MLB
    self.abbreviatedSummary = [playByPlayDict fsp_objectForKey:@"T" defaultValue:@"--"];
    
    self.possessionIdentifier = [playByPlayDict fsp_objectForKey:@"PID" defaultValue:@(FSPLiveEngineDefault)];
    
    if ([self.possessionIdentifier isEqualToNumber:@(FSPLiveEngineDefault)] && ![self.topBottom isEqualToString:@""]) {
        if ([self.topBottom isEqualToString:@"T"]) {
            self.possessionIdentifier = self.game.awayTeamLiveEngineID;
        } else {
            self.possessionIdentifier = self.game.homeTeamLiveEngineID;
        }
    }
    
    //set team
    if ((![self.possessionIdentifier isEqualToNumber:@(FSPLiveEngineDefault)] && [self.possessionIdentifier isEqualToNumber:self.game.homeTeamLiveEngineID]) || [self.topBottom isEqualToString:@"B"]) {
        self.team = self.game.homeTeam;
    } else if ((![self.possessionIdentifier isEqualToNumber:@(FSPLiveEngineDefault)] && [self.possessionIdentifier isEqualToNumber:self.game.awayTeamLiveEngineID]) || [self.topBottom isEqualToString:@"T"]) {
        self.team = self.game.awayTeam;
    }
    
    NSDictionary *time = [playByPlayDict objectForKey:@"TIME"];
    if (time) {
        self.period = [time fsp_objectForKey:@"P" defaultValue:@(FSPLiveEngineDefault)];
        self.minute = [time fsp_objectForKey:@"M" defaultValue:@(FSPLiveEngineDefault)];
        self.second = [time fsp_objectForKey:@"S" defaultValue:@(FSPLiveEngineDefault)];
    } else {
        self.period = @(FSPLiveEngineDefault);
        self.minute = @(FSPLiveEngineDefault);
        self.second = @(FSPLiveEngineDefault);
    }
    
    if (!self.period || [self.period isEqualToNumber:@(FSPLiveEngineDefault)]) {
        //how MLB passes the period (inning)
        self.period = [playByPlayDict fsp_objectForKey:@"I" defaultValue:@(FSPLiveEngineDefault)];
    }
    
	self.possessionChange = [playByPlayDict fsp_objectForKey:@"PC" defaultValue:@(NO)];
    self.possessionChangePhrase = [playByPlayDict fsp_objectForKey:@"PDP" defaultValue:@""];
}

- (NSNumber *)adjustedPeriod;
{
    if (self.game.viewType == FSPBaseballViewType) {
        NSString *inning = [self topBottom];
        if (!inning) {
            return self.period;
        }
        
        // for MLB we need return top/bottom of innings as periods
        if ([inning isEqualToString:@"T"]) {
            return @([self.period intValue] * 2);
        } else {
            return @(([self.period intValue] * 2) + 1);
        }
    } else if (self.game.viewType == FSPNFLViewType)
        return self.adjustedPeriodValue;
    else 
        return self.period;
}

- (NSString *)periodTitle;
{
	NSInteger periodValue = self.period.integerValue;
	switch (self.game.viewType) {
		case FSPBasketballViewType:
		{
			if ( periodValue < 5 ) {
				return [NSString stringWithFormat:@"Period %d", periodValue];
			} else {
				return [NSString stringWithFormat:@"Over Time %d", periodValue - 4];
			}
			break;
		}
		case FSPNCAABViewType: {
			switch (periodValue) {
				case 1:
					return [NSString stringWithFormat:@"%dst Half", periodValue];
					break;
				case 2:
					return [NSString stringWithFormat:@"%dnd Half", periodValue];
					break;
				default:
					return [NSString stringWithFormat:@"Over Time %d", periodValue - 2];
					break;
			}
			break;
		}
		case FSPBaseballViewType: {
			FSPBaseballGame *game = (FSPBaseballGame *)self.game;
			BOOL isTopOfInning = ![self.topBottom isEqualToString:@"T"];
			NSString *teamName = isTopOfInning ? game.homeTeam.longNameDisplayString : game.awayTeam.longNameDisplayString;
			
			return [NSString stringWithFormat:@"%@     %@", [self shortPeriodTitle], teamName];
			break;
		}
		case FSPNFLViewType:
		case FSPNCAAFViewType: {
            if (self.period.intValue > 4) {
                return [NSString stringWithFormat:@"OT  %@", self.possessionChangePhrase];
            } else {
                return [NSString stringWithFormat:@"%@ Quarter  %@", [self.period fsp_ordinalStringValue], self.possessionChangePhrase];
            }
			break;
		}
		case FSPSoccerViewType: {
			if (periodValue == 1) {
				return [NSString stringWithFormat:@"%dst Half", periodValue];
			} else {
				return [NSString stringWithFormat:@"%dnd Half", periodValue];
			}
		}
		case FSPHockeyViewType: {
			return [NSString stringWithFormat:@"%@ Period", [self.period fsp_ordinalStringValue]];
		}
		default:
			return [self.period stringValue];
			break;
	}
}

- (UIColor *)periodBackgroundColor;
{
#ifdef DEBUG
    if (!(self.game.viewType ==  FSPBaseballViewType || self.game.viewType == FSPNFLViewType)) {
        FSPLogPlayByPlay(@"periodBackgroundColor is currently only defined for MLB and NFL. %s", __PRETTY_FUNCTION__);
        return nil;
    }
#endif
    
    if ([self.possessionIdentifier isEqualToNumber:self.game.homeTeamLiveEngineID]) {
        return self.game.homeTeamColor;
    } else {
        return self.game.awayTeamColor;
    }
    return nil;
}

- (NSString *)shortPeriodTitle
{
	if (self.game.viewType == FSPBasketballViewType || self.game.viewType == FSPNCAABViewType) {
		return [self periodTitle];
	}
	else if (self.game.viewType == FSPBaseballViewType) {
		BOOL isTopOfInning = [self.topBottom isEqualToString:@"T"];
		return [NSString stringWithFormat:@"%@ %@", isTopOfInning ? @"Top" : @"Bot", [self.period fsp_ordinalStringValue]];
	}
	
	return [self.period stringValue];
}


- (NSString *)eventPBPString
{
	return self.abbreviatedSummary;
}

- (void)populateWithGameEventDictionary:(NSDictionary *)GEDict inContext:(NSManagedObjectContext *)context
{
    self.eventCode = [[GEDict allKeys] objectAtIndex:0];
    NSDictionary *infoDict = [GEDict objectForKey:self.eventCode];
    
    if (self.game.viewType == FSPSoccerViewType) {
        [self populateSoccerGameWithDictionary:infoDict inContext:context];
    }
    
    if (self.game.viewType == FSPBaseballViewType) {
        if ([self.eventCode isEqualToString:@"E1"]) {
            
            FSPBaseballPlayer * subPlayer = [self findBaseballPlayerWithID:[infoDict objectForKey:@"SID"] fromGame:self.game];
            subPlayer.sub = @1;
            subPlayer.battingOrder = [infoDict fsp_objectForKey:@"BS" defaultValue:@0];
            subPlayer.position = [infoDict fsp_objectForKey:@"POSN" defaultValue:@"--"];
            subPlayer.subBatting = [self subNumberForBattingPlayer:subPlayer];
            if ([subPlayer.position isEqualToString:@"P"])
                subPlayer.subPitching = [self subNumberForPitchingPlayer:subPlayer];
        }
        
        
        
        //pitcher hitter matchup
        NSString *topBottom = [infoDict objectForKey:@"TB"];
        NSNumber *pitcherID = [infoDict objectForKey:@"PID"];
        NSNumber *batterID = [infoDict objectForKey:@"BID"];
        if (pitcherID && batterID) {
            if ([topBottom isEqualToString:@"T"]) {
                self.currentPlayerAway = [self findBaseballPlayerWithID:batterID fromGame:self.game];
                self.currentPlayerHome = [self findBaseballPlayerWithID:pitcherID fromGame:self.game];
            } else if ([topBottom isEqualToString:@"B"]) {
                self.currentPlayerAway = [self findBaseballPlayerWithID:pitcherID fromGame:self.game];
                self.currentPlayerHome = [self findBaseballPlayerWithID:batterID fromGame:self.game];
            }
        }
        
        self.battingSlot = [infoDict objectForKey:@"BS"];
        self.batType = [infoDict objectForKey:@"BT"];
        self.distanceHit = [infoDict objectForKey:@"DIST"];
        self.directionHit = [infoDict objectForKey:@"DIR"];
        self.inningRuns = [infoDict objectForKey:@"RUN"];
        self.inningHits = [infoDict objectForKey:@"HIT"];
        self.inningErrors = [infoDict objectForKey:@"ERR"];
        
        //pitches
        NSArray * values = [[NSOrderedSet orderedSetWithOrderedSet:self.pitches] array];
        NSArray * keys = [values valueForKeyPath:@"sequence"];
        NSMutableDictionary *currentPitchDictionary = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        
        NSArray *pitches = [infoDict objectForKey:@"P"];
        NSUInteger strikes = 0;
        NSUInteger balls = 0;
        for (NSUInteger i = 0; i < [pitches count]; i++) {
            NSDictionary *pitchEvent = [pitches objectAtIndex:i];
            FSPPitchEvent *pitch = [currentPitchDictionary objectForKey:[pitchEvent objectForKey:@"SEQ"]];
            if(!pitch) {
                pitch = [NSEntityDescription insertNewObjectForEntityForName:@"FSPPitchEvent" inManagedObjectContext:context];
                pitch.sequence = [pitchEvent objectForKey:@"SEQ"];
                [currentPitchDictionary setObject:pitch forKey:pitch.sequence];
            }
            [pitch populateWithDictionary:pitchEvent];
            
            if ([pitch.result isEqualToString:@"B"])
                balls++;
            else if (![pitch.result isEqualToString:@"H"])
                strikes++;
        }
        
        if (self.game.viewType == FSPBaseballViewType && [self.summaryPhrase isEqualToString:@""]){
            NSString * pitchCount = [NSString stringWithFormat:@"%d-%d",balls, strikes];
            self.summaryPhrase = [NSString stringWithFormat:@"%@ facing %@ with a count of %@", [self.currentPlayerAway lastName], [self.currentPlayerHome lastName], pitchCount];
            self.abbreviatedSummary = @"At Bat";
        }
    }
}

//NFL only
- (void)populateWithGameStateDictionary:(NSDictionary *)gameState
{
    NSNumber *noValue = @-1;
    self.down = [gameState fsp_objectForKey:@"D" defaultValue:noValue];
    self.yardsToGo = [gameState fsp_objectForKey:@"YTG" defaultValue:noValue];
    self.yardsFromGoal = [gameState fsp_objectForKey:@"YFG" defaultValue:noValue];
    
    self.homeScore = [[gameState fsp_objectForKey:@"H" defaultValue:gameState] fsp_objectForKey:@"TS" defaultValue:noValue];
    self.awayScore = [[gameState fsp_objectForKey:@"A" defaultValue:gameState] fsp_objectForKey:@"TS" defaultValue:noValue];
}

- (NSString *)yardsFromGoalString
{
	NSInteger ytg = [self.yardsFromGoal integerValue];
	NSInteger n = ytg;
	NSString *abbrev;
	if (n > 50) {
		n = 100 - n;
		abbrev = self.team.abbreviation;
	} else {
		if ([self.team isEqual:self.game.homeTeam]) {
			abbrev = self.game.awayTeam.abbreviation;
		} else {
			abbrev = self.game.homeTeam.abbreviation;
		}
		
	}
	return [NSString stringWithFormat:@"%@ %d", abbrev, n];
}

//Baseball only
- (FSPBaseballPlayer *)findBaseballPlayerWithID:(NSNumber *)playerID fromGame:(FSPGame *)game;
{
	if (!playerID) return nil;
	
    FSPBaseballPlayer *foundPlayer;
    for (FSPBaseballPlayer *player in game.homeTeamPlayers) {
        if ([player.liveEngineID isEqualToNumber:playerID]) {
            foundPlayer = player;
            break;
        }
    }
    if (!foundPlayer) {
        for (FSPBaseballPlayer *player in game.awayTeamPlayers) {
            if ([player.liveEngineID isEqualToNumber:playerID]) {
                foundPlayer = player;
                break;
            }
        }
    }
    return foundPlayer;
}

- (NSNumber *)subNumberForBattingPlayer:(FSPBaseballPlayer *)subPlayer
{
    NSUInteger count = 0;
    
    if (subPlayer.homeGame) {
        if (![subPlayer.battingOrder isEqualToNumber:@-1]) {
            for (FSPBaseballPlayer *player in self.game.homeTeamPlayers) {
                if ([player.battingOrder isEqualToNumber:subPlayer.battingOrder]) {
                    count++;
                }
            }
        }
    } else if (subPlayer.awayGame) {
        if (![subPlayer.battingOrder isEqualToNumber:@-1]) {
            for (FSPBaseballPlayer *player in self.game.awayTeamPlayers) {
                if ([player.battingOrder isEqualToNumber:subPlayer.battingOrder]) {
                    count++;
                }
            }
        }
    }
    return @(--count);
}

- (NSNumber *)subNumberForPitchingPlayer:(FSPBaseballPlayer *)subPlayer
{
    NSUInteger count = 0;
    
    if (subPlayer.homeGame) {
        if ([subPlayer.position isEqualToString:@"P"]) {
            for (FSPBaseballPlayer *pitcher in self.game.homeTeamPlayers) {
                if ([pitcher.position isEqualToString:@"P"] && (pitcher.starter.boolValue || pitcher.subPitching.intValue != 0)) {
                    count++;
                }
            }
        }
    } else if (subPlayer.awayGame) {
        if ([subPlayer.position isEqualToString:@"P"]) {
            for (FSPBaseballPlayer *pitcher in self.game.awayTeamPlayers) {
                if ([pitcher.position isEqualToString:@"P"] && (pitcher.starter.boolValue || pitcher.subPitching.intValue != 0)) {
                    count++;
                }
            }
        }
    }
    return @(count);
}

//Soccer Only
- (void)populateSoccerGameWithDictionary:(NSDictionary *)infoDict inContext:(NSManagedObjectContext *)context
{
    FSPSoccerGame *soccerGame = (FSPSoccerGame *)self.game;
    BOOL isHomeTeam = [soccerGame.homeTeamLiveEngineID isEqualToNumber:[infoDict fsp_objectForKey:@"TID" defaultValue:@-1]];
    
    if ([self.eventCode isEqualToString:@"SUB"]) {
        self.substitution = [NSNumber numberWithBool:YES];
        FSPSoccerSub *newSub;
        NSSet *subs = isHomeTeam ? soccerGame.homeSubs : soccerGame.awaySubs;
        for (FSPSoccerSub *sub in subs) {
            if ([sub.sequenceNumber isEqualToNumber:self.sequenceNumber])
                newSub = sub;
        }
        if (!newSub) {
            newSub = [NSEntityDescription insertNewObjectForEntityForName:@"FSPSoccerSub" inManagedObjectContext:context];
            if (isHomeTeam)
                newSub.homeGame = soccerGame;
            else
                newSub.awayGame = soccerGame;
            newSub.sequenceNumber = self.sequenceNumber;
        }
        [newSub populateWithDictionary:infoDict];
    }
    
    if ([self.eventCode isEqualToString:@"GS"]) {
        FSPSoccerGoal *newGoal;
        NSSet *goals = isHomeTeam ? soccerGame.homeGoals : soccerGame.awayGoals;
        self.baseRunners = [NSNumber numberWithBool:1];
        for (FSPSoccerGoal *goal in goals) {
            if ([goal.sequenceNumber isEqualToNumber:self.sequenceNumber])
                newGoal = goal;
        }
        if (!newGoal) {
            newGoal = [NSEntityDescription insertNewObjectForEntityForName:@"FSPSoccerGoal" inManagedObjectContext:context];
            if (isHomeTeam)
                newGoal.homeGame = soccerGame;
            else
                newGoal.awayGame = soccerGame;
            newGoal.sequenceNumber = self.sequenceNumber;
        }
        [newGoal populateWithDictionary:infoDict];
    }
    
    if ([self.eventCode isEqualToString:@"YC"] || [self.eventCode isEqualToString:@"RC"]) {
        FSPSoccerCard *newCard;
        NSSet *cards = isHomeTeam ? soccerGame.homeCards : soccerGame.awayCards;
        if ([self.eventCode isEqualToString:@"YC"]) {
            self.penalty = [NSNumber numberWithBool:1];
        } else {
            self.penalty = [NSNumber numberWithBool:2];
        }
        for (FSPSoccerCard *card in cards) {
            if ([card.sequenceNumber isEqualToNumber:self.sequenceNumber])
                newCard = card;
        }
        if (!newCard) {
            newCard = [NSEntityDescription insertNewObjectForEntityForName:@"FSPSoccerCard" inManagedObjectContext:context];
            if (isHomeTeam)
                newCard.homeGame = soccerGame;
            else
                newCard.awayGame = soccerGame;
            newCard.sequenceNumber = self.sequenceNumber;
            newCard.cardType = self.eventCode;
        }
        [newCard populateWithDictionary:infoDict];
    }
}


@end
