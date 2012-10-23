//
//  FSPInjuryReportContainer.m
//  FoxSports
//
//  Created by Laura Savino on 5/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPInjuryReportContainer.h"
#import "FSPGamePreGameViewController.h"
#import "FSPGameDetailTeamHeader.h"
#import "FSPInjuryReportCell.h"
#import "FSPInjuryReportTableHeader.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPPlayerInjury.h"
#import "UIFont+FSPExtensions.h"


static NSInteger kShowMoreRow = 3;

@interface FSPInjuryReportContainer () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FSPGame *currentGame;

@property(nonatomic, weak) IBOutlet UITableView *tableView;
/**
 * Describes whether the injury table contains any injured players.
 */
@property (nonatomic, getter = isEmptyInjuryTableHome, assign) BOOL emptyInjuryTableHome;
@property (nonatomic, getter = isEmptyInjuryTableAway, assign) BOOL emptyInjuryTableAway;

@property (strong, nonatomic) NSFetchedResultsController *homeFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *awayFetchedResultsController;

@property (assign) BOOL showMoreHome;
@property (assign) BOOL showMore;
@property (nonatomic, weak) IBOutlet FSPGamePreGameViewController *parentViewController;

@end

@implementation FSPInjuryReportContainer

@synthesize currentGame = _currentGame;
@synthesize tableView = _tableView;
@synthesize emptyInjuryTableAway = _emptyInjuryTableAway;
@synthesize emptyInjuryTableHome = _emptyInjuryTableHome;
@synthesize informationComplete = _informationComplete;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize homeFetchedResultsController = _homeFetchedResultsController;
@synthesize awayFetchedResultsController = _awayFetchedResultsController;
@synthesize showMoreHome, showMore;
@synthesize parentViewController;

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

- (void)awakeFromNib
{
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPInjuryReportCell" bundle:nil] forCellReuseIdentifier:FSPInjuryReportCellIdentifier];
	self.tableView.rowHeight = 50;
}

- (BOOL)isInformationComplete
{
    if (self.isEmptyInjuryTableAway && self.isEmptyInjuryTableHome)
        return NO;
    else
        return YES;
}

- (void)updateInterfaceWithGame:(FSPGame *)game
{
    self.currentGame = game;
    self.emptyInjuryTableAway = YES;
    self.emptyInjuryTableHome = YES;
	self.showMoreHome = NO;
	self.showMore = NO;
    
    self.homeFetchedResultsController = nil;
    self.awayFetchedResultsController = nil;

    [self.tableView reloadData];
}


#pragma mark - UITableView delegate/data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    FSPInjuryReportTableHeader *headerView = [[FSPInjuryReportTableHeader alloc] initWithFrame:tableView.frame];
    UIFont *injuryReportTeamNameHeaderFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0];
    CGSize injuryReportTeamNameHeaderShadowOffset = CGSizeMake(0, -1.0);

	headerView.teamHeader.teamNameLabel.font = injuryReportTeamNameHeaderFont;
	headerView.teamHeader.teamNameLabel.shadowOffset = injuryReportTeamNameHeaderShadowOffset;
	headerView.teamHeader.teamNameLabel.textColor = [UIColor whiteColor];

	headerView.teamHeaderHome.teamNameLabel.font = injuryReportTeamNameHeaderFont;
	headerView.teamHeaderHome.teamNameLabel.shadowOffset = injuryReportTeamNameHeaderShadowOffset;
	headerView.teamHeaderHome.teamNameLabel.textColor = [UIColor whiteColor];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[headerView.teamHeader setTeam:self.currentGame.awayTeam teamColor:self.currentGame.awayTeamColor];
		[headerView.teamHeaderHome setTeam:self.currentGame.homeTeam teamColor:self.currentGame.homeTeamColor];
	} else {
		if (section == 0) {
			[headerView.teamHeader setTeam:self.currentGame.awayTeam teamColor:self.currentGame.awayTeamColor];
		} else {
			[headerView.teamHeader setTeam:self.currentGame.homeTeam teamColor:self.currentGame.homeTeamColor];
		}
	}
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FSPNBAInjuryReportHeaderHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return 1;
	} else {
		return 2;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if (self.managedObjectContext) {
        id <NSFetchedResultsSectionInfo> sectionInfo;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// for iPad, we take the larger of the two fetch results
			NSInteger awayRows;
            sectionInfo = [[self.awayFetchedResultsController sections] objectAtIndex:0];
			awayRows = [sectionInfo numberOfObjects];
			if (!self.showMore && awayRows > kShowMoreRow) awayRows = kShowMoreRow + 1;
			
			NSInteger homeRows;
			sectionInfo = [[self.homeFetchedResultsController sections] objectAtIndex:0];
            homeRows = [sectionInfo numberOfObjects];
			if (!self.showMore && homeRows > kShowMoreRow)  homeRows = kShowMoreRow + 1;
	
			rows = (awayRows > homeRows) ? awayRows : homeRows;
        } else {
			if (section == 0) {
				sectionInfo = [[self.awayFetchedResultsController sections] objectAtIndex:0];
				rows = [sectionInfo numberOfObjects];
				if (!self.showMore && rows > kShowMoreRow) rows = kShowMoreRow + 1;
			} else {
				sectionInfo = [[self.homeFetchedResultsController sections] objectAtIndex:0];
				rows = [sectionInfo numberOfObjects];
				if (!self.showMoreHome && rows > kShowMoreRow) rows = kShowMoreRow + 1;
			}
		}
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPPlayerInjury *homeInfo;
    FSPPlayerInjury *awayInfo;
    
    //only retrieve an injury object if the table view is not empty.
    if (indexPath.section == 0) {
		// need special handling for iPhone vs. iPad
		if (indexPath.row == kShowMoreRow && !self.showMore) {
			UITableViewCell *moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"more"];
			moreCell.textLabel.text = @"Show more...";
			moreCell.textLabel.textAlignment = UITextAlignmentCenter;
			moreCell.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
			moreCell.textLabel.textColor = [UIColor whiteColor];
			return moreCell;
		}

        if(self.isEmptyInjuryTableAway) {
            awayInfo = nil;
		} else {
			if ((NSUInteger)indexPath.row < [[self.awayFetchedResultsController fetchedObjects] count]) {
				awayInfo = [self.awayFetchedResultsController objectAtIndexPath:indexPath];
			}
		}

		FSPInjuryReportCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPInjuryReportCellIdentifier];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			if ((NSUInteger)indexPath.row < [[self.homeFetchedResultsController fetchedObjects] count]) {
				homeInfo = [self.homeFetchedResultsController objectAtIndexPath:indexPath];
			}
			[cell populateWithAwayPlayerInjury:awayInfo homePlayerInjury:homeInfo];
		} else {
			[cell populateWithPlayerInjury:awayInfo];
		}
		return cell;
    } else {
		// this is only for iPhone
		if (indexPath.row == kShowMoreRow && !self.showMoreHome) {
			UITableViewCell *moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"more"];
			moreCell.textLabel.textAlignment = UITextAlignmentCenter;
			moreCell.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
			moreCell.textLabel.textColor = [UIColor whiteColor];
			moreCell.textLabel.text = @"Show more...";
			return moreCell;
		}

        if(self.isEmptyInjuryTableHome) {
            homeInfo = nil;
		} else {
            homeInfo = [self.homeFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
		}

		FSPInjuryReportCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPInjuryReportCellIdentifier];
		[cell populateWithPlayerInjury:homeInfo];
		
		return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    if (indexPath.section == 0) {
		if (indexPath.row == kShowMoreRow && !self.showMore) {
			self.showMore = YES;
			[self.tableView reloadData];
			[self.parentViewController updateViewPositions];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	} else {
		if (indexPath.row == kShowMoreRow && !self.showMoreHome) {
			self.showMoreHome = YES;
			[self.tableView reloadData];
			[self.parentViewController updateViewPositions];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = 0;

	NSInteger sections = [self numberOfSectionsInTableView:self.tableView];
	for (NSInteger section = 0; section < sections; section++) {
		height += [self tableView:self.tableView heightForHeaderInSection:section];
		height += self.tableView.rowHeight * [self tableView:self.tableView numberOfRowsInSection:section];
	}
	height += CGRectGetMinY(self.tableView.frame);
    
    return CGSizeMake(size.width, height);
}

#pragma mark - Fetched Results Controllers

- (void)injuryReportDidChangeContent {
    [self.homeFetchedResultsController performFetch:nil];
    if(self.homeFetchedResultsController.fetchedObjects.count == 0)
        self.emptyInjuryTableHome = YES;
    else
        self.emptyInjuryTableHome = NO;

    [self.awayFetchedResultsController performFetch:nil];
    if(self.awayFetchedResultsController.fetchedObjects.count == 0)
        self.emptyInjuryTableAway = YES;
    else
        self.emptyInjuryTableAway = NO;

    if (self.emptyInjuryTableAway && self.emptyInjuryTableHome) {
        self.informationComplete = NO;
    } else {
        self.informationComplete = YES;
        [self updateInterfaceWithGame:self.currentGame];
        [self.tableView reloadData];
    }
}

- (NSFetchedResultsController *)homeFetchedResultsController
{
    if(_homeFetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPPlayerInjury"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier == %@ && teamIdentifier == %@", self.currentGame.uniqueIdentifier, self.currentGame.homeTeam.uniqueIdentifier];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:NO];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        [fetchRequest setFetchBatchSize:20];
        
        _homeFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _homeFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_homeFetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _homeFetchedResultsController = nil;
        }
        
        if (_homeFetchedResultsController.fetchedObjects.count == 0)
            self.emptyInjuryTableHome = YES;
        else
            self.emptyInjuryTableHome = NO;
    }
    return _homeFetchedResultsController;
}

- (NSFetchedResultsController *)awayFetchedResultsController
{
    if(_awayFetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPPlayerInjury"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier == %@ && teamIdentifier == %@", self.currentGame.uniqueIdentifier, self.currentGame.awayTeam.uniqueIdentifier];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:NO];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        [fetchRequest setFetchBatchSize:20];
        
        _awayFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _awayFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_awayFetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _awayFetchedResultsController = nil;
        }

        if (_awayFetchedResultsController.fetchedObjects.count == 0)
            self.emptyInjuryTableAway = YES;
        else
            self.emptyInjuryTableAway = NO;

    }
    
    return _awayFetchedResultsController;
}


#pragma mark - NSFetchedResultsControllerDelegate implementation

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == _awayFetchedResultsController || controller == _homeFetchedResultsController) {
        [self.tableView reloadData];
    }
}

@end
