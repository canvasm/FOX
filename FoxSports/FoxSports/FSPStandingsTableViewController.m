//
//  FSPStandingsTableViewController.m
//  FoxSports
//
//  Created by Laura Savino on 4/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsTableViewController.h"
#import "FSPOrganization.h"
#import "FSPStandingsSectionHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "FSPRacingEvent.h"
#import "FSPTeam.h"
#import "FSPTeamRanking.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPGolfStats.h"
#import "FSPTennisSeasonStats.h"
#import "FSPRankingsTableFooterView.h"

#import "FSPStandingsCell.h"
#import "FSPSoccerStandingsCell.h"
#import "FSPNHLStandingsCell.h"
#import "FSPNASCARStandingsCell.h"
#import "FSPPGAStandingsCell.h"
#import "FSPTennisStandingsCell.h"
#import "FSPRankingsCell.h"

#import "UIFont+FSPExtensions.h"

static NSString * const FSPNBAStandingsSectionHeaderViewNibName = @"FSPNBAStandingsSectionHeaderView";
static NSString * const FSPNFLStandingsSectionHeaderViewNibName = @"FSPNFLStandingsSectionHeaderView";
static NSString * const FSPNASCARStandingsSectionHeaderViewNibName = @"FSPNASCARStandingsSectionHeaderView";
static NSString * const FSPNHLStandingsSectionHeaderViewNibName = @"FSPNHLStandingsSectionHeaderView";
static NSString * const FSPSoccerStandingsSectionHeaderViewNibName = @"FSPSoccerStandingsSectionHeaderView";
static NSString * const FSPPGAStandingsSectionHeaderViewNibName = @"FSPPGAStandingsSectionHeaderView";
static NSString * const FSPTennisStandingsSectionHeaderViewNibName = @"FSPTennisStandingsSectionHeaderView";
static NSString * const FSPRankingsSectionHeaderViewNibName = @"FSPRankingSectionHeaderView";


NSString * const FSPStandingsCellReuseIdentifier = @"FSPStandingsCellReuseIdentifier";
NSString * const FSPRankingsCellReuseIdentifier = @"FSPRankingsCellReuseIdentifier";

@interface FSPStandingsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) FSPOrganization *organization;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *conferenceName;
@property (nonatomic) FSPStandingsSegmentSelected standingsSegmentSelected;

@property (nonatomic, strong) NSArray *rankingsDroppedTeams;
@property (nonatomic, strong) NSArray *rankingsOtherTeams;

- (void)refreshFetchedResultsController;
@end

@implementation FSPStandingsTableViewController

- (id)initWithOrganization:(FSPOrganization *)organization conferenceName:(NSString *)conferenceName
      managedObjectContext:(NSManagedObjectContext *)context segment:(FSPStandingsSegmentSelected)standingsType
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    self.organization = organization;
    self.conferenceName = (conferenceName) ? conferenceName : @"";
    self.managedObjectContext = context;
    self.standingsSegmentSelected = standingsType;

    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	NSString *conferenceCellNibName;
	
	switch (self.organization.viewType) {
		case FSPBasketballViewType:
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
            if ([self.organization isTop25]) {
                conferenceCellNibName = @"FSPRankingsCell";
            }
            else {
                conferenceCellNibName = @"FSPNBAStandingsCell";
            }
			break;
		case FSPBaseballViewType:
			conferenceCellNibName = @"FSPMLBStandingsCell";
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			conferenceCellNibName = @"FSPNFLStandingsCell";
			break;
        case FSPRacingViewType:
            conferenceCellNibName = @"FSPNASCARStandingsCell";
            break;
        case FSPHockeyViewType:
            conferenceCellNibName = @"FSPNHLStandingsCell";
			break;
		case FSPFightingViewType:
			conferenceCellNibName = @"FSPFightingStandingsCell";
            break;
        case FSPSoccerViewType:
            conferenceCellNibName = @"FSPSoccerStandingsCell";
			break;
		case FSPGolfViewType:
			conferenceCellNibName = @"FSPPGAStandingsCell";
			break;
        case FSPTennisViewType:
            conferenceCellNibName = @"FSPTennisStandingsCell";
            break;
		default:
			break;
	}
	
    UINib *conferenceCellNib = [UINib nibWithNibName:conferenceCellNibName bundle:nil];
    UINib *top25CellNib = [UINib nibWithNibName:@"FSPRankingsCell" bundle:nil];
    [self.tableView registerNib:conferenceCellNib forCellReuseIdentifier:FSPStandingsCellReuseIdentifier];
    [self.tableView registerNib:top25CellNib forCellReuseIdentifier:FSPRankingsCellReuseIdentifier];
	
    if (!(self.organization.viewType == FSPRacingViewType || self.organization.viewType == FSPGolfViewType)) {
        CGRect tableViewHeaderFrame = CGRectMake(0, 0, self.tableView.frame.size.width, 30.0);
        
        FSPStandingsScheduleSectionHeader *tableHeaderView = [[FSPStandingsScheduleSectionHeader alloc] initWithFrame:tableViewHeaderFrame];
        switch (self.organization.viewType) {
			case FSPHockeyViewType:
            case FSPSoccerViewType:
				tableHeaderView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ Conference", self.conferenceName];
				break;
			case FSPNFLViewType:
			case FSPNCAAFViewType:
				if ([self.conferenceName isEqualToString:@"AFC"]) {
					tableHeaderView.sectionTitleLabel.text = @"American Football Conference";
				} else if ([self.conferenceName isEqualToString:@"NFC"]) {
					tableHeaderView.sectionTitleLabel.text = @"National Football Conference";
				}
                break;
			default:
                if ([self.organization isTop25]) {
                    if ([self.pollType isEqualToString:FSPTeamRankingAPPollTypeKey]) {
                        tableHeaderView.sectionTitleLabel.text = @"AP Top 25";
                    }
                    else if ([self.pollType isEqualToString:FSPTeamRankingUsaTodayPollTypeKey]) {
                        tableHeaderView.sectionTitleLabel.text = @"USA Today Top 25";
                    }
                }
                else {
				tableHeaderView.sectionTitleLabel.text = self.conferenceName;
                }
				break;
		}
        self.tableView.tableHeaderView = tableHeaderView;
        if ([self.organization isTop25]) {
            self.tableView.tableFooterView = [[FSPRankingsTableFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
            ((FSPRankingsTableFooterView *)self.tableView.tableFooterView).delegate = self;
        }
    }

}

#pragma mark Custom getters and setters

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
	switch (self.organization.viewType) {
		case FSPRacingViewType:
			[self refreshDriverFetchedResultsController];
			break;
		case FSPNCAAFViewType:
		case FSPNCAABViewType:
		case FSPNCAAWBViewType:
            if ([self.organization isTop25]) {
                [self refreshRankingsFetchedResultsController];
            }
            else {
                [self refreshNCAAFootballFetchedResultsController];
            }
			break;
		case FSPSoccerViewType:
			[self refreshSoccerFetchedResultsController];
			break;
		case FSPNFLViewType:
		case FSPBaseballViewType:
			[self refreshFetchedResultsController];
			break;
        case FSPTennisViewType:
            [self refreshTennisFetchedResultsController];
            break;
		default:
			switch (self.standingsSegmentSelected) {
				case FSPStandingsTypeConference:
					[self refreshFetchedResultsControllerForConference];
					break;
				case FSPStandingsTypeDivision:
					[self refreshFetchedResultsControllerForDivision];
					break;
			}
			break;
	}
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark Data refreshing

- (void)refreshFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
    NSPredicate *predicate;
    NSSortDescriptor *sectionSortDescriptor;
    NSString *sectionNameKeyPath;

    // https://ubermind.jira.com/browse/FSTOGOIOS-2037
    // FSPTeams are not a child of themselves, or at least as not as far as Core Data is concerned.
    if ([[self.organization class] isSubclassOfClass:[FSPTeam class]]) {
        predicate = [NSPredicate predicateWithFormat:@"conferenceName MATCHES %@", self.conferenceName];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(conferenceName MATCHES %@) AND (SELF IN %@)", self.conferenceName, self.organization.teams];
    }
    sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"divisionName" ascending:YES];
    sectionNameKeyPath = @"divisionName";
    
    fetchRequest.predicate = predicate;
    NSSortDescriptor *winPercentSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"winPercent" ascending:NO];
    NSSortDescriptor *alphabeticalSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sectionSortDescriptor, winPercentSortDescriptor, alphabeticalSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshFetchedResultsControllerForConference
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"conferenceName == %@ AND branch == %@", self.conferenceName, self.organization.branch];
    
    fetchRequest.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conferenceRanking" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshFetchedResultsControllerForDivision
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"divisionName == %@ AND branch == %@", self.conferenceName, self.organization.branch];
    
    fetchRequest.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conferenceRanking" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshSoccerFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
	fetchRequest.returnsDistinctResults = YES;
    NSArray *heigharchies = [self.organization.currentHierarchyInfo allObjects];
    FSPOrganizationHierarchyInfo *info = [heigharchies objectAtIndex:0];
    NSLog(@"Heigharchies:%@", info.currentOrg);
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY currentHierarchyInfo.branch == %@ AND conferenceName MATCHES %@", info.branch, self.conferenceName];
    NSSortDescriptor *winningsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
    fetchRequest.sortDescriptors = @[winningsSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshDriverFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPRacingSeasonStats"];
	fetchRequest.returnsDistinctResults = YES;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@", self.organization.branch];
    NSSortDescriptor *winningsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
    fetchRequest.sortDescriptors = @[winningsSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshTennisFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTennisSeasonStats"];
	fetchRequest.returnsDistinctResults = YES;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@", self.organization.branch];
    NSSortDescriptor *winningsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    fetchRequest.sortDescriptors = @[winningsSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshNCAAFootballFetchedResultsController
{
    // TODO: refactor so we don't have to dup this method again
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
    NSPredicate *predicate;
    NSSortDescriptor *sectionSortDescriptor;
    NSString *sectionNameKeyPath;

	FSPOrganization *org = self.organization;
	if ([org.type isEqualToString:FSPOrganizationTeamType]) {
		org = [[org highestLevel] parentOrg];
	}
	
    predicate = [NSPredicate predicateWithFormat:@"allParents contains %@", org];
    
    sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"divisionName" ascending:YES];
    sectionNameKeyPath = @"divisionName";
    
    fetchRequest.predicate = predicate;
    NSSortDescriptor *winPercentSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"winPercent" ascending:NO];
    NSSortDescriptor *alphabeticalSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sectionSortDescriptor, winPercentSortDescriptor, alphabeticalSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    [self.tableView reloadData];
}

- (void)refreshRankingsFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeamRanking"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pollType == %@ AND team.branch == %@ AND rank > 0", self.pollType, self.organization.branch];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *rankingsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    fetchRequest.sortDescriptors = @[rankingsSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
    }
    [self.tableView reloadData];
}

- (void)refreshStandings;
{
    [self.tableView reloadData];
    [self.delegate standingsTableViewDidUpdate:self.tableView];
}

- (void)resetWithNewOrganization:(FSPOrganization *)organization {
    _fetchedResultsController = nil;
    self.organization = organization;
    if (self.pollType != nil) {
        [self updateRankingsTableFooter];
    }
    [self.tableView reloadData];
}

#pragma mark - Top 25 Rankings
- (void) updateRankingsTableFooter {
    ((FSPRankingsTableFooterView *)self.tableView.tableFooterView).droppedTeams = [self rankingsDroppedTeamsString];
    ((FSPRankingsTableFooterView *)self.tableView.tableFooterView).otherTeams = [self rankingOtherTeamsString];    
    [((FSPRankingsTableFooterView *)self.tableView.tableFooterView) setNeedsLayout];
}


- (NSArray *)rankingsDroppedTeams
{
    if (!_rankingsDroppedTeams) {
        NSMutableArray *dropped = [NSMutableArray array];
        NSArray *allRankings = [self.fetchedResultsController fetchedObjects];
        for (FSPTeamRanking *ranking in allRankings) {
            if (ranking.rank.intValue > 25 || ranking.rank.intValue == 0) {
                if (ranking.dropped.boolValue) {
                    [dropped addObject:ranking];
                }
            }
        }
        _rankingsDroppedTeams = dropped;
    }
    return _rankingsDroppedTeams;
}

- (NSArray *)rankingsOtherTeams
{
    if (!_rankingsOtherTeams) {
        NSMutableArray *otherTeams = [NSMutableArray array];
        NSArray *allRankings = [self.fetchedResultsController fetchedObjects];
        for (FSPTeamRanking *ranking in allRankings) {
            if (ranking.rank.intValue > 25 || ranking.rank.intValue == 0) {
                if (!ranking.dropped.boolValue) {
                    [otherTeams addObject:ranking];
                }
            }
        }
        _rankingsOtherTeams = otherTeams;
    }
    return _rankingsOtherTeams;
}

- (NSString *)rankingsDroppedTeamsString
{
    if (self.rankingsDroppedTeams.count) {
        __block NSMutableString *droppedString = [NSMutableString string];
        [droppedString appendString:@"Dropped from rankings: "];
        [self.rankingsDroppedTeams enumerateObjectsUsingBlock:^(FSPTeamRanking *ranking, NSUInteger idx, BOOL *stop) {
            [droppedString appendFormat:@"%@ %@", ranking.team.shortNameDisplayString, ranking.points];
            if (idx < self.rankingsDroppedTeams.count - 1) {
                [droppedString appendString:@", "];
            }
        }];
        return droppedString;
    }
    return nil;
}

- (NSString *)rankingOtherTeamsString
{
    if (self.rankingsOtherTeams.count) {
        __block NSMutableString *otherTeamsString = [NSMutableString string];
        [otherTeamsString appendString:@"Others Receiving Votes: "];
        [self.rankingsOtherTeams enumerateObjectsUsingBlock:^(FSPTeamRanking *ranking, NSUInteger idx, BOOL *stop) {
            [otherTeamsString appendFormat:@"%@ %@", ranking.team.shortNameDisplayString, ranking.points];
            if (idx < self.rankingsOtherTeams.count - 1) {
                [otherTeamsString appendString:@", "];
            }
        }];
        return otherTeamsString;
    }
    return nil;
}

- (void)rankingsFooterDidFinishLayout
{
    // On the iPad, the table content view needs to be resized to include
    // the footer height, otherwise the footer floats on top of the table.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize wholesize =  self.tableView.contentSize;
        wholesize.height = self.tableView.contentSize.height + self.tableView.tableFooterView.frame.size.height;
        self.tableView.contentSize = wholesize;
    }
}


#pragma mark - UITableViewDataSource

- (id <NSFetchedResultsSectionInfo>)sectionAtIndex:(NSInteger)index
{
	NSInteger section = index;
	if ([self.organization.branch isEqualToString:FSPNFLEventBranchType]) {
		switch (index) {
			case 0:
				section = 0; // EAST
				break;
			case 1:
				section = 3; // WEST
				break;
			case 2:
				section = 1; // NORTH
				break;
			case 3:
				section = 2; // SOUTH
				break;
		}
	}
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return sectionInfo;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [[self.fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSUInteger numberOfRows = [[self sectionAtIndex:section] numberOfObjects];
    
    // If this is a poll, the max number of rows is 25.  Sometimes rankings returns more than 25 ranked teams.
    if (self.pollType != nil) {
        numberOfRows  = numberOfRows > 25 ? 25 : numberOfRows;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPTeam *teamAtIndexPath = nil;
    FSPTeamRanking *rankingAtIndexPath = nil;
    if ([self.organization isTop25]) {
        rankingAtIndexPath = [[[self sectionAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
    }
    else {
        if ([self.organization.branch isEqualToString:FSPNFLEventBranchType]) {
            teamAtIndexPath = [[[self sectionAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
        } else {
            teamAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    
    FSPStandingsCell *cell = nil;
    if ([self.organization isTop25]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:FSPRankingsCellReuseIdentifier];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:FSPStandingsCellReuseIdentifier];
    }
    
	switch (self.organization.viewType) {    
		case FSPRacingViewType: {
			FSPRacingSeasonStats *stats = [self.fetchedResultsController objectAtIndexPath:indexPath];
			[(FSPNASCARStandingsCell *)cell populateWithStats:stats];
			break;
		}
		case FSPHockeyViewType:
			[(FSPNHLStandingsCell *)cell populateWithTeam:teamAtIndexPath conferenceType:self.standingsSegmentSelected];
			break;
		case FSPSoccerViewType:
			[(FSPSoccerStandingsCell *)cell populateWithTeam:teamAtIndexPath organization:self.organization rank:[indexPath row] + 1];
			break;
        case FSPTennisViewType: {
            FSPTennisSeasonStats *stats = [self.fetchedResultsController objectAtIndexPath:indexPath];
			[(FSPTennisStandingsCell *)cell populateWithStats:stats];
			break;
        }
		default:
            if ([self.organization isTop25]) {
                [(FSPRankingsCell *)cell populateWithTeam:rankingAtIndexPath];
            }
            else {
                [cell populateWithTeam:teamAtIndexPath];
            }
			break;
	}
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    NSString *headerViewNibName;
	switch (self.organization.viewType) {
		case FSPBasketballViewType:
		case FSPNCAABViewType:
		case FSPNCAAWBViewType:
            if ([self.organization isTop25]) {
                headerViewNibName = FSPRankingsSectionHeaderViewNibName;
            }
            else {
                headerViewNibName = FSPNBAStandingsSectionHeaderViewNibName;
            }
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
            if ([self.organization isTop25]) {
                headerViewNibName = FSPRankingsSectionHeaderViewNibName;
            }
            else {
                headerViewNibName = FSPNFLStandingsSectionHeaderViewNibName;
            }
			break;
		case FSPRacingViewType:
			headerViewNibName = FSPNASCARStandingsSectionHeaderViewNibName;
			break;
		case FSPHockeyViewType:
			headerViewNibName = FSPNHLStandingsSectionHeaderViewNibName;
			break;
		case FSPSoccerViewType:
			headerViewNibName = FSPSoccerStandingsSectionHeaderViewNibName;
			break;
		case FSPGolfViewType:
			headerViewNibName = FSPPGAStandingsSectionHeaderViewNibName;
			break;
        case FSPTennisViewType:
            headerViewNibName = FSPTennisStandingsSectionHeaderViewNibName;
            break;
		default:
			break;
	}

    UINib *headerNib = [UINib nibWithNibName:headerViewNibName bundle:nil];
    NSArray *topLevelObjects = [headerNib instantiateWithOwner:nil options:nil];

    id <NSFetchedResultsSectionInfo> sectionInfo = [self sectionAtIndex:section];
    NSString *sectionName = sectionInfo.name;
    FSPStandingsSectionHeaderView *headerView = (id)[topLevelObjects lastObject];
    
    if (self.organization.viewType == FSPNFLViewType) {
        sectionName = [sectionName stringByReplacingOccurrencesOfString:@"AFC" withString:@""];
        sectionName = [sectionName stringByReplacingOccurrencesOfString:@"NFC" withString:@""];
    }
    
    headerView.divisionName = sectionName;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Leave some extra space between the bottom of the last row and the next section.
    int numRowsInsection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == numRowsInsection -1) {
        return 40;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return FSPNBAStandingsDivisionSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    // Calculating footer height for iPad is handled by the FSPRankingsTableFooterView and returned
    // via rankingsFooterDidFinishLayout.  This is so the tableview's content size can be recalculated,
    // to prevent the footers from floating over the tables.  iPhone is handled in standard way.
    if ([self.organization isTop25] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                
        CGFloat headerHeight = 0;
        UIFont  *labelFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        CGSize constraintSize = CGSizeMake(self.tableView.frame.size.width - 20 ,1000);
        
        CGSize droppedSize = [[self rankingsDroppedTeamsString] sizeWithFont:labelFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        headerHeight = droppedSize.height;

        CGSize otherSize = [[self rankingOtherTeamsString] sizeWithFont:labelFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        headerHeight = headerHeight + otherSize.height;
        
        headerHeight = headerHeight + 30;
        return headerHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self.organization isTop25] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return  self.tableView.tableFooterView;
    }
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end

