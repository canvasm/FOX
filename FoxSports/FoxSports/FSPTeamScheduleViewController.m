//
//  FSPTeamScheduleViewController.m
//  FoxSports
//
//  Created by greay on 6/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleViewController.h"
#import "FSPScheduleGame.h"
#import "FSPScheduleNFLGame.h"
#import "FSPOrganization.h"
#import "FSPGame.h"

#import "FSPNBATeamScheduleHeaderView.h"
#import "FSPMLBTeamScheduleHeaderView.h"
#import "FSPNFLTeamScheduleHeaderView.h"
#import "FSPSoccerTeamScheduleHeaderView.h"
#import "FSPNHLTeamScheduleHeaderView.h"

#import "FSPTeamScheduleCell.h"

#import "NSDate+FSPExtensions.h"

@interface FSPTeamScheduleViewController()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Class cellClass;

@end

@implementation FSPTeamScheduleViewController
@synthesize tableView;
@synthesize cellClass;

- (void)setupTableView
{
	FSPViewType viewType = [FSPScheduleViewController viewTypeForOrganization:self.organization];
    NSString *nibName;
	switch (viewType) {
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
		case FSPBasketballViewType:
			nibName = @"FSPNBATeamScheduleCell";
			self.tableView.accessibilityLabel = @"nba team schedule";
			break;
		case FSPBaseballViewType:
			nibName = @"FSPMLBTeamScheduleCell";
			self.tableView.accessibilityLabel = @"mlb team schedule";
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			nibName = @"FSPNFLTeamScheduleCell";
			self.tableView.accessibilityLabel = @"nfl team schedule";
			break;
		case FSPSoccerViewType:
            nibName = @"FSPSoccerTeamScheduleCell";
			self.tableView.accessibilityLabel = @"soccer team schedule";
			break;
        case FSPHockeyViewType:
            nibName = @"FSPNHLTeamScheduleCell";
            self.tableView.accessibilityLabel = @"nhl team schedule";
            break;
		default:
			break;
	}
    UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
    self.cellClass = [[[cellNib instantiateWithOwner:nil options:nil] lastObject] class];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"scheduleCell"];
}


- (void)updateSchedule
{
    NSMutableArray *pastGamesArray = [NSMutableArray array];
    NSMutableArray *futureGamesArray = [NSMutableArray array];
    for (NSArray *array in self.scheduleArray) {
        for (FSPScheduleGame *game in array) {
            // Figure out if this is a future date or not
            BOOL isFuture;
            if ([game.normalizedStartDate fsp_isToday]) {
                isFuture = YES;
            } else {
                NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:game.normalizedStartDate];
                isFuture = (comparisonResult == NSOrderedAscending);
            }
            if (isFuture) {
                [futureGamesArray addObject:game];
            }
            else {
                [pastGamesArray addObject:game];
            }
        }
    }
    
    // Insert a "Bye Week" row into the NFL schedule.  Note that this will not work if the bye
    // week is the first week, since there is no independent way to determine the first day of the season.
    // TODO: Fix that, find a better place for this
    if ([[self.organization baseBranch] isEqualToString:FSPNFLEventBranchType]) {
        BOOL foundByeWeek = NO;
        if (pastGamesArray.count) {
            NSDate *previousGameDate = [[pastGamesArray objectAtIndex:0] normalizedStartDate];
            FSPScheduleNFLGame *byeWeek = nil;
            for (FSPScheduleNFLGame *game in pastGamesArray) {
                // If the next game is not within the next 13 days, then it is a bye week.
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:11];
                NSDate *nextWeek = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:previousGameDate options:0];
                if (game.weekNumber > 1 && [game.normalizedStartDate compare:nextWeek] == NSOrderedDescending) {
                    byeWeek = [[FSPScheduleNFLGame alloc] init];
                    byeWeek.weekNumber = game.weekNumber;
                    foundByeWeek = YES;
                    break;
                }
                previousGameDate = [game normalizedStartDate];
            }
            
            if (foundByeWeek) {
                // Advance all week numbers after bye week by 1
                for (NSUInteger i = 0; i < pastGamesArray.count; i++) {
                    FSPScheduleNFLGame *game = [pastGamesArray objectAtIndex:i];
                    if (game.weekNumber >= byeWeek.weekNumber) {
                        game.weekNumber =game.weekNumber + 1;
                    }
                }
                
                for (NSUInteger i = 0; i < futureGamesArray.count; i++) {
                    FSPScheduleNFLGame *game = [futureGamesArray objectAtIndex:i];
                    game.weekNumber =game.weekNumber + 1;
                }
                
                // Insert the bye week
                [pastGamesArray insertObject:byeWeek atIndex:byeWeek.weekNumber - 1];
            }
        }
        
        if (!foundByeWeek) {
            if (futureGamesArray.count) {
                NSDate *previousGameDate;
                if (pastGamesArray.count)
                    previousGameDate = [[pastGamesArray objectAtIndex:[pastGamesArray count] - 1] normalizedStartDate];
                else 
                    previousGameDate = [[futureGamesArray objectAtIndex:0] normalizedStartDate];
                
                FSPScheduleNFLGame *byeWeek = nil;
                for (FSPScheduleNFLGame *game in futureGamesArray) {
                    // If the next game is not within the next 13 days, then it is a bye week.
                    NSDateComponents *comps = [[NSDateComponents alloc] init];
                    [comps setDay:11];
                    NSDate *nextWeek = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:previousGameDate options:0];
                    if (game.weekNumber > 1 && [game.normalizedStartDate compare:nextWeek] == NSOrderedDescending) {
                        byeWeek = [[FSPScheduleNFLGame alloc] init];
                        byeWeek.weekNumber = game.weekNumber;
                        foundByeWeek = YES;
                        break;
                    }
                    previousGameDate = [game normalizedStartDate];
                }
                if (foundByeWeek) {
                    // Advance all week numbers after bye week by 1
                    for (NSUInteger i = 0; i < futureGamesArray.count; i++) {
                        FSPScheduleNFLGame *game = [futureGamesArray objectAtIndex:i];
                        if (game.weekNumber >= byeWeek.weekNumber) {
                            game.weekNumber =game.weekNumber + 1;
                        }
                    }
                    
                    // Insert the bye week
                    [futureGamesArray insertObject:byeWeek atIndex:byeWeek.weekNumber - pastGamesArray.count - 1];
                }
            }
        }
    }
    
    if (pastGamesArray.count)
        [self.reorderedScheduleArray addObject:pastGamesArray];
    if (futureGamesArray.count)
        [self.reorderedScheduleArray addObject:futureGamesArray];
	
    [self.tableView reloadData];
    self.hasScrolledToToday = NO;
    [self scrollToToday];
}


- (void)scrollToToday;
{
	[super scrollToToday];
}

- (CGFloat)tableView:(UITableView *)atableView heightForHeaderInSection:(NSInteger)section
{
    FSPScheduleHeaderView *headerView = (FSPScheduleHeaderView *)[self tableView:atableView viewForHeaderInSection:section];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return [[headerView class] headerHeght];
	} else {
        if (self.organization.viewType == FSPSoccerViewType) {
            if (headerView.isFuture)
                return [[headerView class] headerHeght] / 2;
        }
        return [[headerView class] headerHeght];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
 	FSPScheduleGame *game = nil;
    if ([[self.reorderedScheduleArray objectAtIndex:section] count]) {
        game = [[self.reorderedScheduleArray objectAtIndex:section] objectAtIndex:0];
    }
	
	FSPScheduleHeaderView *header = [self dequeueHeader];
	
    if (!header) {
		FSPViewType viewType = [FSPScheduleViewController viewTypeForOrganization:self.organization];
		switch (viewType) {
            case FSPNCAABViewType:
            case FSPNCAAWBViewType:
			case FSPBasketballViewType:
				header = [[FSPNBATeamScheduleHeaderView alloc] init];
				break;
			case FSPBaseballViewType:
				header = [[FSPMLBTeamScheduleHeaderView alloc] init];
				break;
			case FSPNFLViewType:
			case FSPNCAAFViewType:
				header = [[FSPNFLTeamScheduleHeaderView alloc] init];
				break;
			case FSPSoccerViewType:
				header = [[FSPSoccerTeamScheduleHeaderView alloc] init];
				break;
            case FSPHockeyViewType:
                header = [[FSPNHLTeamScheduleHeaderView alloc] init];
                break;
			default:
				header = [[FSPScheduleHeaderView alloc] init];
				break;
		}
        
        [self enqueueHeader:header];
    }
    
    header.event = game;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPTeamScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"scheduleCell"];
	if (!cell) {
		cell = [[FSPTeamScheduleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scheduleCell"];
	}
    cell.team = (FSPTeam *)self.organization;
	[cell populateWithGame:[[self.reorderedScheduleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.organization.viewType == FSPHockeyViewType && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (indexPath.section == 1) {
            return 30.0;
        }
    }
    //TODO: use the method on FSPSoccerTeamScheduleCell
    FSPScheduleGame *game = [[self.reorderedScheduleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return [self.cellClass heightForEvent:game];
}


@end
