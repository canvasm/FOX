//
//  FSPNHLTeamStatsFullStatsViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLTeamStatsFullStatsViewController.h"
#import "FSPNHLTeamStatsFullStatsCell.h"
#import "FSPNHLTeamStatsFullStatsHeaderView.h"
#import "FSPGameDetailTeamHeader.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPHockeyGame.h"
#import "FSPHockeyPeriodStats.h"

@interface FSPNHLTeamStatsFullStatsViewController ()

+ (NSArray *)teamStatsRowArray;

@end

typedef NSString *(^FSPNHLTeamStatsGamePropertyBlock)(FSPHockeyGame *game);

@implementation FSPNHLTeamStatsFullStatsViewController

@synthesize game = _game;

static NSString *FSPNHLTeamStatsFullStatsCellIdentifier = @"FSPNHLTeamStatsFullStatsCellIdentifier";
static CGFloat FSPNHLTeamStatsFullStatsHeaderViewHeightPoints = 29.0;
static CGFloat FSPNHLTeamStatsFullStatsRowHeightPoints = 28.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPNHLTeamStatsFullStatsCell" bundle:nil]
         forCellReuseIdentifier:FSPNHLTeamStatsFullStatsCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.class.teamStatsRowArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPNHLTeamStatsFullStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPNHLTeamStatsFullStatsCellIdentifier];

    void(^StyleTopLevelLabel)(UILabel *) = ^(UILabel *label) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor fsp_blackDropShadowColor];
        label.shadowOffset = CGSizeMake(1, 1);
    };
    
    void(^StyleSectionLabel)(UILabel *) = ^(UILabel *label) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
        label.textColor = [UIColor fsp_lightBlueColor];
        label.shadowColor = [UIColor fsp_blackDropShadowColor];
        label.shadowOffset = CGSizeMake(1, 1);
    };
    
    if (cell) {
        NSDictionary *thisRowInfo = [self.class.teamStatsRowArray objectAtIndex:indexPath.row];
        NSString *rowHeaderText = [thisRowInfo objectForKey:FSPNHLTeamStatsRowDescriptionKey];
        NSParameterAssert(rowHeaderText.length > 0);
        if ([[rowHeaderText substringToIndex:1] isEqualToString:@"\t"]) {
            StyleSectionLabel(cell.rowSubheaderLabel);
            StyleTopLevelLabel(cell.teamAValue);
            StyleTopLevelLabel(cell.teamBValue);
            cell.rowHeaderLabel.text = @"";
            cell.rowSubheaderLabel.text = [rowHeaderText substringFromIndex:1];
        } else {
            StyleTopLevelLabel(cell.rowHeaderLabel);
            StyleTopLevelLabel(cell.teamAValue);
            StyleTopLevelLabel(cell.teamBValue);
            cell.rowHeaderLabel.text = rowHeaderText;
            cell.rowSubheaderLabel.text = @"";
        }

        FSPNHLTeamStatsGamePropertyBlock homeTeamInfoBlock = (FSPNHLTeamStatsGamePropertyBlock)[thisRowInfo objectForKey:FSPNHLTeamStatsRowHomeInfoBlockKey];
        FSPNHLTeamStatsGamePropertyBlock awayTeamInfoBlock = (FSPNHLTeamStatsGamePropertyBlock)[thisRowInfo objectForKey:FSPNHLTeamStatsRowAwayInfoBlockKey];
        cell.teamAValue.text = awayTeamInfoBlock(self.game);
        cell.teamBValue.text = homeTeamInfoBlock(self.game);
    }

    return cell;
}

static NSString *FSPNHLTeamStatsRowDescriptionKey = @"FSPNHLTeamStatsRowDescriptionKey";
static NSString *FSPNHLTeamStatsRowHomeInfoBlockKey = @"FSPNHLTeamStatsRowHomeInfoBlockKey";
static NSString *FSPNHLTeamStatsRowAwayInfoBlockKey = @"FSPNHLTeamStatsRowAwayInfoBlockKey";

static NSDictionary *teamStatsRow(NSString *description,
                                  FSPNHLTeamStatsGamePropertyBlock homeTeamInfoBlock,
                                  FSPNHLTeamStatsGamePropertyBlock awayTeamInfoBlock) {
    return @{FSPNHLTeamStatsRowDescriptionKey: description,
            FSPNHLTeamStatsRowHomeInfoBlockKey: homeTeamInfoBlock,
            FSPNHLTeamStatsRowAwayInfoBlockKey: awayTeamInfoBlock};
}

+ (NSArray *)teamStatsRowArray {
    static NSArray *rowArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rowArray = @[teamStatsRow(@"Penalty in Minutes",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homePenaltyMinutes.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayPenaltyMinutes.stringValue;
                                 }),
                    teamStatsRow(@"Power Plays",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return [NSString stringWithFormat:@"%@/%@",
                                             game.homePowerPlayOpportunities,
                                             game.homePowerPlayGoals];
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return [NSString stringWithFormat:@"%@/%@",
                                             game.awayPowerPlayOpportunities,
                                             game.awayPowerPlayGoals];
                                 }),
                    teamStatsRow(@"Hits",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeHits.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayHits.stringValue;
                                 }),
                    teamStatsRow(@"Faceoff Wins",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeFaceOffWins.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayFaceOffWins.stringValue;
                                 }),
                    teamStatsRow(@"Giveaways",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeTurnovers.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayTurnovers.stringValue;
                                 }),
                    teamStatsRow(@"Takeaways",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeSteals.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awaySteals.stringValue;
                                 }),
                    teamStatsRow(@"Blocked Shots",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeBlockedShots.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayBlockedShots.stringValue;
                                 }),
                    teamStatsRow(@"Shots on Goal",
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.homeShotsOnGoal.stringValue;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     return game.awayShotsOnGoal.stringValue;
                                 }),
                    teamStatsRow(@"\t1st",
                                 ^NSString *(FSPHockeyGame *game) {
                                    NSArray *homeTeamStats = [game.homePeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @1) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.awayPeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @1) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 }),
                    teamStatsRow(@"\t2nd",
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.homePeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @2) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.awayPeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @2) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 }),
                    teamStatsRow(@"\t3rd",
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.homePeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @3) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";;
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.awayPeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @3) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 }),
                    teamStatsRow(@"\tOT",
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.homePeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @4) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 },
                                 ^NSString *(FSPHockeyGame *game) {
                                     NSArray *homeTeamStats = [game.awayPeriodStats allObjects];
                                     for (FSPHockeyPeriodStats *stats in homeTeamStats) {
                                         if (stats.period == @4) {
                                             return stats.shotsOnGoal.stringValue;
                                         }
                                     }
                                     return @"-";
                                 })];
    });
    return rowArray;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *objects = [[UINib nibWithNibName:NSStringFromClass(FSPNHLTeamStatsFullStatsHeaderView.class)
                                       bundle:nil] instantiateWithOwner:self options:nil];
    FSPNHLTeamStatsFullStatsHeaderView *headerView = [objects objectAtIndex:0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [headerView.teamAHeader setTeam:self.game.awayTeam teamColor:self.game.awayTeamColor];
        [headerView.teamBHeader setTeam:self.game.homeTeam teamColor:self.game.homeTeamColor];
    } else { /* assume UIUserInterfaceIdiomPhone */
        [headerView.teamAHeader setTeamWithShortNameDisplay:self.game.awayTeam teamColor:self.game.awayTeamColor];
        [headerView.teamBHeader setTeamWithShortNameDisplay:self.game.homeTeam teamColor:self.game.homeTeamColor];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FSPNHLTeamStatsFullStatsHeaderViewHeightPoints;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FSPNHLTeamStatsFullStatsRowHeightPoints;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
