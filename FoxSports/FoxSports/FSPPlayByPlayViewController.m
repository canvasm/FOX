//
//  FSPNBAPlayByPlayViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 2/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayByPlayViewController.h"
#import "FSPTeamColorLabel.h"
#import "FSPSecondarySegmentedControl.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPOrganization.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPCoreDataManager.h"
#import "FSPBaseballGame.h"
#import "FSPMLBPlayByPlayFooterCell.h"
#import "FSPEvent.h"

#import "FSPPlayByPlayCell.h"
#import "FSPNBAPlayByPlayCell.h"
#import "FSPMLBPlayByPlayCell.h"
#import "FSPNFLPlayByPlayCell.h"
#import "FSPSoccerPlayByPlayCell.h"
#import "FSPNHLPlayByPlayCell.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

static NSString * const cacheName = @"com.foxsports.PlayByPlayCache";
static NSString * const FSPPlayByPlayCellIdentifier = @"FSPPlayByPlayCellIdentifier";


@interface FSPPlayByPlayViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet FSPSecondarySegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSFetchedResultsController *playsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *scoringFetchedResultsController;
@property (nonatomic, strong, readonly) NSFetchedResultsController *currentFetchedResultsController;
@property (weak, nonatomic) IBOutlet UILabel *noDataAvailableLabel;

@end

@implementation FSPPlayByPlayViewController

@synthesize tableView = _tableView;
@synthesize segmentedControl = _segmentedControl;
@synthesize selectedIndex;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize playsFetchedResultsController = _playsFetchedResultsController;
@synthesize scoringFetchedResultsController = _scoringFetchedResultsController;
@synthesize currentFetchedResultsController = _currentFetchedResultsController;
@synthesize noDataAvailableLabel = _noDataAvailableLabel;

- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event;
{
    return @[@"Play By Play", @"Scoring"];
}


- (NSFetchedResultsController *)currentFetchedResultsController;
{
    if (self.selectedIndex == 0)
        return self.playsFetchedResultsController;
    else 
        return self.scoringFetchedResultsController;
}

- (Class)cellClass;
{
	Class cellClass = nil;
	switch (self.currentEvent.viewType) {
		case FSPBasketballViewType:
		case FSPNCAABViewType:
		case FSPNCAAWBViewType:
			cellClass = [FSPNBAPlayByPlayCell class];
			break;
		case FSPBaseballViewType:
			cellClass = [FSPMLBPlayByPlayCell class];
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			cellClass = [FSPNFLPlayByPlayCell class];
			break;
		case FSPSoccerViewType:
			cellClass = [FSPSoccerPlayByPlayCell class];
			break;
		case FSPHockeyViewType:
			cellClass = [FSPNHLPlayByPlayCell class];
			break;
		default:
			cellClass = [FSPPlayByPlayCell class];
			break;
	}
	return cellClass;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    if (_currentEvent != currentEvent) {
        _playsFetchedResultsController.delegate = nil;
        _scoringFetchedResultsController.delegate = nil;
        _playsFetchedResultsController = nil;
        _scoringFetchedResultsController = nil;
        _currentEvent = currentEvent;
        [self selectGameDetailViewAtIndex:0];
        self.noDataAvailableLabel.hidden = NO;
		
		NSString *nibName = NSStringFromClass([self cellClass]);
		if (nibName) {
			[self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:FSPPlayByPlayCellIdentifier];
		}
    }
    if ([[self.currentFetchedResultsController fetchedObjects] count] > 0) {
        self.noDataAvailableLabel.hidden = YES;
    }
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
	self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)viewDidUnload;
{
    [self setNoDataAvailableLabel:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Delegate/Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (!self.currentEvent) return 0;
    return [self.currentFetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.currentFetchedResultsController.sections objectAtIndex:section];
    NSInteger rows = (NSInteger)[sectionInfo numberOfObjects];
	if (self.currentEvent.viewType == FSPBaseballViewType) {
		rows++;
	}
	return rows;
}


#define PLAY_BY_PLAY_HEADER_HEIGHT (30)

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return PLAY_BY_PLAY_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.currentFetchedResultsController.sections objectAtIndex:section];
	FSPGamePlayByPlayItem *item = [[sectionInfo objects] lastObject];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, PLAY_BY_PLAY_HEADER_HEIGHT)];
    headerView.image = [[UIImage imageNamed:@"team_header_bezel"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];

    UILabel *periodTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 2, self.view.bounds.size.width, PLAY_BY_PLAY_HEADER_HEIGHT)];
    periodTitleLabel.backgroundColor = [UIColor clearColor];
    periodTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0f];
    periodTitleLabel.textColor = [UIColor whiteColor];
    periodTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    periodTitleLabel.text = [item periodTitle];
    [headerView addSubview:periodTitleLabel];

	FSPViewType viewType = self.currentEvent.viewType;
    if (viewType == FSPBaseballViewType || viewType == FSPNFLViewType || viewType == FSPNCAAFViewType || viewType == FSPSoccerViewType) {
        headerView.backgroundColor = item.periodBackgroundColor;
        if (headerView.backgroundColor == nil) {
            headerView.backgroundColor = [UIColor colorWithRed:0.00f green:0.18f blue:0.43f alpha:1.00f];;
        }
        
    }
//    else if (viewType == FSPSoccerViewType)
//    {
//        headerView.backgroundColor = item.periodBackgroundColor;
//        periodTitleLabel.textColor = [UIColor whiteColor];
//    }
    else
    {
        headerView.backgroundColor = [UIColor colorWithRed:0.000 green:0.267 blue:0.608 alpha:1.000];
        periodTitleLabel.textColor = [UIColor fsp_yellowColor];
    }
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.currentFetchedResultsController.sections objectAtIndex:indexPath.section];
	if ([self isBaseballSectionSummary:sectionInfo indexPath:indexPath]) {
		FSPPlayByPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPPlayByPlayCellIdentifier];
		if (!cell) {
			cell = [[[self cellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FSPPlayByPlayCellIdentifier];
		}
		FSPGamePlayByPlayItem *playByPlay = [self.currentFetchedResultsController objectAtIndexPath:indexPath];
		[cell populateWithPlayByPlayItem:playByPlay];
	
		return cell;
	} else {
		if (self.currentEvent.viewType == FSPBaseballViewType) {
			FSPGamePlayByPlayItem *item = [[sectionInfo objects] lastObject];
			
			
			FSPMLBPlayByPlayFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLB footer"];
			if (!cell) {
				cell = [[FSPMLBPlayByPlayFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MLB footer"];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			cell.title = [NSString stringWithFormat:@"%@ Run, %@ Hit, %@ Error", item.inningRuns, item.inningHits, item.inningErrors];
			return cell;
		}
		NSLog(@"ERROR: only MLB play-by-play should have a footer.");
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.currentFetchedResultsController.sections objectAtIndex:indexPath.section];

	if (self.currentEvent.viewType == FSPBaseballViewType) {
		if ((NSUInteger)indexPath.row > [sectionInfo numberOfObjects]) {
			return FSPPlayByPlayFooterHeight;
		}
	}
    
    if (self.currentEvent.viewType == FSPBaseballViewType && ![self isBaseballSectionSummary:sectionInfo indexPath:indexPath]) {
        return 44.0;
    }
    
    FSPGamePlayByPlayItem *playByPlayItem = [self.currentFetchedResultsController objectAtIndexPath:indexPath];

    switch (self.currentEvent.viewType) {
        case FSPNFLViewType:
            return [FSPNFLPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
        case FSPBaseballViewType:
            return [FSPMLBPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
        case FSPBasketballViewType:
            return [FSPNBAPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
        case FSPHockeyViewType:
            return [FSPNHLPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
        case FSPSoccerViewType:
            return [FSPSoccerPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
        default:
            return [FSPPlayByPlayCell heightForCellWithPlayByPlayItem:playByPlayItem];
    }
}

- (BOOL)isBaseballSectionSummary:(id<NSFetchedResultsSectionInfo>)sectionInfo indexPath:(NSIndexPath *)indexPath
{
    return (NSUInteger)indexPath.row < [sectionInfo numberOfObjects];
}

#pragma mark - Segmented Control

- (IBAction)segmentedControlUpdate:(UISegmentedControl *)sender;
{
	[self selectGameDetailViewAtIndex:sender.selectedSegmentIndex];
}

- (void)selectGameDetailViewAtIndex:(NSUInteger)index
{
	self.selectedIndex = index;
    if ([[self.currentFetchedResultsController fetchedObjects] count] > 0) {
        self.noDataAvailableLabel.hidden = YES;
    }
    [self.tableView reloadData];
    if ([[[self currentFetchedResultsController] sections] count]) {
        for (NSUInteger i = 0; i < [[[self currentFetchedResultsController] sections] count]; i++) {
            if ([self tableView:self.tableView numberOfRowsInSection:i]) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                break;
            }
        }
    }
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView reloadData];
    self.noDataAvailableLabel.hidden = YES;
}

#define CHRONOLOGICAL_PLAY_BY_PLAY (1)
#define REVERSE_CHRONOLOGICAL_PLAY_BY_PLAY (0)

- (NSFetchedResultsController *)scoringFetchedResultsController;
{
    if (_scoringFetchedResultsController)
        return _scoringFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGamePlayByPlayItem"];
    NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:REVERSE_CHRONOLOGICAL_PLAY_BY_PLAY];
    NSSortDescriptor *sortDescriptorSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:REVERSE_CHRONOLOGICAL_PLAY_BY_PLAY];
    
    fetchRequest.shouldRefreshRefetchedObjects = YES;
    fetchRequest.sortDescriptors = @[sortDescriptorPeriod, sortDescriptorSequence];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"game.uniqueIdentifier == %@ && pointsScored > 0", self.currentEvent.uniqueIdentifier];
    
    _scoringFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"adjustedPeriod" cacheName:nil];
    _scoringFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_scoringFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _scoringFetchedResultsController = nil;
	}
    
    return _scoringFetchedResultsController;
}

- (NSFetchedResultsController *)playsFetchedResultsController;
{
    
    if (_playsFetchedResultsController)
        return _playsFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGamePlayByPlayItem"];
    NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:REVERSE_CHRONOLOGICAL_PLAY_BY_PLAY];
    NSSortDescriptor *sortDescriptorSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:REVERSE_CHRONOLOGICAL_PLAY_BY_PLAY];
    
    fetchRequest.shouldRefreshRefetchedObjects = YES;
    fetchRequest.sortDescriptors = @[sortDescriptorPeriod, sortDescriptorSequence];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"game.uniqueIdentifier == %@", self.currentEvent.uniqueIdentifier];
    
    _playsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"adjustedPeriod" cacheName:nil];
    _playsFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_playsFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _playsFetchedResultsController = nil;
	}
    
    return _playsFetchedResultsController;
}

@end
