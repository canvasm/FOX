//
//  FSPNFLTeamStatsFullStatsViewController.m
//  FoxSports
//
//  Created by Ed McKenzie on 7/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamStatsFullStatsViewController.h"
#import "FSPNFLTeamStatsFullStatsCell.h"
#import "FSPNFLTeamStatsFullStatsHeaderView.h"
#import "FSPGameDetailTeamHeader.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPFootballGame.h"

@interface FSPNFLTeamStatsFullStatsViewController ()

+ (NSArray *)teamStatsRowArray;

@end

typedef NSString *(^FSPNFLTeamStatsGamePropertyBlock)(FSPFootballGame *game);

@implementation FSPNFLTeamStatsFullStatsViewController

@synthesize game = _game;

static NSString *FSPNFLTeamStatsFullStatsCellIdentifier = @"FSPNFLTeamStatsFullStatsCellIdentifier";
static CGFloat FSPNFLTeamStatsFullStatsHeaderViewHeightPoints = 57.0;
static CGFloat FSPNFLTeamStatsFullStatsRowHeightPoints = 28.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPNFLTeamStatsFullStatsCell" bundle:nil]
         forCellReuseIdentifier:FSPNFLTeamStatsFullStatsCellIdentifier];
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
    FSPNFLTeamStatsFullStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPNFLTeamStatsFullStatsCellIdentifier];

    void(^StyleTopLevelLabel)(UILabel *) = ^(UILabel *label) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor fsp_blackDropShadowColor];
        label.shadowOffset = CGSizeMake(1, 1);
    };
    
    void(^StyleSectionLabel)(UILabel *) = ^(UILabel *label) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        label.textColor = [UIColor fsp_lightBlueColor];
        label.shadowColor = [UIColor fsp_blackDropShadowColor];
        label.shadowOffset = CGSizeMake(1, 1);
    };
    
    if (cell) {
        NSDictionary *thisRowInfo = [self.class.teamStatsRowArray objectAtIndex:indexPath.row];
        NSString *rowHeaderText = [thisRowInfo objectForKey:FSPNFLTeamStatsRowDescriptionKey];
        NSParameterAssert(rowHeaderText.length > 0);
        if ([[rowHeaderText substringToIndex:1] isEqualToString:@"\t"]) {
            StyleSectionLabel(cell.rowSubheaderLabel);
            StyleSectionLabel(cell.teamAValue);
            StyleSectionLabel(cell.teamBValue);
            cell.rowHeaderLabel.text = @"";
            cell.rowSubheaderLabel.text = [rowHeaderText substringFromIndex:1];
        } else {
            StyleTopLevelLabel(cell.rowHeaderLabel);
            StyleTopLevelLabel(cell.teamAValue);
            StyleTopLevelLabel(cell.teamBValue);
            cell.rowHeaderLabel.text = rowHeaderText;
            cell.rowSubheaderLabel.text = @"";
        }

        FSPNFLTeamStatsGamePropertyBlock homeTeamInfoBlock = (FSPNFLTeamStatsGamePropertyBlock)[thisRowInfo objectForKey:FSPNFLTeamStatsRowHomeInfoBlockKey];
        FSPNFLTeamStatsGamePropertyBlock awayTeamInfoBlock = (FSPNFLTeamStatsGamePropertyBlock)[thisRowInfo objectForKey:FSPNFLTeamStatsRowAwayInfoBlockKey];
        cell.teamAValue.text = awayTeamInfoBlock(self.game);
        cell.teamBValue.text = homeTeamInfoBlock(self.game);
    }

    return cell;
}

static NSString *FSPNFLTeamStatsRowDescriptionKey = @"FSPNFLTeamStatsRowDescriptionKey";
static NSString *FSPNFLTeamStatsRowHomeInfoBlockKey = @"FSPNFLTeamStatsRowHomeInfoBlockKey";
static NSString *FSPNFLTeamStatsRowAwayInfoBlockKey = @"FSPNFLTeamStatsRowAwayInfoBlockKey";

static NSDictionary *teamStatsRow(NSString *description,
                                  FSPNFLTeamStatsGamePropertyBlock homeTeamInfoBlock,
                                  FSPNFLTeamStatsGamePropertyBlock awayTeamInfoBlock) {
    return @{FSPNFLTeamStatsRowDescriptionKey: description,
            FSPNFLTeamStatsRowHomeInfoBlockKey: homeTeamInfoBlock,
            FSPNFLTeamStatsRowAwayInfoBlockKey: awayTeamInfoBlock};
}

+ (NSArray *)teamStatsRowArray {
    static NSArray *rowArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rowArray = @[teamStatsRow(@"1st Downs",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeFirstDowns.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayFirstDowns.stringValue;
                                 }),
                    teamStatsRow(@"3rd Down Efficiency",
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@%@ ", game.homeThirdDownEfficiency.stringValue, @"%"];
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@%@ ", game.awayThirdDownEfficiency.stringValue, @"%"];
                                 }),
                    teamStatsRow(@"4th Down Efficiency",
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@%@ ", game.homeFourthDownEfficiency.stringValue, @"%"];
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@%@ ", game.awayFourthDownEfficiency.stringValue, @"%"];
                                 }),
                    teamStatsRow(@"Total Yards",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeTotalYards.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayTotalYards.stringValue;
                                 }),
                    teamStatsRow(@"Passing Yards",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeTotalPassingYards.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayTotalPassingYards.stringValue;
                                 }),
                    teamStatsRow(@"\tCompletions-Attempts",
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@-%@",
                                             game.homeTotalPassCompletions,
                                             game.homeTotalPassAttempts];
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%@-%@",
                                             game.awayTotalPassCompletions,
                                             game.awayTotalPassAttempts];
                                 }),
                    teamStatsRow(@"\tYards Per Pass",
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%.1f", [game.homeYardsPerPass floatValue]];
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return [NSString stringWithFormat:@"%.1f", [game.awayYardsPerPass floatValue]];
                                 }),
                    teamStatsRow(@"Rushing Yards",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeTotalRushingYards.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayTotalRushingYards.stringValue;
                                 }),
                    teamStatsRow(@"\tRushing Attempts",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeTotalRushes.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayTotalRushes.stringValue;
                                 }),
                    teamStatsRow(@"\tYards Per Rush",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeYardsPerRush;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayYardsPerRush;
                                 }),
                    teamStatsRow(@"Interceptions Thrown",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeInterceptionsThrown.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayInterceptionsThrown.stringValue;
                                 }),
                    teamStatsRow(@"Fumbles Lost",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeFumblesLost.stringValue;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayFumblesLost.stringValue;
                                 }),
                    teamStatsRow(@"Time of Possession",
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.homeTimeOfPossession;
                                 },
                                 ^NSString *(FSPFootballGame *game) {
                                     return game.awayTimeOfPossession;
                                 })];
    });
    return rowArray;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *objects = [[UINib nibWithNibName:NSStringFromClass(FSPNFLTeamStatsFullStatsHeaderView.class)
                                       bundle:nil] instantiateWithOwner:self options:nil];
    FSPNFLTeamStatsFullStatsHeaderView *headerView = [objects objectAtIndex:0];
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
    return FSPNFLTeamStatsFullStatsHeaderViewHeightPoints;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FSPNFLTeamStatsFullStatsRowHeightPoints;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
