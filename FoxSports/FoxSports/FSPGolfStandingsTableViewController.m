//
//  FSPGolfStandingsTableViewController.m
//  FoxSports
//
//  Created by greay on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGolfStandingsTableViewController.h"
#import "FSPPGAStandingsCell.h"
#import "FSPStandingsSectionHeaderView.h"

#import "FSPOrganization.h"
#import "FSPGolfStats.h"

#import "UIColor+FSPExtensions.h"

@interface FSPGolfStandingsTableViewController ()
@property (nonatomic, strong) NSString *standingsType;
@end

@implementation FSPGolfStandingsTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithOrganization:(FSPOrganization *)organization conferenceName:(NSString *)conferenceName
      managedObjectContext:(NSManagedObjectContext *)context standingsType:(NSString *)standingsType
{
	self = [super initWithOrganization:organization conferenceName:conferenceName managedObjectContext:context segment:FSPStandingsTypeConference];
	if (self) {
		self.standingsType = standingsType;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.allowsSelection = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.scrollEnabled = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? NO : YES;
	
	if (self.drawDivider) {
		UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width - 1, 0, 1, self.tableView.bounds.size.height)];
		divider.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
		divider.backgroundColor = [UIColor fsp_colorWithIntegralRed:191 green:191 blue:191 alpha:1.0];
		[self.tableView addSubview:divider];
	}
}


- (NSFetchedResultsController *)fetchedResultsController
{
	if (!_fetchedResultsController) {
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGolfStats"];
		fetchRequest.returnsDistinctResults = YES;
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"scoringAverage > 0 AND branch == %@ ", self.organization.branch];
        BOOL displayAscending = [[self.standingsType lowercaseString] isEqualToString:@"scoringaverage"] ? YES : NO;
		NSSortDescriptor *winningsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.standingsType ascending:displayAscending];
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES];
		fetchRequest.sortDescriptors = @[winningsSortDescriptor, nameSortDescriptor];
		
		[fetchRequest setFetchBatchSize:20];
		
		[NSFetchedResultsController deleteCacheWithName:nil];
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		NSError *error = nil;
		if (![_fetchedResultsController performFetch:&error]) {
		
			NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
			_fetchedResultsController = nil;
		}
	}
	return _fetchedResultsController;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Leave some extra space between the bottom of the last row and the next section.
    int numRowsInsection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == numRowsInsection -1) {
        return 38;
    }
    return 28;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger rows = [sectionInfo numberOfObjects];
	if (rows > 10 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) rows = 10;
	
	return rows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
	FSPStandingsSectionHeaderView *headerView = (FSPStandingsSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    headerView.backgroundColor = [UIColor whiteColor];
	
	for (UILabel *label in headerView.columnHeadingLabels) {
		if ([label isEqual:headerView.sectionNameLabel]) {
			// this is the name label
			if ([self.standingsType isEqualToString:@"earnings"]) {
				label.text = @"Money Leaders";
			} else if ([self.standingsType isEqualToString:@"points"]) {
				label.text = @"FedEx Cup Points Leaders";
			} else if ([self.standingsType isEqualToString:@"worldRankingPoints"]) {
				label.text = @"World Ranking Leaders";
			} else if ([self.standingsType isEqualToString:@"scoringAverage"]) {
				label.text = @"Scoring Average Leaders";
			}
			label.hidden = NO;

		} else {
			// this is the value label
			if ([self.standingsType isEqualToString:@"earnings"]) {
				label.text = @"Winnings";
			} else if ([self.standingsType isEqualToString:@"points"]) {
				label.text = @"Cup Points";
			} else if ([self.standingsType isEqualToString:@"worldRankingPoints"]) {
				label.text = @"Avg Points";
			} else if ([self.standingsType isEqualToString:@"scoringAverage"]) {
				label.text = @"Average";
			}
		}
	}
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPPGAStandingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPStandingsCellReuseIdentifier];
    
	FSPGolfStats *stats = [self.fetchedResultsController objectAtIndexPath:indexPath];
	FSPPGAStandingsCell *golfCell = (FSPPGAStandingsCell *)cell;

	// [golfCell setRank:stats.worldRanking];
	[golfCell setRank:@(indexPath.row + 1)];
	[golfCell setPlayerName:stats.playerName];
    if ([self.standingsType isEqualToString:@"worldRankingPoints"]) {
		[golfCell loadImageFromURL:[NSURL URLWithString:stats.symbolUrl]];
	}
    if ([self.standingsType isEqualToString:@"earnings"]) {
        [golfCell setDetailText:stats.earningsString];
	} else if ([self.standingsType isEqualToString:@"points"]) {
        [golfCell setDetailText:stats.pointsString];
	} else {
        [golfCell setDetailText:[[stats valueForKey:self.standingsType] stringValue]];
	}
    
    return cell;
}


@end
