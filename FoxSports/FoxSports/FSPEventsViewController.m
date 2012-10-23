//
//  FSPAllEventsViewController.m
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FSPEventsViewController.h"
#import "FSPEvent.h"
#import "FSPEventChipsSectionHeader.h"
#import "FSPGameChipCell.h"
#import "FSPTournamentChipCell.h"
#import "FSPOrganization.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPDataCoordinator.h"
#import "UIColor+FSPExtensions.h"
#import "NSUserDefaults+FSPExtensions.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "FSPCustomIndicator.h"
#import "UIFont+FSPExtensions.h"
#import "FSPRankedGameChipCell.h"

//static NSTimeInterval FSPEventRefreshInterval = 15; // 5 minutes = 300

const NSInteger FSPAdSectionIndex = 1;
const NSInteger FSPAdRowIndex = 3;

// Cell identifiers
static NSString *const FSPGameChipIdentifier = @"FSPGameChipIdentifier";
static NSString * const FSPTournamentChipCellIdentifier = @"FSPTournamentChipCellIdentifier";
static NSString * const FSPRankedGameChipCellIdentifier = @"FSPRankedGameChipCellIdentifier";

@interface FSPEventsViewController ()
{
    BOOL hasScrolledToToday;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *noDataAvailable;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id teamUpdateObserver;
@property (nonatomic, weak) id noEventDataFoundObserver;
@property (nonatomic) BOOL needToUpdateSelectionPosition;
@property FSPCustomIndicator *activityIndicator;

#ifdef DEBUG_xmas_loading_time
@property NSDate *updateTime;
#endif


/**
 * The ad to be displayed in every ad cell. 
 */
@property (nonatomic, strong) UIView *adView;

- (NSIndexPath *)indexPathForCurrentEvent;
- (FSPEvent *)eventAtIndexPath:(NSIndexPath *)indexPath;

@end


@implementation FSPEventsViewController


#pragma mark - Custom getters and setters
- (NSString *)lastSelectedEventDefaultsKey
{
	return [NSString stringWithFormat:@"%@/%@", FSPSelectedEventUserDefaultsPrefixKey, self.organization.uniqueIdentifier];
}

- (void)setLastSelectedEventKeyIdentifier:(NSString *)uniqueIdentifier;
{
    [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:[self lastSelectedEventDefaultsKey]];
}

- (void)setSelectedEvent:(FSPEvent *)selectedEvent
{
	if (_selectedEvent != selectedEvent) {
		_selectedEvent = selectedEvent;
		if (selectedEvent && [self lastSelectedEventDefaultsKey]) {
            if ([selectedEvent respondsToSelector:@selector(uniqueIdentifier)]) {
                //[[NSUserDefaults standardUserDefaults] setObject:selectedEvent.uniqueIdentifier forKey:[self lastSelectedEventDefaultsKey]];]
                [self setLastSelectedEventKeyIdentifier:selectedEvent.uniqueIdentifier];
            }
		}
	}
}

- (void)setOrganization:(FSPOrganization *)organization
{
	if (organization != _organization) {
		_organization = organization;
        
        [FSPOrganization endUpdatingOrganziations];
        [self.organization beginUpdating];
        
        
		self.selectedEvent = nil;
		self.fetchedResultsController = nil;
        
	}
}

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest;
    
    if ([self.organization.type isEqualToString:FSPOrganizationTeamType]) {
		// FSPEvent does not have awayTeamIdentifier or homeTeamIdentifier, so we need to search on games
		fetchRequest  = [[NSFetchRequest alloc] initWithEntityName:@"FSPGame"];
        // This is a team so we need to check if the game object contains either the team in the home team id or away team id
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((awayTeamIdentifier == %@) OR (homeTeamIdentifier == %@))", self.organization.uniqueIdentifier, self.organization.uniqueIdentifier];
    } else {
        // We want to get all the events that relate to this type of org
		fetchRequest  = [[NSFetchRequest alloc] initWithEntityName:[self.organization predicateClassString]];
        
        //TODO: is this going to work?
        //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@", self.organization.branch];
        fetchRequest.predicate = [self.organization matchingEventsPredicate];
    }
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    NSSortDescriptor *uniqueIdSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uniqueIdentifier" ascending:YES];
    NSArray *sortDescriptors = @[dateSortDescriptor, uniqueIdSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"startDateGroup" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	} else {
        if (_fetchedResultsController.fetchedObjects.count) {
            [self hideActivityIndicator];
            self.noDataAvailable.hidden = YES;
        }
        
    }
    
    return _fetchedResultsController;
}

#pragma mark - Memory Management

- (void)showActivityIndicator;
{
#if 0
    // activity indicator
    self.activityIndicator = [[FSPCustomIndicator alloc] init];
    [self.tableView addSubview:self.activityIndicator];
    self.activityIndicator.frame = self.tableView.frame;
    [self.activityIndicator startAnimating];
#endif
}

- (void)hideActivityIndicator;
{
#if 0
    [self.activityIndicator removeFromSuperview];
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
#endif
}


#pragma mark - Memory Management
- (id)initWithOrganization:(FSPOrganization *)organization managedObjectContext:(NSManagedObjectContext *)context;
{
    self = [super initWithNibName:@"FSPEventsViewController" bundle:nil];
    if (self) {
        self.managedObjectContext = context;
        self.organization = organization;
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.teamUpdateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.noEventDataFoundObserver];
    _fetchedResultsController.delegate = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noDataAvailable.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:18.0];
    self.noDataAvailable.text = @"No data available";
    self.noDataAvailable.textColor = [UIColor fsp_darkBlueColor];
    self.noDataAvailable.shadowColor = [UIColor fsp_blackDropShadowColor];
    self.noDataAvailable.shadowOffset = CGSizeMake(0, -1);
    self.noDataAvailable.hidden = YES;
    
    self.tableView.accessibilityIdentifier = @"eventsList";
    self.tableView.rowHeight = 98.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height += self.tableView.sectionHeaderHeight;
    self.tableView.contentSize = contentSize;
    
    self.view.backgroundColor = [UIColor fsp_lightGrayColor];
    
    // Register all of our cells with the table view
    [FSPTournamentChipCell registerSelfWithTableView:self.tableView forReuseIdentifier:FSPTournamentChipCellIdentifier];
    [FSPGameChipCell registerSelfWithTableView:self.tableView forReuseIdentifier:FSPGameChipIdentifier];
    [FSPRankedGameChipCell registerSelfWithTableView:self.tableView forReuseIdentifier:FSPRankedGameChipCellIdentifier];
    
    [self.tableView flashScrollIndicators];
    
    // Remove ads for v1.0 release
	if (ADS_ENABLED) {
		[[FSPAdManager sharedManager] requestAdViewForAdType:FSPAdTypeChip delegate:self acceptHouseAd:YES];
		UIImage *houseAdImage = [UIImage imageNamed:@"house-ad-sample-chip"];
		self.adView = [[UIImageView alloc] initWithImage:houseAdImage];
	}
    
	if (self.organization) {
		__weak FSPEventsViewController *weakSelf = self;
		self.teamUpdateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSDictionary *userInfo = [note userInfo];
			NSManagedObjectID *orgId = [userInfo objectForKey:FSPDataCoordinatorUpdatedOrganizationObjectIDKey];
			if ([orgId isEqual:[weakSelf.organization objectID]] || !orgId) {
				NSIndexPath *indexPath = [weakSelf.tableView indexPathForSelectedRow];
				[weakSelf.tableView reloadData];
				[weakSelf.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			}
            self.noEventDataFoundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FSPDataCoordinatorNoEventDataFoundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [weakSelf hideActivityIndicator];
                //self.noDataAvailable.hidden = NO;
            }];
		}];
	}
    
    [self showActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.currentSelectedEventPath) {
		UITableViewScrollPosition scrollPosition = UITableViewScrollPositionNone;
		if (![[self.tableView indexPathsForVisibleRows] containsObject:self.currentSelectedEventPath]) {
			scrollPosition = UITableViewScrollPositionTop;
		}

		// flash the current selection
		[self.tableView selectRowAtIndexPath:self.currentSelectedEventPath animated:NO scrollPosition:scrollPosition];
		[self.tableView deselectRowAtIndexPath:self.currentSelectedEventPath animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self.tableView indexPathForSelectedRow]) {
		[self selectCurrentEventOnTable];
	}
	
#ifdef DEBUG_xmas_loading_time
    self.updateTime = [NSDate date];
#endif
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[FSPOrganization endUpdatingOrganziations];
    [[NSNotificationCenter defaultCenter] removeObserver:self.teamUpdateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.noEventDataFoundObserver];
    _fetchedResultsController.delegate = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSIndexPath *)adjustedIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *adjustedIndexPath;
	if (ADS_ENABLED && indexPath.section == FSPAdSectionIndex && indexPath.row > FSPAdRowIndex) {
		adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
	} else {
		adjustedIndexPath = indexPath;
	}
	return adjustedIndexPath;
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger rows = [sectionInfo numberOfObjects];
	if (ADS_ENABLED && section == FSPAdSectionIndex && rows >= FSPAdRowIndex) rows++;
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (ADS_ENABLED && indexPath.section == FSPAdSectionIndex && indexPath.row == FSPAdRowIndex) {
   		FSPEventChipCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPGameChipIdentifier];
		[cell populateCellWithEvent:nil];
		cell.isAdView = YES;
        [cell.adView addSubview:self.adView];
		
		return cell;
        
    } else {
		NSString *identifier;
        
		FSPEvent *event = [self eventAtIndexPath:indexPath];
		
		if ([event isKindOfClass:[FSPGame class]]) {
            if (event.viewType == FSPNCAABViewType || event.viewType == FSPNCAAFViewType || event.viewType == FSPNCAAWBViewType) {
                identifier = FSPRankedGameChipCellIdentifier;
            } else {
                identifier = FSPGameChipIdentifier;
            }
        }
		else
			identifier = FSPTournamentChipCellIdentifier;
		
        
		FSPEventChipCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
		[cell populateCellWithEvent:event];
		cell.isAdView = NO;
        
		return cell;
	}
}


#pragma mark - TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"FSPEventChipsSectionHeader" bundle:nil];
    NSArray *topLevelObjects = [sectionHeaderNib instantiateWithOwner:nil options:nil];
    FSPEventChipsSectionHeader *sectionHeader = [topLevelObjects lastObject];
    sectionHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]);
    
    NSNumber *startDateGroup = [(FSPEvent *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] startDateGroup];
    NSString *displayName = [FSPEvent displayNameForStartDateGroup:startDateGroup];
    sectionHeader.startDateGroupLabel.text = displayName;
    return sectionHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[NSUserDefaults standardUserDefaults] fsp_setIndexPath:indexPath forKey:@"lastSelectedEvent"];
	
	if (ADS_ENABLED && indexPath.section == FSPAdSectionIndex && indexPath.row == FSPAdRowIndex) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
    
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && [indexPath isEqual:self.currentSelectedEventPath]) {
		return;
	}
	self.currentSelectedEventPath = indexPath;
    
    FSPEvent *event = [self eventAtIndexPath:indexPath];
    
    if (self.delegate) {
        [self.delegate eventsViewController:self didSelectEvent:event];
    }
    self.selectedEvent = event;
    
    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.rootViewController dismissPopover];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}


#pragma mark Ad view delegate

- (void)adManager:(FSPAdManager *)adManager didReceiveAd:(UIView *)adView
{
    CGRect adFrame = self.adView.frame;
    adView.frame = adFrame;
    self.adView = adView;
    //TODO: Reload this cell's view a different way.
    NSIndexPath *adIndexPath = [NSIndexPath indexPathForRow:FSPAdRowIndex inSection:FSPAdSectionIndex];
    FSPEventChipCell *adCell = (FSPEventChipCell *)[self.tableView cellForRowAtIndexPath:adIndexPath];
    if (adCell.isAdView) {
        [self.tableView reloadRowsAtIndexPaths:@[adIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (FSPImageAdType) adType
{
    return FSPAdTypeChip;
}


#pragma mark - Fetched results controller delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeDelete:
        case NSFetchedResultsChangeMove:
            self.needToUpdateSelectionPosition = YES;
            break;
            
        default:
        case NSFetchedResultsChangeUpdate:
            // On update, don't do anything here. The chip index paths didn't change, so don't do any work until -controllerDidChangeContent:.
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
 
#ifdef DEBUG_xmas_loading_time
    NSLog(@"events controller (%@) received content did change in: (%fms)\n %@", self.organization.name, [[NSDate date] timeIntervalSinceDate:self.updateTime], controller);
    self.updateTime = [NSDate date];
#endif
    
    [self hideActivityIndicator];
    
    if (self.needToUpdateSelectionPosition) {
        if (self.currentSelectedEventPath && ![self.selectedEvent isEqual:[self eventAtIndexPath:self.currentSelectedEventPath]]) {
            self.selectedEvent = [[self fetchedResultsController] objectAtIndexPath:[self currentSelectedEventPath]];
            hasScrolledToToday = NO;
        }

        [self.tableView reloadData];
        [self selectCurrentEventOnTable];
    } else {
        NSIndexPath *currentlySelected = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:currentlySelected
                                    animated:NO
                              scrollPosition:UITableViewRowAnimationNone];
    }
	self.needToUpdateSelectionPosition = NO;
}

#pragma mark - Helper methods

- (NSIndexPath *)indexPathForCurrentEvent
{
	NSIndexPath *indexPath = nil;
	
	if ([[self fetchedResultsController] fetchedObjects].count > 0) {
		
		// Determine what is the first section that has the next upcoming game.
		int selectedSection = -1;
		// Get the section titles
		NSArray *sectionTitles = [[self fetchedResultsController] sectionIndexTitles];
		// Is there a today?, if so, that will be what is selected as the first "current" game.  If there is no today!, give it 110%!
		// Then see if there is a Tomorrow, or Coming Up group
		for (NSInteger section = FSPStartDateGroupToday; section <= FSPStartDateGroupComingUp; section++) {
			NSString *sectionTitle = [NSString stringWithFormat:@"%d", section];
			if ([sectionTitles indexOfObject:sectionTitle] != NSNotFound) {
				selectedSection = [[self fetchedResultsController] sectionForSectionIndexTitle:sectionTitle atIndex:[sectionTitles indexOfObject:sectionTitle]];
				break;
			}
		}
		
		// Select the first row in whichever section is current
		if (selectedSection >= 0 && ([self tableView:self.tableView numberOfRowsInSection:selectedSection] > 0)) {
			indexPath = [NSIndexPath indexPathForRow:0 inSection:selectedSection];
		} else if ([self numberOfSectionsInTableView:self.tableView] > 0) {
			// Select the first row in the last section, (should be "Last Results")
			int lastSectionIndex = [self numberOfSectionsInTableView:self.tableView] - 1;
			indexPath = [NSIndexPath indexPathForRow:0 inSection:lastSectionIndex];
		}
	}
	return indexPath;
}

- (void)selectCurrentEventOnTable
{
    BOOL isAnimated = NO;

	FSPEvent *currentEvent = self.selectedEvent;
	
    if (![self.tableView indexPathForSelectedRow]) {
        
        //get the current event if we have an ID but no selected event
        if (!currentEvent) {
			NSString *currentSelectedEventID = nil;
			if ([self lastSelectedEventDefaultsKey]) {
				currentSelectedEventID = [[NSUserDefaults standardUserDefaults] stringForKey:[self lastSelectedEventDefaultsKey]];        
			}
			if (currentSelectedEventID) {
				NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPEvent"];
				fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", currentSelectedEventID];
				
				NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
				
				currentEvent = [events lastObject];
			}
        }
        
        NSIndexPath *selectedEventIndexPath = [self.fetchedResultsController indexPathForObject:currentEvent];
        
        if (!selectedEventIndexPath) {
			selectedEventIndexPath = [self indexPathForCurrentEvent];
			id event = [self.fetchedResultsController objectAtIndexPath:selectedEventIndexPath];
            if ([event isKindOfClass:[FSPEvent class]]) currentEvent = event;
            isAnimated = YES;
        }
        
		// don't select cells on iPhone
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			//select the chip
			[self.tableView selectRowAtIndexPath:selectedEventIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			
			//scroll to the selected chip if necessary
			if (!hasScrolledToToday && selectedEventIndexPath) {
				[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:isAnimated];
				hasScrolledToToday = YES;
			}
			
			if (currentEvent != self.selectedEvent) {
				[self.delegate eventsViewController:self didSelectEvent:currentEvent];
			}
		} else {
			// iPhone
			if (!hasScrolledToToday && selectedEventIndexPath) {
				[self.tableView scrollToRowAtIndexPath:selectedEventIndexPath atScrollPosition:UITableViewScrollPositionTop animated:isAnimated];
				hasScrolledToToday = YES;
			}
		}
		
		if (currentEvent != self.selectedEvent) {
			self.selectedEvent = currentEvent;
		}
		self.currentSelectedEventPath = selectedEventIndexPath;
	}
}

- (FSPEvent *)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return (FSPEvent *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end



