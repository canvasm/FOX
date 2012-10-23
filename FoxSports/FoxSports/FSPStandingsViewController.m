//
//  FSPStandingsViewController.m
//  FoxSports
//
//  Created by Matthew Fay on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsViewController.h"

#import "FSPStandingsTableViewController.h"
#import "FSPMLBStandingsTableViewController.h"
#import "FSPFightingStandingsTableViewController.h"
#import "FSPGolfStandingsTableViewController.h"

#import "FSPPrimarySegmentedControl.h"
#import "FSPOrganization.h"
#import "FSPTeam.h"
#import "FSPTeamRanking.h"
#import "FSPDataCoordinator.h"
#import "FSPDropDownView.h"
#import "FSPConferencesOverlayViewController.h"
#import "FSPConferencesModalViewController.h"

#import "UIColor+FSPExtensions.h"


static NSString * const FSPNBAConferenceDisplayTitleAll = @"Conference";
static NSString * const FSPNBAConferenceDisplayTitleEastern = @"Eastern";
static NSString * const FSPNBAConferenceDisplayTitleWestern = @"Western";

typedef enum {
    FSPNBAConferenceIndexAll = 0,
    FSPNBAConferenceIndexEastern,
    FSPNBAConferenceIndexWestern,
    FSPNBAConferenceIndexCount
} FSPNBAConferenceIndex;

@interface FSPStandingsViewController() <FSPStandingsTableViewControllerDelegate>

//TODO: Generalize table view creation
@property (weak, nonatomic) IBOutlet FSPPrimarySegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *tableViewControllers;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) FSPOrganization *currentSelectedConference;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;
@property (nonatomic, weak) UITableView *currentTableView;
@property (nonatomic, assign) BOOL didToggleRankings;

/**
 * Returns a list of expected conference names for a given pro branch.
 *
 * For pro teams, this is a hard-coded list of strings.
 * 
 * TODO: For college teams, this should be a list of conference names from the organization's children
 * of type FSPOrganizationConferenceType. 
 */
- (NSArray *)conferenceNamesForBranch:(NSString *)branch;

- (void)refreshStandings;
- (void)showOrganizationsContainerWithHeight:(CGFloat)containerHeight;
- (IBAction)updateSelectedSegment:(UISegmentedControl *)sender;

@property (nonatomic, strong) FSPDropDownView *dropDownButton;
@property (nonatomic, strong) FSPConferencesOverlayViewController *pseudoModalViewController;
- (void)presentOverlayViewController:(FSPConferencesOverlayViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissOverlayViewControllerAnimated:(BOOL)animated;

@end


@implementation FSPStandingsViewController

@synthesize popoverController = _popover;

- (id)initWithOrganization:(FSPOrganization *)organization managedObjectContext:(NSManagedObjectContext *)context;
{
    self = [super init];
    if(!self) return nil;

    FSPViewType viewType = organization.viewType;
    
	if (viewType == FSPBasketballViewType
    || (viewType == FSPNFLViewType)
	|| (viewType == FSPNCAAFViewType)
    || (viewType == FSPBaseballViewType)
    || (viewType == FSPRacingViewType) 
    || (viewType == FSPFightingViewType)
    || (viewType == FSPHockeyViewType)
    || (viewType == FSPSoccerViewType)
	|| (viewType == FSPGolfViewType)
    || (viewType == FSPTennisViewType)
    || (viewType == FSPNCAABViewType)
    || (viewType == FSPNCAAWBViewType)) {
        self.managedObjectContext =  context;
        self.organization = organization;
		self.currentSelectedConference = [organization defaultChildOrganization];
	} else {
        self = nil;
    }
    return self;
}

- (FSPOrganization *)currentOrganization;
{
	if (self.currentSelectedConference) {
		return self.currentSelectedConference;
	} else {
		return self.organization;
	}
}

- (NSArray *)orderedConferences;
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customizable == YES OR selectable == YES"];
	NSSet *setToSort = [self.organization.children filteredSetUsingPredicate:predicate];
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES];
	
	return [setToSort sortedArrayUsingDescriptors:@[sort]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];

	[self refreshStandings];
    
	FSPViewType viewType = self.organization.viewType;
	
    //Hide segmented control
    if ([self.organization.children count] > 0) {
		switch (viewType) {
			case FSPSoccerViewType:
			case FSPNCAAFViewType:
			case FSPNCAABViewType:
			case FSPNCAAWBViewType: {
				self.segmentedControl.hidden = YES;
				// conference popover
				[self showOrganizationsContainerWithHeight:self.segmentedControl.bounds.size.height];
			}
			default: {
				__block NSUInteger selection = -1;
				[[self orderedConferences] enumerateObjectsUsingBlock:^(FSPOrganization *org, NSUInteger i, BOOL *stop) {
					[self.segmentedControl insertSegmentWithTitle:org.name atIndex:i animated:NO];
					if ([org isEqual:[self.organization defaultChildOrganization]]) {
						selection = i;
					}
				}];
				[self.segmentedControl addTarget:self action:@selector(updateSelectedConference:) forControlEvents:UIControlEventValueChanged];
				self.segmentedControl.selectedSegmentIndex = selection;
				break;
			}
		}
	}
    else if (viewType == FSPBasketballViewType || viewType == FSPHockeyViewType) {
        // WNBA has no conferences, but changing it to a separate viewtype from FSPBasketballViewType
        // would require lots of changes
        if ([self.organization.viewTypeString isEqualToString:@"WNBA"]) {
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height + self.segmentedControl.frame.size.height);
            self.segmentedControl.hidden = YES;
        }
        // TODO: Not sure why this is necessary to get WNBA standing to load correctly
        [self.segmentedControl insertSegmentWithTitle:@"Conference" atIndex:0 animated:NO];
        [self.segmentedControl insertSegmentWithTitle:@"Division" atIndex:1 animated:NO];
        [self.segmentedControl addTarget:self action:@selector(updateSelectedSegment:) forControlEvents:UIControlEventValueChanged];
        self.segmentedControl.selectedSegmentIndex = 0;

	} else if (viewType == FSPGolfViewType && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		NSArray *segments = @[ @"Money Leaders", @"FedEx Cup", @"World Ranking", @"Scoring Average" ];
		[segments enumerateObjectsUsingBlock:^(NSString *name, NSUInteger i, BOOL *stop) {
			[self.segmentedControl insertSegmentWithTitle:name atIndex:i animated:NO];

		}];
		[self.segmentedControl addTarget:self action:@selector(changeStatType:) forControlEvents:UIControlEventValueChanged];
		self.segmentedControl.selectedSegmentIndex = 0;

	} else {
        self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height + self.segmentedControl.frame.size.height);
        self.segmentedControl.hidden = YES;
        self.segmentedControl = nil;
    }
    [self updateStandings];
}


- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    for (FSPStandingsTableViewController *tableViewController in self.tableViewControllers) {
        [tableViewController.tableView reloadData];
        [self standingsTableViewDidUpdate:tableViewController.tableView];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (NSArray *)conferenceNamesForBranch:(NSString *)branch;
{
    NSArray *conferenceNames;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPTeam"];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@ && conferenceName != %@",
							  branch, @"NO"];
	fetchRequest.propertiesToFetch = @[@"conferenceName"];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"conferenceName" ascending:YES]];
	fetchRequest.includesSubentities = NO;
	NSError *error;
	NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	NSSet *set = [NSSet setWithArray:[result valueForKey:@"conferenceName"]];
	conferenceNames = [set sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
	
    return conferenceNames;
}

- (NSArray *)divisionNamesForBranch:(NSString *)branch;
{
    NSArray *divisionNames;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPTeam"];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@ && divisionName != %@",
							  branch, @"NO"];
	fetchRequest.propertiesToFetch = @[@"divisionName"];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"divisionName" ascending:YES]];
	fetchRequest.includesSubentities = NO;
	NSError *error;
	NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	NSSet *set = [NSSet setWithArray:[result valueForKey:@"divisionName"]];
	divisionNames = [set sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
    
    return divisionNames;
}

- (void)standingsTableViewDidUpdate:(UITableView *)tableView;
{
	if (self.organization.viewType == FSPGolfViewType) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			CGRect topLeft, topRight, bottomLeft, bottomRight;
            CGFloat width = fmodf(self.view.bounds.size.width, 2) == 0 ? self.view.bounds.size.width : self.view.bounds.size.width + 1;
			CGRectDivide(self.view.bounds, &topLeft, &bottomLeft, self.view.bounds.size.height / 2, CGRectMinYEdge);
			CGRectDivide(topLeft, &topLeft, &topRight, width / 2, CGRectMinXEdge);
			CGRectDivide(bottomLeft, &bottomLeft, &bottomRight, width / 2, CGRectMinXEdge);
			
			[[self.tableViewControllers objectAtIndex:0] tableView].frame = topLeft;
			[[self.tableViewControllers objectAtIndex:1] tableView].frame = topRight;
			[[self.tableViewControllers objectAtIndex:2] tableView].frame = bottomLeft;
			[[self.tableViewControllers objectAtIndex:3] tableView].frame = bottomRight;
		} else {
			tableView.frame = CGRectMake(0, tableView.frame.origin.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
		}
	} else if ([self.currentOrganization.viewTypeString rangeOfString:@"TOP25"].location != NSNotFound){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // Layout side by side
            CGRect left, right;
            CGFloat width = fmodf(self.view.bounds.size.width, 2) == 0 ? self.view.bounds.size.width : self.view.bounds.size.width + 1;
            CGRectDivide(self.view.bounds, &left, &right, width / 2, CGRectMinXEdge);
            [[self.tableViewControllers objectAtIndex:0] tableView].frame = left;
            [[self.tableViewControllers objectAtIndex:1] tableView].frame = right;
            [[[self.tableViewControllers objectAtIndex:0] tableView].tableFooterView setNeedsLayout];
            [[[self.tableViewControllers objectAtIndex:1] tableView].tableFooterView setNeedsLayout];
            CGRect leftFooterFrame = [[self.tableViewControllers objectAtIndex:0] tableView].tableFooterView.frame;
            CGRect rightFooterFrame = [[self.tableViewControllers objectAtIndex:1] tableView].tableFooterView.frame;
            
            leftFooterFrame.size.width = rightFooterFrame.size.width = [[self.tableViewControllers objectAtIndex:0] tableView].frame.size.width;
            [[self.tableViewControllers objectAtIndex:0] tableView].tableFooterView.frame = leftFooterFrame;
            [[self.tableViewControllers objectAtIndex:1] tableView].tableFooterView.frame = rightFooterFrame;
            
        }
        else {
            // Layout top to bottom
            tableView.frame = CGRectMake(0, tableView.frame.origin.y, self.scrollView.bounds.size.width, tableView.contentSize.height);
            
            CGFloat y = 0;
            for (UITableViewController *vc in self.tableViewControllers) {
                CGRect frame = vc.tableView.frame;
                frame.origin.y = y;
                vc.tableView.frame = frame;
                y += frame.size.height;
            }
            
            CGSize contentSize = self.scrollView.contentSize;
            contentSize.height = y;
            self.scrollView.contentSize = contentSize;

        }
    }
    else {
		tableView.frame = CGRectMake(0, tableView.frame.origin.y, self.scrollView.bounds.size.width, tableView.contentSize.height);

		CGFloat y = 0;
		for (UITableViewController *vc in self.tableViewControllers) {
			CGRect frame = vc.tableView.frame;
			frame.origin.y = y;
			vc.tableView.frame = frame;
			y += frame.size.height;
		}
		
		CGSize contentSize = self.scrollView.contentSize;
		contentSize.height = y;
		self.scrollView.contentSize = contentSize;
	}
    
    // If conference/ranking tableviews are added to the scroll view before they have data and are layed out,
    // weird things happen.  See toggleConferences.
    if (self.didToggleRankings) {
        for (FSPStandingsTableViewController *standingsViewController in self.tableViewControllers) {
            [self.scrollView addSubview:standingsViewController.view];
        }
        self.didToggleRankings = NO;
    }
}

- (void)updateStandings;
{
	FSPViewType viewType = self.currentOrganization.viewType;

	if (!self.tableViewControllers) {
		NSArray *conferenceNames = [self conferenceNamesForBranch:[self.currentOrganization baseBranch]];

		Class standingsControllerClass = nil;
		if ([conferenceNames count] == 2) {
			
			if (viewType == FSPBaseballViewType) {
				standingsControllerClass = [FSPMLBStandingsTableViewController class];
			} else {
				standingsControllerClass = [FSPStandingsTableViewController class];
			}
			FSPStandingsTableViewController *topTableViewController = [[standingsControllerClass alloc] initWithOrganization:self.currentOrganization conferenceName:[conferenceNames objectAtIndex:0] managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
			FSPStandingsTableViewController *bottomTableViewController = [[standingsControllerClass alloc] initWithOrganization:self.currentOrganization conferenceName:[conferenceNames objectAtIndex:1] managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
			topTableViewController.delegate = self;
			bottomTableViewController.delegate = self;

			self.tableViewControllers = @[topTableViewController, bottomTableViewController];
		} else if (viewType == FSPGolfViewType) {
			NSMutableArray *viewControllers = [NSMutableArray array];
			
			for (NSString *standingsType in @[ @"earnings", @"points", @"worldRankingPoints", @"scoringAverage" ]) {
				FSPGolfStandingsTableViewController *vc = [[FSPGolfStandingsTableViewController alloc] initWithOrganization:self.currentOrganization conferenceName:nil managedObjectContext:self.managedObjectContext standingsType:standingsType];
				[viewControllers addObject:vc];
			}
			[(FSPGolfStandingsTableViewController *)[viewControllers objectAtIndex:0] setDrawDivider:YES]; // top left
			[(FSPGolfStandingsTableViewController *)[viewControllers objectAtIndex:2] setDrawDivider:YES]; // bottom left
			
			self.tableViewControllers = viewControllers;
        }
        else if ([self.organization isTop25]) {
            FSPStandingsTableViewController *leftTableViewController = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:nil managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
            leftTableViewController.pollType = FSPTeamRankingAPPollTypeKey;
            FSPStandingsTableViewController *rightTableViewController = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:nil managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
            rightTableViewController.pollType = FSPTeamRankingUsaTodayPollTypeKey;
            self.tableViewControllers = @[leftTableViewController, rightTableViewController];
		} else {
			NSString *conferenceName = nil;
			if (viewType == FSPFightingViewType) {
				standingsControllerClass = [FSPFightingStandingsTableViewController class];
			} else if (viewType == FSPNCAAFViewType) {
				standingsControllerClass = [FSPStandingsTableViewController class];
				conferenceName = self.currentOrganization.name;
				// [self.topTableViewController resetWithNewOrganization:self.currentOrganization];
			} else {
				standingsControllerClass = [FSPStandingsTableViewController class];
			}
            FSPStandingsTableViewController *topTableViewController = [[standingsControllerClass alloc] initWithOrganization:self.currentOrganization conferenceName:conferenceName managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
			topTableViewController.delegate = self;
			
			self.tableViewControllers = @[topTableViewController];

		}
		
		if (!(self.organization.viewType == FSPGolfViewType && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
			for (FSPStandingsTableViewController *vc in self.tableViewControllers) {
				[self.scrollView addSubview:vc.tableView];
			}
		} else {
			// this will select the default segment
			[self changeStatType:self.segmentedControl];
		}
	} else {
		for (FSPStandingsTableViewController *vc in self.tableViewControllers) {
			[vc resetWithNewOrganization:self.currentOrganization];
		}
	}
	
    NSString *orgName = self.currentOrganization.name;
    if ([self.currentOrganization isKindOfClass:[FSPTeam class]]) {
        orgName = [(FSPTeam *)[self currentOrganization] shortNameDisplayString];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", orgName, (viewType == FSPFightingViewType) ? @"Titleholders" : @"Standings"];
	
    for (FSPStandingsTableViewController *tableViewController in self.tableViewControllers) {
        [tableViewController.tableView reloadData];
        [self standingsTableViewDidUpdate:tableViewController.tableView];
    }
}

- (void)refreshStandings;
{
    if ([[self currentOrganization].viewTypeString rangeOfString:@"TOP25"].location != NSNotFound) {
        [self.dataCoordinator updateRankingsForOrganizationId:[self currentOrganization].objectID callback:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateStandings];
            });
        }];
    }
    else {
        [self.dataCoordinator updateStandingsForOrganizationId:[self currentOrganization].objectID callback:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateStandings];
            });
        }];
    }
}

// ABSTRACT THIS OUT
- (void)showOrganizationsContainerWithHeight:(CGFloat)containerHeight;
{
    CGRect containerFrame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        containerFrame = CGRectMake(0.0, 0.0, 320.0, containerHeight);
    } else {
        containerFrame = CGRectMake(0.0, 0.0, 647.0, containerHeight);
    }

    self.dropDownButton = [[FSPDropDownView alloc] initWithFrame:containerFrame];
	
    [self.dropDownButton setButtonTitle:self.currentSelectedConference.name];
    [self.dropDownButton.button addTarget:self action:@selector(toggleConferences:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dropDownButton];
}

- (void)toggleConferences:(UIButton *)sender;
{
	void (^completion)(FSPOrganization *) = ^(FSPOrganization *conference) {
		if (![[conference objectID] isEqual:[self.currentSelectedConference objectID]]) {
            // if the currentconference is 25 and the conference is not
            BOOL currentConferenceIsTop25 = [self.currentSelectedConference.viewTypeString rangeOfString:@"TOP25"].location != NSNotFound;
            BOOL newConferenceIsTop25 = [conference.viewTypeString rangeOfString:@"TOP25"].location != NSNotFound;
            if ((!currentConferenceIsTop25 && newConferenceIsTop25) || (currentConferenceIsTop25 && !newConferenceIsTop25)) {
                // If the conferences/rankings are added to the scroll view before they have data and are layed out.  See standingsTableViewDidUpdate.
                // weird things happen.
                self.didToggleRankings = YES;
                for (FSPStandingsTableViewController *vc in self.tableViewControllers) {
                    [vc.view removeFromSuperview];
                }
                if (newConferenceIsTop25) {
                    // Need 2 table views
                    FSPStandingsTableViewController *leftTableViewController = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:conference.name managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
                    leftTableViewController.pollType = FSPTeamRankingAPPollTypeKey;
                    FSPStandingsTableViewController *rightTableViewController = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:conference.name managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
                    rightTableViewController.pollType = FSPTeamRankingUsaTodayPollTypeKey;
                    self.tableViewControllers = @[leftTableViewController, rightTableViewController];
                }
                else {
                    // Back to 1
                    FSPStandingsTableViewController *tableViewController = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:conference.name managedObjectContext:self.managedObjectContext segment:self.segmentedControl.selectedSegmentIndex];
                    self.tableViewControllers = @[tableViewController];
                }
            }
            self.currentSelectedConference = conference;
            [self refreshStandings];
			
			FSPDropDownView *dropdown = nil;
			if ([[sender superview] isKindOfClass:[FSPDropDownView class]]) {
				dropdown = (FSPDropDownView *)[sender superview];
			}
			[dropdown setButtonTitle:conference.name];
		}
		[self.popoverController dismissPopoverAnimated:YES];
		[self dismissOverlayViewControllerAnimated:YES];
	};
	
    NSMutableSet *noVirtualOrgs = [NSMutableSet set];
    for (FSPOrganization *org in self.organization.children) {
        if (![org isVirtualConference] || [org isTop25]) {
            [noVirtualOrgs addObject:org];
        }
    }

	FSPConferencesModalViewController *confrencesViewController = [[FSPConferencesModalViewController alloc] initWithOrganizations:noVirtualOrgs
																												 includeTournamets:NO
																															 style:UITableViewStyleGrouped
																										selectionCompletionHandler:completion];
	confrencesViewController.selectedConference = self.currentSelectedConference;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:confrencesViewController];
	navController.navigationBar.barStyle = UIBarStyleBlack;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        [self.popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
		if (!self.pseudoModalViewController) {
			FSPConferencesOverlayViewController *otherConfrencesViewController = [[FSPConferencesOverlayViewController alloc] initWithOrganizations:noVirtualOrgs
																																  includeTournamets:NO
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

- (IBAction)updateSelectedSegment:(FSPSegmentedControl *)sender;
{
    if (self.organization.viewType == FSPHockeyViewType || self.organization.viewType == FSPBasketballViewType) {
        // remove tables from superviews
        for (FSPStandingsTableViewController *vc in self.tableViewControllers) {
            [vc.view removeFromSuperview];
        }
        NSMutableArray *tableViews = [NSMutableArray array];
        // remove tables from tvc array
        // if the selected segment index == 1
        if (sender.selectedSegmentIndex == 1) {
            // count up the division names
            NSArray *divisionNames = [self divisionNamesForBranch:self.organization.branch];
            // add enough tvc's to fit all the divisions to the tvc array
            for (NSString *name in divisionNames) {
                 // these are inited with segment index == 1 so do different things in tvc's
                FSPStandingsTableViewController *vc = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:name managedObjectContext:self.managedObjectContext segment:sender.selectedSegmentIndex];
                [tableViews addObject:vc];
            }
        }
        else {
            NSArray *conferenceNames = [self conferenceNamesForBranch:self.organization.branch];
            for (NSString *name in conferenceNames) {
                FSPStandingsTableViewController *vc = [[FSPStandingsTableViewController alloc] initWithOrganization:self.organization conferenceName:name managedObjectContext:self.managedObjectContext segment:sender.selectedSegmentIndex];
                [tableViews addObject:vc];
            }

        }
        self.tableViewControllers = tableViews;
        for (FSPStandingsTableViewController *vc in self.tableViewControllers) {
            [self.scrollView addSubview:vc.view];
        }
    }
    [self updateStandings];
	[self refreshStandings];
}

- (void)updateSelectedConference:(FSPSegmentedControl *)sender
{
	FSPOrganization *conference = [[self orderedConferences] objectAtIndex:sender.selectedSegmentIndex];
	self.currentSelectedConference = conference;
	[self updateStandings];
	[self refreshStandings];
}

- (void)changeStatType:(FSPSegmentedControl *)sender
{
	[self.currentTableView removeFromSuperview];
	
	self.currentTableView = [[self.tableViewControllers objectAtIndex:sender.selectedSegmentIndex] tableView];
	self.currentTableView.frame = self.scrollView.bounds;
	[self.scrollView addSubview:self.currentTableView];
	
}

#pragma mark - conferences selector overlay

- (void)presentOverlayViewController:(FSPConferencesOverlayViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
{
	if (self.pseudoModalViewController) {
		[self.pseudoModalViewController.overlay removeFromSuperview];
	}
	self.pseudoModalViewController = viewController;
	
	if ([viewController respondsToSelector:@selector(setOverlayPresentingViewController:)]) {
		[(id)viewController setOverlayPresentingViewController:self];
	}
	
	viewController.overlay = [[FSPConferencesOverlayContainerView alloc] initWithFrame:self.scrollView.frame];
	viewController.overlay.alpha = 0.0;
	
	CGSize contentSize = viewController.contentSizeForViewInPopover;
	if (contentSize.height > self.scrollView.bounds.size.height) {
		contentSize.height = self.scrollView.bounds.size.height;
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

- (void)dismissOverlayViewControllerAnimated:(BOOL)animated;
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

