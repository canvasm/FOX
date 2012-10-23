//
//  FSPScheduleViewController.m
//  FoxSports
//
//  Created by greay on 4/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleViewController.h"

#import "FSPOrganization.h"
#import "FSPTeam.h"
#import "FSPOrganizationSchedule.h"
#import "FSPDataCoordinator.h"
#import "FSPEvent.h"
#import "FSPScheduleGame.h"
#import "FSPScheduleNFLGame.h"
#import "FSPScheduleTennisEvent.h"

#import "FSPScheduleCell.h"
#import "FSPScheduleHeaderView.h"

#import "FSPNBALeagueScheduleHeaderView.h"
#import "FSPMLBLeagueScheduleHeaderView.h"
#import "FSPNFLLeagueScheduleHeaderView.h"
#import "FSPNASCARScheduleHeaderView.h"
#import "FSPUFCScheduleHeaderView.h"
#import "FSPSoccerLeagueScheduleHeaderView.h"
#import "FSPNHLLeagueScheduleHeaderView.h"
#import "FSPPGATourScheduleHeaderView.h"
#import "FSPTennisScheduleHeaderView.h"

#import "FSPPrimarySegmentedControl.h"
#import "FSPDropDownView.h"
#import "FSPConferencesModalViewController.h"
#import "FSPConferencesOverlayViewController.h"

#import "NSDate+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPScheduleViewController ()

@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) FSPOrganization *currentSelectedConference;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableSet *headerViewCache;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIPopoverController *popoverController;

- (FSPOrganization *)currentOrganization;
- (void)refreshSchedule;

@property (nonatomic, strong) FSPDropDownView *dropDownButton;
@property (nonatomic, strong) FSPConferencesOverlayViewController *pseudoModalViewController;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

- (void)presentOverlayViewController:(FSPConferencesOverlayViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissOverlayViewControllerAnimated:(BOOL)animated;

@end

@implementation FSPScheduleViewController
@synthesize organization = _organization;
@synthesize managedObjectContext;
@synthesize scheduleArray;
@synthesize headerViewCache = _headerViewCache;
@synthesize reorderedScheduleArray;
@synthesize hasScrolledToToday;
@synthesize cellClass;
@synthesize tableView;
@synthesize popoverController;
@synthesize currentSelectedConference = _currentSelectedConference;

+ (id)scheduleViewControllerWithOrganization:(FSPOrganization *)org managedObjectContext:(NSManagedObjectContext *)context
{
	return [[self alloc] initWithOrganization:org managedObjectContext:context];
}

+ (FSPViewType)viewTypeForOrganization:(FSPOrganization *)org
{
	FSPViewType viewType = [org viewType];
	
	if (viewType == FSPUnknownViewType) {
		// no view type; we're probably a team so use our org's view type
		if ([org isKindOfClass:[FSPTeam class]]) {
			FSPTeam *team = (FSPTeam *)org;
			viewType = ((FSPOrganization *)[[team organizations] anyObject]).viewType;
		}
	}
	return viewType;
}

- (id)initWithOrganization:(FSPOrganization *)org managedObjectContext:(NSManagedObjectContext *)context;
{
    self = [super init];
    if (self) {
        self.organization = org;
        self.currentSelectedConference = [org defaultChildOrganization];
        self.managedObjectContext = context;
        NSString *name = org.name;
        if ([org isKindOfClass:[FSPTeam class]]) {
            name = [(FSPTeam *)org shortNameDisplayString];
        }
		self.navigationItem.title = [NSString stringWithFormat:@"%@ Schedule", name];
    }
    return self;
}

- (void)setOrganization:(FSPOrganization *)organization
{
    if (![self.organization.objectID isEqual:organization.objectID]) {
        _organization = organization;
    }
}

- (FSPOrganization *)currentOrganization
{
	if (self.currentSelectedConference) {
		return self.currentSelectedConference;
	} else {
		return self.organization;
	}
}

- (NSArray *)orderedConferences
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customizable == YES OR selectable == YES"];
	NSSet *setToSort = [self.organization.children filteredSetUsingPredicate:predicate];
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES];
	
	return [setToSort sortedArrayUsingDescriptors:@[sort]];
}

- (void)loadView
{
    CGRect parentFrame = self.parentViewController.view.frame;
    self.view = [[UIView alloc] initWithFrame:parentFrame];
    
    CGFloat conferenceSelectorButtonContainerHeight = 0.0f;
    if ([self.organization.children count] > 0) {
        conferenceSelectorButtonContainerHeight = 36.0f;
		[self showOrganizationsContainerWithHeight:conferenceSelectorButtonContainerHeight];
    }
    
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, conferenceSelectorButtonContainerHeight, parentFrame.size.width, parentFrame.size.height - conferenceSelectorButtonContainerHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.allowsSelection = NO;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.showsVerticalScrollIndicator = YES;
	
	[self.view insertSubview:self.tableView atIndex:0];
}

- (void)showOrganizationsContainerWithHeight:(CGFloat)containerHeight
{
    CGRect frame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        frame = CGRectMake(0.0, 0.0, 320.0, containerHeight);
    } else {
        frame = CGRectMake(0.0, 0.0, 647.0, containerHeight);
    }
	
	switch (self.organization.viewType) {
		case FSPSoccerViewType:
		case FSPNCAAFViewType:
		case FSPNCAABViewType:
		case FSPNCAAWBViewType: {
			FSPDropDownView *dropdown = [[FSPDropDownView alloc] initWithFrame:frame];
			
			[dropdown setButtonTitle:self.currentSelectedConference.name];
			[dropdown.button addTarget:self action:@selector(toggleConferences:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:dropdown];
			self.dropDownButton = dropdown;
			break;
		}
		default: {
			FSPPrimarySegmentedControl *segmentedControl = [[FSPPrimarySegmentedControl alloc] initWithFrame:frame];
			segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			__block NSUInteger selection = -1;
			[[self orderedConferences] enumerateObjectsUsingBlock:^(FSPOrganization *org, NSUInteger i, BOOL *stop) {
				[segmentedControl insertSegmentWithTitle:org.name atIndex:i animated:NO];
				if ([org isEqual:[self.organization defaultChildOrganization]]) {
					selection = i;
				}
			}];
			[segmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
			[self.view addSubview:segmentedControl];
			segmentedControl.selectedSegmentIndex = selection;
		}
	}
}

- (void)toggleConferences:(UIButton *)sender
{
	void (^completion)(FSPOrganization *) = ^(FSPOrganization *conference) {
		if (![[conference objectID] isEqual:[self.currentSelectedConference objectID]]) {
			self.currentSelectedConference = conference;
			[self refreshSchedule];
			
			FSPDropDownView *dropdown = nil;
			if ([[sender superview] isKindOfClass:[FSPDropDownView class]]) {
				dropdown = (FSPDropDownView *)[sender superview];
			}
			[dropdown setButtonTitle:conference.name];
		}
		[self.popoverController dismissPopoverAnimated:YES];
		[self dismissOverlayViewControllerAnimated:YES];
	};
    // Don't show virtual organizations
    NSMutableSet *noVirtualOrgs = [NSMutableSet set];
    for (FSPOrganization *org in self.organization.children) {
        if (![org isVirtualConference]) {
            [noVirtualOrgs addObject:org];
        }
    }
    
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		FSPConferencesModalViewController *confrencesViewController = [[FSPConferencesModalViewController alloc] initWithOrganizations:noVirtualOrgs
																													 includeTournamets:YES
																																 style:UITableViewStyleGrouped
																											selectionCompletionHandler:completion];
		confrencesViewController.selectedConference = self.currentSelectedConference;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:confrencesViewController];
		navController.navigationBar.barStyle = UIBarStyleBlack;

		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];

        [self.popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }  else {
		if (!self.pseudoModalViewController) {
			FSPConferencesOverlayViewController *otherConfrencesViewController = [[FSPConferencesOverlayViewController alloc] initWithOrganizations:noVirtualOrgs
																																  includeTournamets:YES
																																			  style:UITableViewStylePlain
																														 selectionCompletionHandler:completion];
			otherConfrencesViewController.selectedConference = self.currentSelectedConference;
			
			[self presentOverlayViewController:otherConfrencesViewController animated:YES completion:nil];
		} else {
			// dismiss
			[self dismissOverlayViewControllerAnimated:YES];
		}
	}
}

- (void)selectionChanged:(FSPSegmentedControl *)sender
{
	FSPOrganization *conference = [[self orderedConferences] objectAtIndex:sender.selectedSegmentIndex];
	if (![[conference objectID] isEqual:[self.currentSelectedConference objectID]]) {
		self.currentSelectedConference = conference;
		[self refreshSchedule];
	}
}

- (void)setupTableView
{
	FSPViewType viewType = [FSPScheduleViewController viewTypeForOrganization:[self currentOrganization]];
	NSString *nibName = nil;
	switch (viewType) {
		case FSPBaseballViewType:
			nibName = @"FSPMLBLeagueScheduleCell";
			self.tableView.accessibilityLabel = @"mlb league schedule";
			break;
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
		case FSPBasketballViewType:
			nibName = @"FSPNBALeagueScheduleCell";
			self.tableView.accessibilityLabel = @"basketball league schedule";
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			nibName = @"FSPNFLLeagueScheduleCell";
			self.tableView.accessibilityLabel = @"nfl league schedule";
			break;
		case FSPRacingViewType:
			nibName = @"FSPNASCARScheduleCell";
			self.tableView.accessibilityLabel = @"nascar schedule";
            break;
        case FSPTennisViewType:
            nibName = @"FSPTennisScheduleCell";
            self.tableView.accessibilityLabel = @"tennis schedule";
            break;
        case FSPFightingViewType:
			nibName = @"FSPUFCScheduleCell";
			self.tableView.accessibilityLabel = @"ufc schedule";
            break;
        case FSPSoccerViewType:
            // soccer team / league files are reversed
            nibName = @"FSPSoccerLeagueScheduleCell";
			self.tableView.accessibilityLabel = @"soccer schedule";
            break;
        case FSPHockeyViewType:
            nibName = @"FSPNHLLeagueScheduleCell";
            self.tableView.accessibilityLabel = @"nhl schedule";
            break;
        case FSPGolfViewType:
            nibName = @"FSPPGATourScheduleCell";
            self.tableView.accessibilityLabel = @"pga schedule";
		default:
			NSLog(@"...");
			break;
	}

	if (nibName) {
		UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
		self.cellClass = [[[cellNib instantiateWithOwner:nil options:nil] lastObject] class];
		[self.tableView registerNib:cellNib forCellReuseIdentifier:@"scheduleCell"];
    }

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.headerViewCache = [NSMutableSet set];
	self.reorderedScheduleArray = [NSMutableArray array];
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
	[self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSchedule];
    [self scrollToToday];
    self.tableView.backgroundColor = [UIColor fsp_colorWithIntegralRed:242 green:242 blue:242 alpha:1.0];
    self.hasScrolledToToday = NO;
    [self scrollToToday];
}

- (void)didReceiveMemoryWarning
{
    [self.headerViewCache removeAllObjects];
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	else return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (FSPScheduleHeaderView *)dequeueHeader {
    __block FSPScheduleHeaderView *header;
    [self.headerViewCache enumerateObjectsUsingBlock:^(FSPScheduleHeaderView *obj, BOOL *stop) {
        if (!obj.superview) {
            header = obj;
            *stop = YES;
        }
    }];

	return header;
}
- (void)enqueueHeader:(FSPScheduleHeaderView *)header {
	[self.headerViewCache addObject:header];
}

#pragma mark - TableView delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
 	FSPScheduleGame *game = nil;
    if ([[self.reorderedScheduleArray objectAtIndex:section] count]) {
        game = [[self.reorderedScheduleArray objectAtIndex:section] objectAtIndex:0];
    }

	FSPScheduleHeaderView *header = [self dequeueHeader];
	
    if (!header) {
		FSPViewType viewType = [FSPScheduleViewController viewTypeForOrganization:[self currentOrganization]];
		switch (viewType) {
			case FSPNCAABViewType:
            case FSPNCAAWBViewType:
            case FSPBasketballViewType:
				header = [[FSPNBALeagueScheduleHeaderView alloc] init];
				break;
			case FSPBaseballViewType:
				header = [[FSPMLBLeagueScheduleHeaderView alloc] init];
				break;
			case FSPRacingViewType:
				header = [[FSPNASCARScheduleHeaderView alloc] init];
				break;
            case FSPFightingViewType:
				header = [[FSPUFCScheduleHeaderView alloc] init];
                break;
			case FSPNFLViewType:
			case FSPNCAAFViewType:
				header = [[FSPNFLLeagueScheduleHeaderView alloc] init];
				break;
            case FSPSoccerViewType:
                header = [[FSPSoccerLeagueScheduleHeaderView alloc] init];
                break;
            case FSPHockeyViewType:
                header = [[FSPNHLLeagueScheduleHeaderView alloc] init];
                break;
            case FSPGolfViewType:
                header = [[FSPPGATourScheduleHeaderView alloc] init];
                break;
            case FSPTennisViewType:
                header = [[FSPTennisScheduleHeaderView alloc] init];
                break;
			default:
				header = [[FSPScheduleHeaderView alloc] init];
				break;
		}
		
        [self enqueueHeader:header];
    }
    
    header.event = game;
    return header;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section;
{
    FSPScheduleHeaderView *headerView = (FSPScheduleHeaderView *)[self tableView:aTableView viewForHeaderInSection:section];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return [[headerView class] headerHeght];
	} else {
		if (self.currentOrganization.viewType == FSPBaseballViewType
            || self.currentOrganization.viewType == FSPHockeyViewType
            || self.currentOrganization.viewType == FSPBasketballViewType
            || self.currentOrganization.viewType == FSPNCAABViewType
            || self.currentOrganization.viewType == FSPNCAAWBViewType) {
			if (headerView.isFuture) {
				return [[headerView class] headerHeght];
			} else {
				return [[headerView class] headerHeght] / 2;
			}
		} else if (self.currentOrganization.viewType == FSPSoccerViewType){
            if (headerView.isFuture)
                return [[headerView class] headerHeght] / 2;
            else
                return [[headerView class] headerHeght];
		} else {
            return [[headerView class] headerHeght];
        }
	}
}


#pragma mark - TableView datasource


- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.reorderedScheduleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.reorderedScheduleArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"scheduleCell"];
	if (!cell) {
		cell = [[FSPScheduleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scheduleCell"];
	}
	
	id event = [[self.reorderedScheduleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if (self.currentOrganization.isTeamSport) {
		[cell populateWithGame:event];
	} else {
		[cell populateWithEvent:event];
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPScheduleGame *game = [[self.reorderedScheduleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return [self.cellClass heightForEvent:game];
}

#pragma mark - : helpers :

- (void)updateSchedule
{
	self.reorderedScheduleArray = [NSMutableArray array];
	
	if (self.currentOrganization.isTeamSport) {
		[self.reorderedScheduleArray addObjectsFromArray:self.scheduleArray];
	} else {
		NSMutableArray *pastGamesArray = [NSMutableArray array];
		NSMutableArray *futureGamesArray = [NSMutableArray array];
		for (NSArray *array in self.scheduleArray) {
			for (FSPScheduleEvent *event in array) {
				// Figure out if this is a future date or not
				BOOL isFuture;
                NSDate *checkDate;
                if ([event isKindOfClass:[FSPScheduleTennisEvent class]])
                    checkDate = ((FSPScheduleTennisEvent *)event).endDate;
                else
                    checkDate = event.normalizedStartDate;
                
				if ([checkDate fsp_isToday]) {
					isFuture = YES;
				} else {
					NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:checkDate];
					isFuture = (comparisonResult == NSOrderedAscending);
				}
				if (isFuture) {
					[futureGamesArray addObject:event];
				}
				else {
					[pastGamesArray addObject:event];
				}
			}
		}
		
		[self.reorderedScheduleArray addObject:pastGamesArray];
		[self.reorderedScheduleArray addObject:futureGamesArray];
	}
	
    [self.tableView reloadData];
    self.hasScrolledToToday = NO;
    [self scrollToToday];
}


- (void)scrollToToday;
{
    if (!hasScrolledToToday) {
        
		if (self.currentOrganization.isTeamSport) {
			NSDate *today = [[NSDate date] fsp_normalizedDate];
			
			NSUInteger count = [self.reorderedScheduleArray count];
			for (NSUInteger section = 0; section < count; section++) {
				
				NSArray *group = [self.reorderedScheduleArray objectAtIndex:section];
				if (group.count > 0) {
					for (NSUInteger row = 0; row < [group count]; row++) {
						FSPEvent *game = [group objectAtIndex:row];
						
						NSComparisonResult comparisonResult = [today compare:game.normalizedStartDate];
						BOOL isTodayOrFuture = (comparisonResult == NSOrderedSame || comparisonResult == NSOrderedAscending);
						
						if (isTodayOrFuture) {
							NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
							[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
							[self.tableView flashScrollIndicators];
							hasScrolledToToday = YES;
							return;
						}
					}
				}
			}
		} else {
			NSDate *today = [[NSDate date] fsp_normalizedDate];
			
			// Since there are only 2 sections, results and scheduled, today is either going
			// to be the last result or the first scheduled, or a date in between.  In that
			// case, default to last result.
			
			NSIndexPath *pathToScrollTo = nil;
			// If there are results, assume scrolling to last result
			if (self.reorderedScheduleArray.count && [[self.reorderedScheduleArray objectAtIndex:0] count]) {
				pathToScrollTo = [NSIndexPath indexPathForRow:([[self.reorderedScheduleArray objectAtIndex:0] count] - 1) inSection:0];
			}
			
			//Check to see if should scroll to first scheduled instead.
			if (self.reorderedScheduleArray.count > 0 && [[self.reorderedScheduleArray objectAtIndex:0] count]) {
				FSPScheduleEvent *firstScheduled = [[self.reorderedScheduleArray objectAtIndex:1] firstObject];
				NSComparisonResult lastDateComparison = [today compare:firstScheduled.normalizedStartDate];
				if (lastDateComparison == NSOrderedSame) {
					pathToScrollTo = [NSIndexPath indexPathForRow:[[self.reorderedScheduleArray objectAtIndex:1] indexOfObject:firstScheduled] inSection:1];
				}
			}
			
			// Scroll
			if (pathToScrollTo) {
				[self.tableView scrollToRowAtIndexPath:pathToScrollTo atScrollPosition:UITableViewScrollPositionTop animated:NO];
				[self.tableView flashScrollIndicators];
				self.hasScrolledToToday = YES;
			}
			return;

		}
    }
}

- (void)refreshSchedule;
{
    [self.dataCoordinator updateScheduleForOrganizationId:[self currentOrganization].objectID success:^(NSArray *schedule){
        // We are responding to the FSPScheduleDidCompleteUpdatingNotification, I am not sure if it is better to respond
        // via the notification or this callback.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scheduleArray = schedule;
            [self updateSchedule];
        });
    } failure:^(NSError *error) {
        //TODO: Notify about error.
    }];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
	[super presentViewController:viewControllerToPresent animated:flag completion:^{
		if (self.pseudoModalViewController) {
			[self dismissOverlayViewControllerAnimated:NO];
		}
		if (completion) {
			completion();
		}
	}];
}

- (void)presentOverlayViewController:(FSPConferencesOverlayViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
	if (self.pseudoModalViewController) {
		[self.pseudoModalViewController.overlay removeFromSuperview];
	}
	self.pseudoModalViewController = viewController;
	
	if ([viewController respondsToSelector:@selector(setOverlayPresentingViewController:)]) {
		[(id)viewController setOverlayPresentingViewController:self];
	}
	
	viewController.overlay = [[FSPConferencesOverlayContainerView alloc] initWithFrame:self.tableView.frame];
	viewController.overlay.alpha = 0.0;
	
	CGSize contentSize = viewController.contentSizeForViewInPopover;
	if (contentSize.height > self.tableView.bounds.size.height) {
		contentSize.height = self.tableView.bounds.size.height;
	}
	CGRect finalRect;
	finalRect.origin = CGPointZero;
	finalRect.size = contentSize;
	
	UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, finalRect.origin.y - finalRect.size.height, contentSize.width, contentSize.height)];
	shadowView.backgroundColor = [UIColor clearColor];
	
	shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
	shadowView.layer.shadowOffset = CGSizeMake(0, 1.0);
	shadowView.layer.shadowRadius = 10.0;
	shadowView.layer.masksToBounds = NO;
	
	[shadowView addSubview:self.pseudoModalViewController.view];
	[viewController.overlay addSubview:shadowView];

	viewController.view.frame = shadowView.bounds;
	[self.view insertSubview:viewController.overlay belowSubview:self.dropDownButton];

	[UIView animateWithDuration:0.4 animations:^{
		viewController.overlay.alpha = 1.0;
		shadowView.frame = finalRect;
		shadowView.layer.shadowOpacity = 1.0;
	}];
}

- (void)dismissOverlayViewControllerAnimated:(BOOL)animated
{
	void (^completion)(BOOL) = ^(BOOL finished) {
		[self.pseudoModalViewController.overlay removeFromSuperview];
		self.pseudoModalViewController = nil;
	};
	
	if (animated && self.pseudoModalViewController) {
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame = self.pseudoModalViewController.view.frame;
			frame.origin.y -= frame.size.height;
			self.pseudoModalViewController.view.frame = frame;
			self.pseudoModalViewController.overlay.alpha = 0.0;
		} completion:completion];
	} else {
		completion(YES);
	}
}

@end
