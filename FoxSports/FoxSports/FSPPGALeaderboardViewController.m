//
//  FSPPGALeaderboardViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGALeaderboardViewController.h"
#import "FSPPGALeaderBoardCell.h"
#import "FSPPGAEvent.h"
#import "FSPCoreDataManager.h"
#import "FSPPGALeaderboardTableViewSectionHeader.h"
#import "FSPPGAGolferDetailViewController.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

static NSString *CellIdentifier = @"FSPPGALeaderboardCellIdentifier";

@interface FSPPGALeaderboardViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) FSPPGAGolferDetailViewController *golferDetailViewController;

@end

@implementation FSPPGALeaderboardViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize golferDetailViewController = _golferDetailViewController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPGolfer"];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"place" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        fetchRequest.sortDescriptors = @[ sortDescriptor, sortDescriptor2 ];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FSPCoreDataManager sharedManager].GUIObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"golfEvent == %@", self.currentEvent];
    _fetchedResultsController.fetchRequest.predicate = predicate;
    return _fetchedResultsController;
}

- (FSPPGAGolferDetailViewController *)golferDetailViewController
{
    if (!_golferDetailViewController) {
        _golferDetailViewController = [[FSPPGAGolferDetailViewController alloc] initWithNibName:@"FSPPGAGolferDetailViewController" bundle:nil];
    }
    return _golferDetailViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"FSPPGALeaderboardCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showNoDataAvailableLabelIfNecessary];
}

- (void)fetchData
{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

- (void)showNoDataAvailableLabelIfNecessary
{
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {
        self.noDataAvailableLabel.hidden = YES;
        self.tableView.hidden = NO;
    } else {
        self.noDataAvailableLabel.hidden = NO;
        self.tableView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPPGALeaderBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FSPGolfer *golfer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell populateWithPlayer:golfer];
    
    [cell setDisclosureViewVisible:NO];
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        [cell setDisclosureViewVisible:YES];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[FSPPGALeaderboardTableViewSectionHeader alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [FSPPGALeaderboardTableViewSectionHeader headerHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat unselectedRowHeight = [FSPPGALeaderBoardCell unselectedRowHeight];
    CGFloat minimumRowHeight = [FSPPGALeaderBoardCell minimumRowHeight];
    CGFloat golferDetailViewHeight = [FSPPGALeaderBoardCell playerDetailViewHeight];
    CGFloat totalViewHeight = unselectedRowHeight + golferDetailViewHeight;
    if ([indexPath isEqual:self.selectedIndexPath]) {
        return minimumRowHeight > totalViewHeight ? minimumRowHeight : totalViewHeight;
    } else {
        return unselectedRowHeight;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *indexPaths = [self setIndexPathsForReloadWithSelectedIndexPath:indexPath];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        FSPGolfer *golfer = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.golferDetailViewController.golfer = golfer;
        FSPAppDelegate *delegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.rootViewController presentModalViewController:self.golferDetailViewController animated:YES];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self showNoDataAvailableLabelIfNecessary];
}

@end
