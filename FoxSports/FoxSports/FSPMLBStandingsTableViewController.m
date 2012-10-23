//
//  FSPMLBStandingsViewController.m
//  FoxSports
//
//  Created by Laura Savino on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBStandingsTableViewController.h"
#import "FSPTeam.h"
#import "FSPStandingsCell.h"
#import "FSPMLBStandingsCell.h"
#import "FSPStandingsSectionHeaderView.h"

static const NSInteger FSPMLBWildCardTeamCount = 5;
static NSString * const FSPMLBStandingsSectionHeaderViewNibName = @"FSPMLBStandingsSectionHeaderView";

@interface FSPMLBStandingsTableViewController ()

@property (nonatomic, strong) NSArray *wildCardTeams;

/**
 * Returns the team to display at a given index path (taking wild card teams
 * into account).
 */
- (FSPTeam *)teamForIndexPath:(NSIndexPath *)indexPath;

/**
 * Given all teams for a conference, returns teams eligible for wild card standings by removing division leaders (including any ties).
 */
- (NSArray *)wildCardEligibleTeamsFromTeams:(NSArray *)allTeams;

@end

@implementation FSPMLBStandingsTableViewController

@synthesize wildCardTeams = _wildCardTeams;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Account for 'wild card' section
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if ((NSUInteger)section < [[self.fetchedResultsController sections] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return FSPMLBWildCardTeamCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
  cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPStandingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPStandingsCellReuseIdentifier];
    
    if ((NSUInteger)indexPath.section < [[self.fetchedResultsController sections] count])
        [cell populateWithTeam:[self teamForIndexPath:indexPath]];
    else
        [(FSPMLBStandingsCell *)cell populateWithWildcardTeam:[self teamForIndexPath:indexPath]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UINib *headerNib = [UINib nibWithNibName:FSPMLBStandingsSectionHeaderViewNibName bundle:nil];
    NSArray *topLevelObjects = [headerNib instantiateWithOwner:nil options:nil];

    NSArray *sections = self.fetchedResultsController.sections;
    NSString *sectionName;
    if (section < (NSInteger)sections.count) { 
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        NSArray *divisionComponents = [sectionInfo.name componentsSeparatedByString:@" "];
        NSString *trimmedDivisionName = [divisionComponents objectAtIndex:0];
        sectionName = trimmedDivisionName;
    } else {
        sectionName = @"Wild Card";
    }
    FSPStandingsSectionHeaderView *headerView = (id)[topLevelObjects lastObject];
    headerView.divisionName = sectionName;

    return headerView;
}

- (FSPTeam *)teamForIndexPath:(NSIndexPath *)indexPath;
{
    FSPTeam *team;
    if ((NSUInteger)indexPath.section < [[self.fetchedResultsController sections] count])
        team = [self.fetchedResultsController objectAtIndexPath:indexPath];
    else {
        NSArray *wildCardTeams = self.wildCardTeams;
        if(indexPath.row <= FSPMLBWildCardTeamCount)
            team = [wildCardTeams objectAtIndex:indexPath.row];
    }

    return team;
}

- (NSArray *)wildCardTeams
{
    if (_wildCardTeams)
        return _wildCardTeams;

    NSArray *allTeams = [self.fetchedResultsController fetchedObjects];
    NSArray *wildCardEligibleTeams = [self wildCardEligibleTeamsFromTeams:allTeams];

    //Sort eligible teams
    NSSortDescriptor *wildCardSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"winPercent" ascending:NO comparator:^(NSString *teamFirstWinPercent, NSString *teamSecondWinPercent) {
        NSNumber *teamFirstWildCardWinPercent = @([teamFirstWinPercent floatValue]);
        NSNumber *teamSecondWildCardWinPercent = @([teamSecondWinPercent floatValue]);
        return [teamFirstWildCardWinPercent compare:teamSecondWildCardWinPercent];
    }];

    //Get top wild card teams
    if (wildCardEligibleTeams.count) {
        NSArray *wildCardEligibleTeamsSorted = [wildCardEligibleTeams sortedArrayUsingDescriptors:@[wildCardSortDescriptor]];
        NSInteger wildCardMax = MIN(FSPMLBWildCardTeamCount, (int)wildCardEligibleTeams.count);
        NSRange wildCardRange = NSMakeRange(0, wildCardMax);
        _wildCardTeams = [wildCardEligibleTeamsSorted subarrayWithRange:wildCardRange];
    }

    return _wildCardTeams;
    
}

- (NSArray *)wildCardEligibleTeamsFromTeams:(NSArray *)allTeams;
{
    NSMutableArray *leadingTeams = [[NSMutableArray alloc] init];
    for (FSPTeam *currentTeam in allTeams) {
        if ([currentTeam.divisionGamesBack isEqualToString:@"0"])
            [leadingTeams addObject:currentTeam];
    }
    NSArray *eligibleTeams = [allTeams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", leadingTeams]];
    return eligibleTeams;
}

@end
