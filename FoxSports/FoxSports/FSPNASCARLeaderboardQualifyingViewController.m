//
//  FSPNASCARLeaderboardQualifyingViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardQualifyingViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPNASCARLeaderboardSectionHeaderView.h"
#import "FSPNASCARLeaderboardQualifyingCell.h"
#import "FSPRacingPlayer.h"

@interface FSPNASCARLeaderboardQualifyingViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation FSPNASCARLeaderboardQualifyingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Needs to be called before superclass
    UINib *nib = [UINib nibWithNibName:@"FSPNASCARLeaderboardQualifyingCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:FSPNASCARLeaderboardQualifyingCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Overridden Methods

- (void)fetchData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"race == %@", self.currentEvent];

    if (!self.fetchedResultsController) {
        NSManagedObjectContext *context = [[FSPCoreDataManager sharedManager] GUIObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPRacingPlayer"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"qualifyingSpeed" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"race"]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
    } else {
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    NSAssert(!error, @"FSPNASCARLeaderboardViewController: Error fetching FSPRacingPlayers (%@)", [error localizedDescription]);
    
    [self.tableView reloadData];

    [self updateViewForNewData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPNASCARLeaderboardQualifyingCell *cell = (FSPNASCARLeaderboardQualifyingCell *)[tableView dequeueReusableCellWithIdentifier:FSPNASCARLeaderboardQualifyingCellIdentifier];
    
    if (cell == nil) {
        cell = [[FSPNASCARLeaderboardQualifyingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FSPNASCARLeaderboardQualifyingCellIdentifier];
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] < 1) {
        return cell;
    }
    
    FSPRacingPlayer *driverAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell populateWithPlayer:driverAtIndexPath];
    cell.positionLabel.text = [[NSNumber numberWithInt:[indexPath row] + 1] stringValue];
    [cell setDisclosureViewVisible:NO];
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        [cell setDisclosureViewVisible:YES];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPRacingPlayer *driverAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat unselectedRowHeight = 34.0;
    CGFloat minimumHeight = 134.0;
    CGFloat heightForCellCountingSeasons = unselectedRowHeight + (82.0 * [driverAtIndexPath.seasons count]);
    if ([indexPath isEqual:self.selectedIndexPath]) {
        return minimumHeight > heightForCellCountingSeasons ? minimumHeight : heightForCellCountingSeasons;
    } else {
        return unselectedRowHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [FSPNASCARLeaderboardSectionHeaderView headerHeightForType:FSPNASCARLeaderboardSectionHeaderTypeQualifying];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FSPNASCARLeaderboardSectionHeaderView *headerView = [[FSPNASCARLeaderboardSectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, [FSPNASCARLeaderboardSectionHeaderView headerHeightForType:FSPNASCARLeaderboardSectionHeaderTypeQualifying]) type:FSPNASCARLeaderboardSectionHeaderTypeQualifying];
    return headerView;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self updateViewForNewData];
}

@end
