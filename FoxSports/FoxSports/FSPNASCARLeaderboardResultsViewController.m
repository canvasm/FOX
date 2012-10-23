//
//  FSPNASCARLeaderboardResultsViewController.m
//  FoxSports
//
//  Created by Stephen Spring on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardResultsViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPNASCARLeaderboardResultsCell.h"
#import "FSPNASCARLeaderboardSectionHeaderView.h"
#import "FSPRacingPlayer.h"
#import "FSPNASCARDriverDetailViewController.h"
#import "FSPExtendedEventDetailManaging.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

@interface FSPNASCARLeaderboardResultsViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, FSPExtendedEventDetailManaging>

@end

@implementation FSPNASCARLeaderboardResultsViewController

- (void)viewDidLoad
{
    // Needs to be called before superclass
    UINib *nib = [UINib nibWithNibName:@"FSPNASCARLeaderboardResultsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:FSPNASCARLeaderboardResultsCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Overridden Methods

- (void)fetchData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"race == %@ AND positionInRace != 0", self.currentEvent];

    if (!self.fetchedResultsController) {
        NSManagedObjectContext *context = [[FSPCoreDataManager sharedManager] GUIObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPRacingPlayer"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"positionInRace" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:predicate];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
    } else {
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    NSAssert(!error, @"FSPNASCARLeaderboardViewController: Error fetching FSPRacingPlayers (%@)", [error localizedDescription]);
    
    [self updateViewForNewData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *indexPaths = [self setIndexPathsForReloadWithSelectedIndexPath:indexPath];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        FSPRacingPlayer *driver = [self.fetchedResultsController objectAtIndexPath:indexPath];
        FSPNASCARDriverDetailViewController *driverDetailVC = [[FSPNASCARDriverDetailViewController alloc] init];
        driverDetailVC.driver = driver;
        FSPAppDelegate *delegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.rootViewController presentViewController:driverDetailVC animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPNASCARLeaderboardResultsCell *cell = (FSPNASCARLeaderboardResultsCell *)[tableView dequeueReusableCellWithIdentifier:FSPNASCARLeaderboardResultsCellIdentifier];
    
    if (cell == nil) {
        cell = [[FSPNASCARLeaderboardResultsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FSPNASCARLeaderboardResultsCellIdentifier];
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] < 1) {
        return cell;
    }
    
    FSPRacingPlayer *driverAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell populateWithPlayer:driverAtIndexPath];
    
    [cell setDisclosureViewVisible:NO];
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        [cell setDisclosureViewVisible:YES];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPRacingPlayer *driverAtIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat unselectedRowHeight = [FSPNASCARLeaderboardResultsCell unselectedRowHeight];
    CGFloat minimumHeight = [FSPNASCARLeaderboardResultsCell minimumRowHeight];
    CGFloat driverDetailViewHeight = [FSPNASCARLeaderboardResultsCell playerDetailViewHeight];
    CGFloat heightForCellCountingSeasons = unselectedRowHeight + (driverDetailViewHeight * [driverAtIndexPath.seasons count]);
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
    return [FSPNASCARLeaderboardSectionHeaderView headerHeightForType:FSPNASCARLeaderboardSectionHeaderTypeResults];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FSPNASCARLeaderboardSectionHeaderView *headerView = [[FSPNASCARLeaderboardSectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, [FSPNASCARLeaderboardSectionHeaderView headerHeightForType:FSPNASCARLeaderboardSectionHeaderTypeResults]) type:FSPNASCARLeaderboardSectionHeaderTypeResults];
    
    // TODO: Use the following code to name the sections properly once "My Leaderboard" is implemented.
    //     id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    //    headerView.titleLabel.text = [sectionInfo name];
    
    return headerView; 
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self updateViewForNewData];
}

@end
