//
//  FSPScheduleProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleProcessingOperation.h"

#import "FSPCoreDataManager.h"
#import "FSPDataCoordinator.h" // For notifications
#import "FSPEvent.h"
#import "FSPEventValidator.h"
#import "FSPOrganization.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPOrganizationSchedule.h"
#import "FSPScheduleGame.h"
#import "FSPScheduleMLBGame.h"
#import "FSPScheduleNFLGame.h"
#import "FSPScheduleNBAGame.h"
#import "FSPScheduleRacingEvent.h"
#import "FSPScheduleNHLGame.h"
#import "FSPScheduleTennisEvent.h"
#import "FSPTeam.h"
#import "FSPPGAScheduleEvent.h"

#import "NSDictionary+FSPExtensions.h"


@interface FSPScheduleProcessingOperation ()
@property (nonatomic, copy) NSArray *schedule;
@property (nonatomic, copy) NSManagedObjectID *orgMOID;
- (FSPScheduleEvent *)chooseScheduleFromOrganization:(FSPOrganization *)org;
@end

@implementation FSPScheduleProcessingOperation
@synthesize schedule = _schedule;
@synthesize orgMOID = _orgMOID;
@synthesize sortedScheduleArray;

- (id)initWithSchedule:(NSArray *)schedule forOrganizationId:(NSManagedObjectID *)organizationIdentifier
               context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.schedule = schedule;
        self.orgMOID = organizationIdentifier;
        self.sortedScheduleArray = [[NSArray alloc] init];
    }
    return self;
}

- (void)main;
{
    if ([self.schedule count] == 0 || self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSMutableArray *mutSchedule = [[NSMutableArray alloc] initWithCapacity:[self.schedule count]];
        
        FSPOrganization *org = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:self.orgMOID error:nil];

        if (!org)
            return;
        
		FSPEventValidator * validator = [[FSPEventValidator alloc] init];
		if (org.isTeamSport) {
			NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganizationHierarchyInfo"];
			fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isTeam == YES && branch == %@", [org highestLevel].branch];
            NSArray * hierarchyInfo = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
			NSArray * teams = [hierarchyInfo valueForKeyPath:@"currentOrg"];
			NSArray * teamsIds = [teams valueForKeyPath:@"uniqueIdentifier"];
			NSDictionary *teamsDictionary = [NSDictionary dictionaryWithObjects:teams forKeys:teamsIds];
			
			[self.schedule enumerateObjectsUsingBlock:^(NSDictionary *event, NSUInteger idx, BOOL *stop){
				NSDictionary *validatedEvent = [validator validateDictionary:event error:nil];
				if (validatedEvent) {
					FSPScheduleGame *eventToUpdate = (FSPScheduleGame *)[self chooseScheduleFromOrganization:org];
					if (eventToUpdate) {
						FSPTeam *homeTeam = [teamsDictionary objectForKey:[validatedEvent objectForKey:@"homeTeamId"]];
						if (homeTeam.viewType == FSPNCAAFViewType || homeTeam.viewType == FSPNCAABViewType || homeTeam.viewType == FSPNCAAWBViewType) {
                            eventToUpdate.homeTeamName = homeTeam.name;
                        } else {
                            eventToUpdate.homeTeamName = [homeTeam.nickname isEqualToString:@""] ? homeTeam.name : homeTeam.nickname;
                        }
						eventToUpdate.homeTeamAbbreviation = homeTeam.abbreviation;
						FSPTeam *awayTeam = [teamsDictionary objectForKey:[validatedEvent objectForKey:@"visitingTeamId"]];
						if (awayTeam.viewType == FSPNCAAFViewType || awayTeam.viewType == FSPNCAABViewType || awayTeam.viewType == FSPNCAAWBViewType) {
                            eventToUpdate.awayTeamName = awayTeam.name;
                        } else {
                            eventToUpdate.awayTeamName = [awayTeam.nickname isEqualToString:@""] ? awayTeam.name : awayTeam.nickname;
                        }
						eventToUpdate.awayTeamAbbreviation = awayTeam.abbreviation;
                        eventToUpdate.homeTeam = homeTeam;
                        eventToUpdate.awayTeam = awayTeam;
						[eventToUpdate populateWithDictionary:validatedEvent];
						
						if (homeTeam && awayTeam) {
							[mutSchedule addObject:eventToUpdate];
						}
					}
				}
			}];
		} else {
			[self.schedule enumerateObjectsUsingBlock:^(NSDictionary *event, NSUInteger idx, BOOL *stop){
				NSDictionary *validatedEvent = [validator validateDictionary:event error:nil];
				if (validatedEvent) {
					FSPScheduleEvent *eventToUpdate = [self chooseScheduleFromOrganization:org];
					[eventToUpdate populateWithDictionary:validatedEvent];
					[mutSchedule addObject:eventToUpdate];
				}
			}];
		}
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        NSArray * sortedSchedule = [mutSchedule sortedArrayUsingDescriptors:sortDescriptors];
        
        NSMutableArray * scheduleSections = [[NSMutableArray alloc] init];
        NSMutableArray * currentSection;
        NSDate *currentDate;
        
        for (FSPScheduleGame *event in sortedSchedule) {
            if ( [currentDate isEqualToDate:event.normalizedStartDate]) {
                [currentSection addObject:event];
            } else {
                if (currentSection) {
                    [scheduleSections addObject:currentSection];
                }
                currentSection = [[NSMutableArray alloc] init];
                [currentSection addObject:event];
                currentDate = event.normalizedStartDate;
            }
        }
        
        if (currentSection)
            [scheduleSections addObject:currentSection];
        
        self.sortedScheduleArray = [self scheduleArrayForBranch:org.branch fromArray:[NSArray arrayWithArray:scheduleSections]];
    }];
}

- (FSPScheduleEvent *)chooseScheduleFromOrganization:(FSPOrganization *)org
{
	NSString *branch = [org baseBranch];
    FSPScheduleEvent *event;
    if ([branch isEqualToString:FSPNBAEventBranchType] || [branch isEqualToString:FSPNCAABasketballEventBranchType] || [branch isEqualToString:FSPNCAAWBasketballEventBranchType] || [branch isEqualToString:FSPWNBAEventBranchType]) {
        event = [[FSPScheduleNBAGame alloc] init];
    } else if ([branch isEqualToString:FSPMLBEventBranchType]) {
        event = [[FSPScheduleMLBGame alloc] init];
    } else if ([branch isEqualToString:FSPNFLEventBranchType] || [branch isEqualToString:FSPNCAAFootballEventBranchType]) {
        event = [[FSPScheduleNFLGame alloc] init];
    } else if ([branch isEqualToString:FSPNASCAREventBranchType]) {
		event = [[FSPScheduleRacingEvent alloc] init];
	} else if ([branch isEqualToString:FSPNHLEventBranchType]) {
        event = [[FSPScheduleNHLGame alloc] init];
    } else if ([branch isEqualToString:FSPGolfBranchType]) {
        event = [[FSPPGAScheduleEvent alloc] init];
    } else if ([branch isEqualToString:FSPTennisEventBranchType]) {
        event = [[FSPScheduleTennisEvent alloc] init];
    } else {
		if (org.isTeamSport) {
			event = [[FSPScheduleGame alloc] init];
		} else {
			event = [[FSPScheduleEvent alloc] init];
		}
	}
    return event;
}

- (NSArray *)scheduleArrayForBranch:(NSString *)branch fromArray:(NSArray *)array
{
	branch = [FSPOrganization baseBranchForBranch:branch];
    NSMutableArray *reorderedArray = [NSMutableArray array];
    if ([branch isEqualToString:FSPNFLEventBranchType] || [branch isEqualToString:FSPNCAAFootballEventBranchType]) {
        
        NSDate *firstGame;
        // Throw everything into one big array
        NSMutableArray *bigArray = [NSMutableArray array];
        for (NSArray *anArray in array) {
            for (FSPScheduleGame *game in anArray) {
                [bigArray addObject:game];
                //TODO: Fix when we have more than just preseason
                //Find first regular season game
                if (!firstGame  /*&& [game.seasonType isEqualToString:@"REGULAR_SEASON"]*/)
                    firstGame = game.normalizedStartDate;
            }
        }
        
        if (!firstGame)
            return array;
        // The games need to be assigned a week number for display purposes.  Additionally, football weeks start on Thursdays, though
        // the season may not.  To assign week numbers properly, pick the first day & create a "start of season" date = the thursday before.

		NSUInteger units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSWeekCalendarUnit | NSWeekdayCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                                
		NSDateComponents *comps = [calendar components:units fromDate:firstGame];
        if ([branch isEqualToString:FSPNFLEventBranchType])
            [comps setWeekday:3];
        else if ([branch isEqualToString:FSPNCAAFootballEventBranchType])
            [comps setWeekday:5];
        NSDate *startOfSeason = [[NSCalendar currentCalendar] dateFromComponents:comps];
		if ([startOfSeason compare:[[bigArray objectAtIndex:0] normalizedStartDate]] == NSOrderedDescending) {
			comps.week -= 1;
		}
        
        startOfSeason = [calendar dateFromComponents:comps];

		__block NSDate *endOfWeek = nil;
       
        
		comps = [[NSDateComponents alloc] init];
		[comps setDay:7];
		endOfWeek = [calendar dateByAddingComponents:comps toDate:startOfSeason options:0];
        
        // Prepare to resort the games into arrays of weeks
        __block NSMutableArray *weekArray = [NSMutableArray array];
        __block NSUInteger weekNumber = 1;
        // Start at 0 for hall of fame game
        __block NSUInteger preseasonWeekNumber = 0;
        __block NSUInteger postseasonWeekNumber = 1;
        __block FSPScheduleNFLGame *previousGame =nil;
        
        [bigArray enumerateObjectsUsingBlock:^(FSPScheduleNFLGame *game, NSUInteger idx, BOOL *stop) {
            
            // Find regular season games that fall before the endo of the current week.
            // TODO:  Need to see how they want pre-season and post-season done.
            
            // The preseason is a special case, since the first game is the "Hall of Fame Game"
            // and needs to have its own week.
            if (preseasonWeekNumber == 0 && [game.seasonType isEqualToString:@"EXHIBITION"]) {
                game.showDateLabel = YES;
                game.weekNumber = 0;
                NSArray *hallOfFameArray = @[game];
                [comps setDay:7];
                endOfWeek = [calendar dateByAddingComponents:comps toDate:endOfWeek options:0];
                [reorderedArray addObject:hallOfFameArray];
                preseasonWeekNumber++;
            }
            else if ([game.normalizedStartDate compare:endOfWeek] == NSOrderedAscending) {
                // Get the previous game if it exists
                if (bigArray.count > 0 && idx > 0) {
                    previousGame = [bigArray objectAtIndex:idx - 1];
                }
                if ((previousGame && ![previousGame.normalizedStartDate isEqualToDate:game.normalizedStartDate]) || weekArray.count < 1) {
                    // If the previous game was not on the same day as the game, it is necessary to show a date header above the game
                    game.showDateLabel = YES;
                }
                [weekArray addObject:game];
                if ([game.seasonType isEqualToString:@"REGULAR_SEASON"])
                    game.weekNumber = weekNumber;
                else if ([game.seasonType isEqualToString:@"EXHIBITION"])
                    game.weekNumber = preseasonWeekNumber;
                else if ([game.seasonType isEqualToString:@"POST_SEASON"])
                    game.weekNumber = postseasonWeekNumber;
            }
            else {
                // The game is in the next week.  Create an array for the new week, put the game in it, and update
                // the end of the week.
                [comps setDay:7];
                endOfWeek = [calendar dateByAddingComponents:comps toDate:endOfWeek options:0];
                [reorderedArray addObject:weekArray];
                weekArray = [NSMutableArray array];
                [weekArray addObject:game];
                if ([game.seasonType isEqualToString:@"REGULAR_SEASON"]) {
                    weekNumber++;
                    game.weekNumber = weekNumber;
                } else if ([game.seasonType isEqualToString:@"EXHIBITION"]) {
                    preseasonWeekNumber++;
                    game.weekNumber = preseasonWeekNumber;
                } else if ([game.seasonType isEqualToString:@"POST_SEASON"]) {
                    postseasonWeekNumber++;
                    game.weekNumber = postseasonWeekNumber;
                }
                game.showDateLabel = YES;
            }
            
            if (idx == [bigArray count] - 1)
                [reorderedArray addObject:weekArray];
        }];
        return reorderedArray;

    }
    else {
        return array;
    }
}

@end
