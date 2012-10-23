//
//  RootViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRootViewController.h"
#import "FSPAllMyEventsContainerViewController.h"
#import "FSPAppDelegate.h"
#import "FSPConfiguration.h"
#import "FSPCoreDataManager.h"
#import "FSPCustomizationViewController.h"
#import "FSPDataCoordinator.h"
#import "FSPEventDetailContainerViewController.h"
#import "FSPEventsContainerViewController.h"
#import "FSPFootballDNAViewController.h"
#import "FSPMassRelevanceViewController.h"
#import "FSPNetworkNotifier.h"
#import "FSPOrganizationsHeaderView.h"
#import "FSPSettingsViewController.h"
#import "FSPAdManager.h"
#import "FSPSlidingAdView.h"
#import "FSPSportsNewsContainerViewController.h"
#import "FSPStoryViewController.h"
#import "FSPTveLoginViewController.h"
#import "WebViewController.h"
#import "FSPVideoDetailViewController.h"
#import "FSPNewsHeadline.h"
#import "FSPTeam.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSDictionary+FSPExtensions.h"
#import "NSUserDefaults+FSPExtensions.h"
#import "FSPPollingCenter.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMailComposeViewController.h>


static NSTimeInterval FSPTransitionToFromFullScreenModeDuration = 0.28;
static NSTimeInterval FSPTransitionToFromFullScreenModeDelay = 0.0;
static NSTimeInterval FSPOrganizationFetchRetryIntervalSeconds = 10.0;

static NSTimeInterval FSPCustomizationTranstionDuration = 0.32;

static CGFloat FSPViewControllerModalWidth = 647.0; // Width of the standings/schedule modal window.

NSString * const FSPRootViewControllerWillTransitionToFullScreenNotification = @"FSPRootViewControllerWillTransitionToFullScreenNotification";
NSString * const FSPRootViewControllerDidTransitionToFullScreenNotification = @"FSPRootViewControllerDidTransitionToFullScreenNotification";
NSString * const FSPRootViewControllerWillTransitionFromFullScreenNotification = @"FSPRootViewControllerWillTransitionFromFullScreenNotification";
NSString * const FSPRootViewControllerDidTransitionFromFullScreenNotification = @"FSPRootViewControllerDidTransitionFromFullScreenNotification";

const int FSPHeaderTransformOffset = 36;
const int FSPHeaderLogoTransformOffset = 119;
const int FSPHeaderFlareTransformation = -86;

@interface FSPRootViewController()
@property (nonatomic, strong, readwrite) UIViewController *detailViewController;

@property (nonatomic, weak) IBOutlet UIView *eventDetailView;
@property (nonatomic, strong) FSPSlidingAdView *adView;
@property (nonatomic, strong) NSTimer *adDismissTimer;
@property (nonatomic, weak) IBOutlet UIButton *showHideButton;
@property (nonatomic, weak) IBOutlet UILabel *headerTitleLabel;

@property (nonatomic, weak) IBOutlet UIView *extraDetailContainerView;
@property (nonatomic, weak) IBOutlet UIView *organizationsView;
@property (nonatomic, weak) IBOutlet UIView *chipsContainerView;

@property (nonatomic, weak) IBOutlet UIView *headerContainer;
@property (nonatomic, weak) IBOutlet UIView *customizationContainer;
@property (nonatomic, weak) IBOutlet UIButton *customizeButton;

@property (nonatomic, weak) IBOutlet UIImageView *flareImageView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

@property (nonatomic, strong, readwrite) UIViewController *presentedSlideInViewController;
@property (nonatomic, strong) UIView *eventDetailOverlayView;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, weak) IBOutlet UINavigationBar *columnANavigationBar;

@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerViewController;

@property (weak, nonatomic) IBOutlet UIImageView *columnBRightShadow;
@property (weak, nonatomic) IBOutlet UIImageView *columnBLeftShadow;
@property (weak, nonatomic) IBOutlet UIImageView *columnALeftShadow;
@property (weak, nonatomic) IBOutlet UIView *dnaView;

@property (nonatomic, strong) FSPFootballDNAViewController *dna;
@property (nonatomic, strong) FSPMassRelevanceViewController *massRelevance;

@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;
@property (nonatomic, strong) NSTimer *initialOrgFetchAction;
@property (nonatomic, strong) NSTimer *initialTeamFetchAction;

- (void)updateOrganizationsView;
- (void)updateChipsContainerView;
- (void)updateDetailView;
- (void)updateExtraDetailView;
- (void)updateCustomizationView;
- (void)updateView:(UIView *)container withViewController:(UIViewController *)viewController;
- (void)swapViewController:(UIViewController *)newViewController forViewController:(UIViewController *)viewController;
- (void)updateOffscreenViewController:(UIViewController *)offscreenViewController;
- (void)updateAllContainerViews;

- (void)setAdViewVisible:(BOOL)visible animated:(BOOL)animated;
- (void)showAdViewAnimated:(BOOL)animated;
- (void)hideAdViewAnimated:(BOOL)animated;
- (void)adDismissTimerFired:(NSTimer *)timer;

- (IBAction)showHideButtonWasPressed:(id)sender;
- (void)updateShowHideButtonTitle:(BOOL)showMenu;

// Full Sceen Mode helpers
- (void)setMasterViewsInFullScreenMode:(BOOL)inFullScreen animated:(BOOL)animated;
- (void)performFullScreenTransition:(BOOL)toFullScreen animated:(BOOL)animated;

// Customization mode helpers
- (void)performCustomizationModeTransition:(BOOL)toFullScreen animated:(BOOL)animated;
- (IBAction)settingsButtonTapped:(UIButton *)sender;

- (void)performInitialLaunchUpdating;
- (void)setupForOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end


@implementation FSPRootViewController {
    BOOL adIsPresented;
    CGRect orginalAdFrame;
    BOOL eventsHidden;
    BOOL hasUpdatedOrgs;
    BOOL hasUpdatedAllTeams;
    id networkCallbackIdentifier;
    
    struct {
        unsigned int isFullScreen:1;
        unsigned int inTransition:1;
    } fullScreenFlags;
    
    struct {
        unsigned int inCustomizationMode:1;
        unsigned int inTransition:1;
    } customizationFlags;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

+ (FSPRootViewController *)rootViewController;
{
    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController;
}

+ (UIView *)rootDNAView
{
    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController.dnaView;
}

+ (FSPMassRelevanceViewController *)massRelevanceView
{
    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.rootViewController.massRelevance;
}

- (void)setNewMassRelevance:(Class)newClass
{
    if (self.massRelevance)
    {
        if (self.massRelevance.class != newClass) //dont destroy if its the same as the current one
            self.massRelevance = nil; //destroy old one and create new one
    }
    
    if (!self.massRelevance)
    {
        self.massRelevance = [[newClass alloc] initWithNibName:NSStringFromClass(newClass) bundle:nil];
        [self setExtraDetailViewController:self.massRelevance];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self updateAllContainerViews];
    
	CGRect adViewFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad setup        
        adViewFrame = CGRectMake(self.eventDetailView.frame.origin.x + ((self.eventDetailView.bounds.size.width - 650.0) / 2.0), CGRectGetMaxY(self.view.bounds), 650.0, 80.0);
        
        self.columnBRightShadow.image = [[UIImage imageNamed:@"shadow-column-b"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        self.columnALeftShadow.image = [[UIImage imageNamed:@"shadow-customization"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//		self.columnALeftShadow.layer.borderWidth = 1.0;
//		self.columnALeftShadow.layer.borderColor = [UIColor greenColor].CGColor;
        
    } else { // iPhone setup
		adViewFrame = CGRectMake(0, self.view.bounds.size.height - 50, 320, 50);
        
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[settingsButton setImage:[UIImage imageNamed:@"A_Settings.png"] forState:UIControlStateNormal];
		[settingsButton sizeToFit];
        UIView *settingButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, settingsButton.frame.size.width + 25, settingsButton.frame.size.height)];
        [settingButtonContainer addSubview:settingsButton];
        settingsButton.frame = CGRectMake(settingsButton.frame.origin.x + 12, settingsButton.frame.origin.y + 2, settingsButton.frame.size.width, settingsButton.frame.size.height);
		[settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        //Add Fox Logo and center it below the shine
		UINavigationItem *item = [[UINavigationItem alloc] init];
        UIImageView *FoxLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Fox_Logo"]];
        UIView *smallLogoContainer = [[UIView alloc]initWithFrame:FoxLogo.frame];
        item.titleView = smallLogoContainer;
        [smallLogoContainer addSubview:FoxLogo];
        FoxLogo.frame = CGRectMake(item.titleView.frame.origin.x, item.titleView.frame.origin.y + 10, item.titleView.frame.size.width - 16, item.titleView.frame.size.height - 14);
		item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButtonContainer];
		self.columnANavigationBar.items = @[item];

	}
    
    //sets first Mass Relevance View Controller
    [self setNewMassRelevance:[FSPMassRelevanceViewController class]];
    
//	adViewFrame = [self.view convertRect:adViewFrame toView:self.view.window];
//	self.adView = [[FSPSlidingAdView alloc] initWithFrame:adViewFrame];
//	self.adView.alpha = 0.0;
//	[[FSPAdManager sharedManager] requestAdViewForAdType:FSPAdTypeEventDetailHeader delegate:self.adView acceptHouseAd:YES];
//	[self.adView.dismissButton addTarget:self action:@selector(dismissAd:) forControlEvents:UIControlEventTouchUpInside];
//	
//	orginalAdFrame = adViewFrame;
//	[self.view addSubview:self.adView];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // iPad setup        
		[self showAdViewAnimated:YES];
#if 0
        if (!dna)
            dna = [[FSPFootballDNAViewController alloc] initWithNibName:@"FSPFootballDNAViewController" bundle:nil];
        [self.dnaView addSubview:dna.view];
        self.dnaView.backgroundColor = [UIColor redColor];
#endif
	}

    self.headerTitleLabel.font = [UIFont fontWithName:FSPUScoreRGKFontName size:20.0];
    self.headerTitleLabel.accessibilityIdentifier = @"chipHeaderTitle";
    self.eventDetailView.accessibilityIdentifier = @"eventDetails";

    [self setChipsContainerViewControllerHidden:NO animated:NO];
    // add left shadow to the chips controller so when it slides over there is a shadow between it and the orgs
    UIImageView *chipsLeftShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow-column-b-left"]];
    [self.chipsContainerView addSubview:chipsLeftShadow];
    chipsLeftShadow.frame = CGRectMake(-5, 0, 16, 480);

    [self.showHideButton setBackgroundImage:[UIImage imageNamed:@"dropdown_button_bckrnd"] forState:UIControlStateNormal];
    [self.showHideButton setImage:[UIImage imageNamed:@"chevron_down"] forState:UIControlStateNormal];

    [self updateShowHideButtonTitle:[[NSUserDefaults standardUserDefaults] boolForKey:FSPDropDownExtendedKey]];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    self.chipsContainerView = nil;
    self.organizationsView = nil;
    self.extraDetailContainerView = nil;
    self.columnBRightShadow = nil;
    self.columnBLeftShadow = nil;
    self.dnaView = nil;
    [super viewDidUnload];
}

#pragma mark - Orientation Setup

- (void)setupForOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // we don't change orientations on the iPhone
        return;
    }
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {        
        self.chipsContainerView.hidden = NO;
        self.columnBRightShadow.hidden = NO;
        self.columnBLeftShadow.hidden = NO;
		self.columnALeftShadow.hidden = NO;
        self.headerContainer.hidden = NO;

    } else {
        self.chipsContainerView.hidden = YES;
        self.columnBRightShadow.hidden = YES;
        self.columnBLeftShadow.hidden = YES;
		self.columnALeftShadow.hidden = YES;
        self.headerContainer.hidden = YES;

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
#if 0
        return YES;
#else
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
#endif
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self setupForOrientation:toInterfaceOrientation];
}

#pragma mark - Initial Launch

- (void)performInitialLaunchUpdating;
{
    void (^updateTeamsBlock)(void) = ^{
        self.initialTeamFetchAction = [[FSPPollingCenter defaultCenter] addPollingActionForKey:FSPTeamsPollingActionKey timeInterval:FSPOrganizationFetchRetryIntervalSeconds
                                                                                             usingBlock:^{
            [self.dataCoordinator updateAllTeamsForAllOrganizations:^(BOOL success) {
                if (success && !hasUpdatedAllTeams && networkCallbackIdentifier) {
                    [[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPTeamsPollingActionKey];
                    [[FSPNetworkNotifier defaultNotifier] removeNetworkDidChangeBlock:networkCallbackIdentifier];
                    networkCallbackIdentifier = nil;

                    // Start listening for configuration changes
                    [self.dataCoordinator beginUpdatingConfiguration];
                    [[FSPCoreDataManager sharedManager] synchronizeSavingWithCallback:^{
                        hasUpdatedAllTeams = YES;
                    }];
                }
            }];
        }];
    };
    
    if (!networkCallbackIdentifier) {
        FSPRootViewController *weakSelf = self;
        networkCallbackIdentifier = [[FSPNetworkNotifier defaultNotifier] addNetworkDidChangeBlock:^(FSPNetworkType fromType, FSPNetworkType toType) {
            if ((fromType == FSPNetworkUnknownType) && (toType != FSPNetworkUnknownType))
                [weakSelf performInitialLaunchUpdating];
        }];
    }
    
    if (!hasUpdatedOrgs) {
        self.initialOrgFetchAction = [[FSPPollingCenter defaultCenter] addPollingActionForKey:FSPOrgsPollingActionKey timeInterval:FSPOrganizationFetchRetryIntervalSeconds
                                                                                            usingBlock:^{
            [self.dataCoordinator updateAllOrganizationsCallback:^(BOOL success, NSDictionary *userInfo) {
                if (success && !hasUpdatedOrgs) {
                    [[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPOrgsPollingActionKey];
                    [[FSPCoreDataManager sharedManager] synchronizeSavingWithCallback:^{
                        hasUpdatedOrgs = YES;
                    }];
                }
            }];
        }];
        updateTeamsBlock();
    } else if (!hasUpdatedAllTeams) {
        updateTeamsBlock();
    } else {
		// if we've already done all the initial stuff, still update the configuration feed when the application becomes active.
		[self.dataCoordinator beginUpdatingConfiguration];
	}
}

#pragma mark - View Controller Management
- (void)updateView:(UIView *)container withViewController:(UIViewController *)viewController;
{
    if (![viewController.view superview]) {
        viewController.view.frame = container.bounds;
        [container addSubview:viewController.view];
    }
}

- (void)swapViewController:(UIViewController *)newViewController forViewController:(UIViewController *)viewController 
{
    if (viewController != newViewController) {
        if (viewController != nil) {
            // remove it
            [viewController willMoveToParentViewController:nil];
            if (viewController.isViewLoaded)
                [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
                
        if (newViewController != nil) {
            // add it
            [self addChildViewController:newViewController];
            [newViewController didMoveToParentViewController:self];
        }
    }
}

- (void)updateOffscreenViewController:(UIViewController *)offscreenViewController;
{
    if (offscreenViewController.isViewLoaded) {
        [offscreenViewController.view removeFromSuperview];
    }
}

- (void)updateAllContainerViews;
{
    [self updateOrganizationsView];
    [self updateChipsContainerView];
    [self updateDetailView];
    [self updateExtraDetailView];
    [self updateCustomizationView];
}

#pragma mark - Oranizations View
- (void)updateOrganizationsView;
{
    if (fullScreenFlags.isFullScreen && !fullScreenFlags.inTransition) {
        [self updateOffscreenViewController:self.organizationsViewController];
    } else {
        [self updateView:self.organizationsView withViewController:self.organizationsViewController];
    }
}

- (void)setOrganizationsViewController:(FSPOrganizationsViewController *)newOrganizationsViewController
{
    [self swapViewController:newOrganizationsViewController forViewController:_organizationsViewController];
    _organizationsViewController = newOrganizationsViewController;
    
    if (_organizationsViewController != nil && self.isViewLoaded) {
        [self updateOrganizationsView];
    }
}

#pragma mark - Event View
- (void)updateChipsContainerView;
{
    if (fullScreenFlags.isFullScreen && !fullScreenFlags.inTransition) {
        [self updateOffscreenViewController:self.chipsContainerViewController];
    } else {
        if (self.chipsContainerViewController == nil) {
			// Select the last organization
			NSIndexPath *indexPath = [[NSUserDefaults standardUserDefaults] fsp_indexPathForKey:@"lastSelectedOrganization"];
			// TODO : get rid of this check once favorites are saving
			if (!indexPath || indexPath.section == FSPOrganizationFavoritesSection) {
				indexPath = [NSIndexPath indexPathForRow:FSPOrganizationsPersistentCellsNewsRow inSection:FSPOrganizationsPersistentCellsSection];
			}
			if (indexPath.row < [self.organizationsViewController tableView:self.organizationsViewController.tableView numberOfRowsInSection:indexPath.section]) {
				[self.organizationsViewController.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
				[self.organizationsViewController tableView:self.organizationsViewController.tableView didSelectRowAtIndexPath:indexPath];
			}
        }
        [self updateView:self.chipsContainerView withViewController:self.chipsContainerViewController];
    }
}

- (void)setChipsContainerViewController:(FSPEventsContainerViewController *)newChipsContainerViewController;
{
    [self swapViewController:newChipsContainerViewController forViewController:_chipsContainerViewController];
    _chipsContainerViewController = newChipsContainerViewController;
    
    if (_chipsContainerViewController != nil && self.isViewLoaded) {
        [self updateChipsContainerView];

        if ([_chipsContainerViewController respondsToSelector:@selector(dropDownMenu)]) {
            self.showHideButton.hidden = !(_chipsContainerViewController.dropDownMenu.sectionsHeight > 0);
        }
        
        self.headerTitleLabel.text = _chipsContainerViewController.title.uppercaseString;
    }
}

- (void)setChipsContainerViewControllerHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
	
    eventsHidden = hidden;

    // Figure out how much time the animation should be
    static NSTimeInterval baseDuration = 0.21;
    static CGFloat hiddenEventsWidth = 44.0;
    CGFloat currentX = self.chipsContainerView.frame.origin.x;
    CGFloat destinationX;
    if (hidden) {
        destinationX = CGRectGetMaxX(self.view.frame) - hiddenEventsWidth;
    } else {
        destinationX = 0.0;
    }

    CGFloat fullTravelDistanceX = self.view.bounds.size.width;
    if (fullTravelDistanceX == 0) {
        fullTravelDistanceX = 1.0;
    }
    CGFloat travelDistanceX = ABS(destinationX - currentX);
    CGFloat travelPercentageX = travelDistanceX / fullTravelDistanceX;
    
    NSTimeInterval duration = travelPercentageX * baseDuration;

    [UIView animateWithDuration:animated ? duration : 0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.chipsContainerView.frame;
        frame.origin.x = destinationX;
        self.chipsContainerView.frame = frame;
    } completion:^(BOOL completed){
        //This should be true on the iPhone
        if ([self.chipsContainerViewController isKindOfClass:[UINavigationController class]]) {
            NSArray *viewControllers = [(UINavigationController *)self.chipsContainerViewController viewControllers];
            if (viewControllers.count) {
                FSPEventsContainerViewController *rootViewController = [viewControllers objectAtIndex:0];
                if ([rootViewController isKindOfClass:[FSPChipsContainerViewController class]])
                    rootViewController.hidden = hidden;
            }
        }
    }];
	
	[self.organizationsViewController.tableView setEditing:NO animated:animated];
}

- (IBAction)showHideButtonWasPressed:(id)sender;
{
    BOOL showMenu = !self.chipsContainerViewController.isDropDownMenuExtended;
    [self updateShowHideButtonTitle:showMenu];
    [self.chipsContainerViewController setDropDownMenuExtended:showMenu animated:YES];
}

- (void)updateShowHideButtonTitle:(BOOL)showMenu;
{
    self.showHideButton.accessibilityLabel = showMenu ? NSLocalizedString(FSPDropDownToggleHideLabel, nil) : NSLocalizedString(FSPDropDownToggleShowLabel, nil);
    
    UIImage *chevron = nil;
    if (showMenu) {
        chevron = [UIImage imageNamed:@"chevron_up"];
    } else {
        chevron = [UIImage imageNamed:@"chevron_down"];
    }
    [self.showHideButton setImage:chevron forState:UIControlStateNormal];
}


#pragma mark - Detail View
- (void)updateDetailView;
{
    [self updateView:self.eventDetailView withViewController:self.detailViewController];
}

- (void)setDetailViewController:(UIViewController *)newDetailViewController;
{
    [self swapViewController:newDetailViewController forViewController:_detailViewController];
    _detailViewController = newDetailViewController;
    
    if (_detailViewController != nil && self.isViewLoaded) {
        [self updateDetailView];
    }
}

#pragma mark - Extra Detail View
- (void)updateExtraDetailView;
{
    if (!fullScreenFlags.isFullScreen && !fullScreenFlags.inTransition) {
        [self updateOffscreenViewController:self.extraDetailViewController];
    } else {
        [self updateView:self.extraDetailContainerView withViewController:self.extraDetailViewController];
    }
}

- (void)setExtraDetailViewController:(UIViewController *)newViewController;
{
    [self swapViewController:newViewController forViewController:_extraDetailViewController];
    _extraDetailViewController = newViewController;
    
    if (_extraDetailViewController != nil && self.isViewLoaded) {
        [self updateExtraDetailView];
    }
}

#pragma mark - Customization View
- (void)updateCustomizationView;
{
    if (!customizationFlags.inCustomizationMode && !customizationFlags.inTransition) {
        [self updateOffscreenViewController:self.customizationViewController];
    } else {
        [self updateView:self.customizationContainer withViewController:self.customizationViewController];
    }
}

- (void)setCustomizationViewController:(FSPCustomizationViewController *)newViewController;
{
    [self swapViewController:newViewController forViewController:_customizationViewController];
    _customizationViewController = newViewController;
    
    if (_customizationViewController != nil && self.isViewLoaded) {
        [self updateCustomizationView];
    }
}

#pragma mark - Schedule / Scores View

- (void)slideInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (self.presentedSlideInViewController) {
		[self slideOutViewControllerAnimated:animated];
	}
	self.presentedSlideInViewController = viewController;
	
	UIView *orgView = self.organizationsViewController.view;
    CGSize viewSize = viewController.view.frame.size;
    
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orgView.frame), self.view.bounds.size.height - viewSize.height, viewSize.width, viewSize.height)];
	containerView.clipsToBounds = YES;

	viewController.view.frame = CGRectMake(-viewSize.width, 0, viewSize.width, viewSize.height);

	[containerView addSubview:viewController.view];
	[self.view addSubview:containerView];
	
	UIView *overlay = [[UIView alloc] initWithFrame:self.eventDetailView.bounds];
	overlay.backgroundColor = [UIColor blackColor];
	overlay.alpha = 0.0;
	[self.eventDetailView addSubview:overlay];
	self.eventDetailOverlayView = overlay;

	[UIView animateWithDuration:0.6 delay:0.0 
						options:UIViewAnimationCurveEaseIn
					 animations:^{
						 CGRect frame = viewController.view.frame;
						 frame.origin.x = 0;
						 viewController.view.frame = frame;
						 overlay.alpha = 0.8;
						 self.showHideButton.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
						 self.showHideButton.hidden = YES;
					 }];
}

- (void)slideOutViewControllerAnimated:(BOOL)animated completion:(void (^)())completion
{
	UIViewController *viewController = self.presentedSlideInViewController;
	UIView *overlay = self.eventDetailOverlayView;
	
	BOOL hide = !(self.chipsContainerViewController.dropDownMenu.sectionsHeight > 0);
	self.showHideButton.alpha = 0.0;
	self.showHideButton.hidden = NO;
	
	[UIView animateWithDuration:0.6 delay:0.0
						options:UIViewAnimationCurveEaseIn
					 animations:^{
						 CGRect frame = viewController.view.frame;
						 frame.origin.x -= frame.size.width;
						 viewController.view.frame = frame;
						 overlay.alpha = 0.0;
						 self.showHideButton.alpha = (hide) ? 0.0 : 1.0;
					 } 
					 completion:^(BOOL finished) {
						 [[viewController.view superview] removeFromSuperview];
						 if (viewController == self.presentedSlideInViewController) {
							 self.presentedSlideInViewController = nil;
						 }
						 [overlay removeFromSuperview];
						 if (overlay == self.eventDetailOverlayView) {
							 self.eventDetailOverlayView = nil;
						 }
						 self.showHideButton.hidden = hide;

						 if (completion) completion();
					 }];
}

- (void)slideOutViewControllerAnimated:(BOOL)animated
{
	[self slideOutViewControllerAnimated:animated completion:nil];
}

- (void)displayModalViewController:(UIViewController *)placeholder animated:(BOOL)animated;
{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeModalViewController)];
    UIImage *backgroundImage = [[UIImage imageNamed:@"close_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    [barItem setBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSDictionary *closeButtonTextAttributes = @{UITextAttributeFont: [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:13.0]};
    [barItem setTitleTextAttributes:closeButtonTextAttributes forState:UIControlStateNormal];
    [barItem setTitlePositionAdjustment:UIOffsetMake(0.0, 3.0) forBarMetrics:UIBarMetricsDefault];
    placeholder.navigationItem.rightBarButtonItem = barItem;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:placeholder];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navController.view.frame = CGRectMake(0.0, 0.0, FSPViewControllerModalWidth, 686.0);
        UIFont *font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0];
        navController.navigationBar.titleTextAttributes = @{UITextAttributeFont: font,
                                                           UITextAttributeTextColor: [UIColor whiteColor]};
        [navController.navigationBar setTitleVerticalPositionAdjustment:7.0 forBarMetrics:UIBarMetricsDefault];
    }
    
    [navController.navigationBar setBackgroundImage:[self modalNavigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
        
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self slideInViewController:navController animated:animated];
	} else {
		[self presentModalViewController:navController animated:animated];
	}
}

- (void)closeModalViewController;
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self slideOutViewControllerAnimated:YES];
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (UIImage *)modalNavigationBarBackgroundImage;
{
    static UIImage *modalBackgroundImage;
    if (!modalBackgroundImage) {
        CGFloat width;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            width = FSPViewControllerModalWidth;
        else //The navigation bar will be the width of the view controller
            width = self.view.bounds.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, 44.0));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        //Draw horizontal gradient
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {
            0.0 / 255.0, 66.0 / 255.0, 159.0 / 255.0, 1.0,
            14.0 / 255.0, 92.0 / 255.0, 207 / 255.0, 1.0,
            0.0 / 255.0, 66.0 / 255.0, 159.0 / 255.0, 1.0
        };
        CGFloat locations[] = { 0.0, 0.5, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 3);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(width, 0.0), 0);
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
        
        //Draw top highlight line
        CGPoint topSegment[] = { CGPointMake(0.0, 0.0), CGPointMake(width, 0.0) };
        [[UIColor fsp_colorWithIntegralRed:54 green:144 blue:228 alpha:1.0] setStroke];
        CGContextStrokeLineSegments(context, topSegment, 2);
        
        //Draw bottom black line
        CGPoint bottomSegment[] = { CGPointMake(0.0, 44.0), CGPointMake(width, 44.0) };
        [[UIColor blackColor] setStroke];
        CGContextStrokeLineSegments(context, bottomSegment, 2);
        modalBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        CGContextRestoreGState(context);
    }
    
    return modalBackgroundImage;
}


#pragma mark - :: Delegates ::
#pragma mark - FSPDropDownContainerViewControllerDelegate
- (void)dropDownContainerViewController:(FSPDropDownContainerViewController *)viewController didChangeDropDownMenuState:(BOOL)showMenu;
{
    if (self.chipsContainerViewController == viewController) {
        [self updateShowHideButtonTitle:showMenu];
    }
}

#pragma mark - FSPEventsViewControllerDelegate
- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectEvent:(FSPEvent *)event
{
    if (event == nil) {
        self.detailViewController = nil;
        return;
    }
    
	FSPEventDetailContainerViewController *eventDetailContainerViewController = [[FSPEventDetailContainerViewController alloc] init];
	eventDetailContainerViewController.event = event;
	[self setOrPushNewDetailController:eventDetailContainerViewController];
    
    //if ([event.branch isEqualToString:FSPNFLEventBranchType]) {
        self.dna.currentEvent = event;
    //}
}

- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectNewsHeadline:(FSPNewsHeadline *)headline
{
	FSPStoryViewController *storyViewController = nil;
	storyViewController = [[FSPStoryViewController alloc] initWithStoryType:FSPStoryTypeNews];
	[self setOrPushNewDetailController:storyViewController];

	[self.dataCoordinator asynchronouslyLoadNewsStoryForHeadline:headline.objectID success:^(FSPNewsStory *story) {
		storyViewController.story = story;

	} failure:^(NSError *error) {
		NSLog(@"Error fetching story for headline %@:%@", headline, error);
	}];
}

- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectVideo:(FSPVideo *)video;
{
    if (video == nil) {
        self.detailViewController = nil;
        return;
    }
	
	FSPVideoDetailViewController *videoViewController = [[FSPVideoDetailViewController alloc] initWithVideo:video];
	videoViewController.video = video;
	[self setOrPushNewDetailController:videoViewController];
}

- (void)setOrPushNewDetailController:(UIViewController *)newController
{
    [self setAdViewVisible:YES animated:YES];

    if (newController != nil) {
        self.detailViewController = newController;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [self.chipsContainerViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.chipsContainerViewController pushViewController:self.detailViewController animated:YES];
    }
}


#pragma mark - FSPChipsContainerViewControllerDelegate
- (void)chipsContainerViewControllerToggleHidden:(FSPEventsContainerViewController *)viewController
{
    BOOL hidden = !eventsHidden;
    [self setChipsContainerViewControllerHidden:hidden animated:YES];
}

- (void)chipsContainerViewController:(FSPEventsContainerViewController *)viewController didPanWithGesture:(UIPanGestureRecognizer *)gesture;
{
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded:
        {
            // It is done, figure out if we are moving in any direction and react
            static CGFloat velocityThreshold = 75.0;
            static CGFloat horizontalThreshold = 30.0;
            CGPoint velocity = [gesture velocityInView:viewController.view.superview];
            BOOL hidden = NO;;
            if (velocity.x > velocityThreshold) {
                // it is moving right
                hidden = YES;
            } else if (velocity.x < -velocityThreshold) {
                hidden = NO;
            } else {
                // determine its position and send it somewhere
                CGFloat currentX = self.chipsContainerView.frame.origin.x;
                if (currentX <= horizontalThreshold) {
                    hidden = NO;
                } else {
                    hidden = YES;
                }

            }
            [self setChipsContainerViewControllerHidden:hidden animated:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            // It is moving
            CGFloat rightThreshold = self.view.bounds.size.width;
            BOOL resetGesture = YES;
            float newX = [gesture translationInView:viewController.view.superview].x;
            CGRect newFrame = self.chipsContainerView.frame;
            newFrame.origin.x += newX;
            if (newFrame.origin.x < 0.0) {
                newFrame.origin.x = 0.0;
                resetGesture = NO;
            } else if (newFrame.origin.x > rightThreshold) {
                newFrame.origin.x = rightThreshold;
                resetGesture = NO;
            }
            self.chipsContainerView.frame = newFrame;
            
            if (resetGesture) {
                [gesture setTranslation:CGPointZero inView:viewController.view.superview];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - FSPOrganizationsViewControllerDelegate

- (void)dismissPopover;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} 
}

- (void)presentNewChipsContainerViewController:(FSPChipsContainerViewController *)newViewController;
{
    newViewController.chipsContainerDelegate = self;
    newViewController.dropDownContainerDelegate = self;
    
    if (self.presentedSlideInViewController) {
		[self slideOutViewControllerAnimated:YES];
	}
    
    if (self.chipsContainerViewController) {
        [self.chipsContainerViewController willMoveToParentViewController:nil];
        [self.chipsContainerViewController.view removeFromSuperview];
        [self.chipsContainerViewController removeFromParentViewController];
        self.chipsContainerViewController = nil;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.chipsContainerViewController = newViewController;
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.view.window) {
            
            // display in popover
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.chipsContainerViewController];
            
            if (!self.popover) {
                
                self.popover = [[UIPopoverController alloc] initWithContentViewController:navController];
                self.popover.delegate = self;
                
                UITableView *orgTableView = self.organizationsViewController.tableView;
                NSIndexPath *indexPath = [[NSUserDefaults standardUserDefaults] fsp_indexPathForKey:@"lastSelectedOrganization"];
                CGRect rectInTableView = [orgTableView rectForRowAtIndexPath:indexPath];
                
                [self.popover presentPopoverFromRect:[orgTableView convertRect:rectInTableView toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            } else {
                [self.popover dismissPopoverAnimated:YES];
            }
        }
        
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newViewController];
        navController.navigationBar.tintColor = [UIColor grayColor];
        UIFont *font = [UIFont fontWithName:FSPUScoreRGKFontName size:20.0f];
        navController.navigationBar.titleTextAttributes = @{UITextAttributeFont: font};
        
        //This adjusts the header title so the text will be centered vertically
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 44)];
        UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(container.frame.origin.x, container.frame.origin.y + 4, container.frame.size.width, container.frame.size.height - 4)];
        headerText.font = font;
        headerText.backgroundColor = [UIColor clearColor];
        headerText.textColor = [UIColor whiteColor];
        headerText.textAlignment = UITextAlignmentCenter;
        headerText.text = newViewController.title;
        [container addSubview:headerText];

        UIImage *homeImage = [[UIImage imageNamed:@"back_button"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        [backItem setBackButtonBackgroundImage:homeImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        for (UIViewController *viewController in navController.viewControllers) {
            viewController.navigationItem.backBarButtonItem = backItem;
        }
        
        for (UINavigationItem *item in navController.navigationBar.items) {
            item.titleView = container;
        }
        
        newViewController.hidden = YES;
        self.chipsContainerViewController = (id)navController;
    }
    
    [self setChipsContainerViewControllerHidden:NO animated:YES];
}

- (IBAction)cancel:(id)sender {
    if ([self.chipsContainerViewController isKindOfClass:[UINavigationController class]])
        [((UINavigationController *)self.chipsContainerViewController) popViewControllerAnimated:YES];
}

- (void)organizationsViewController:(FSPOrganizationsViewController *)organizationsViewController didSelectNewOrganization:(FSPOrganization *)newOrganization;
{
    FSPEventsContainerViewController *newChipsContainerViewController = [[FSPEventsContainerViewController alloc] initWithOrganization:newOrganization];
    NSString *title = newOrganization.name;

    //reset the mass relevance view, since they will be different for each sport
    FSPEventsViewController *createdEventsViewController = (FSPEventsViewController *)newChipsContainerViewController.subViewController;
    [self setNewMassRelevance:[createdEventsViewController.selectedEvent getMassRelevanceClass]];
    
    if ([newOrganization isKindOfClass:[FSPTeam class]]) {
        title = ((FSPTeam *)newOrganization).shortNameDisplayString;
    }
    newChipsContainerViewController.title = title;
    
    [self presentNewChipsContainerViewController:newChipsContainerViewController];
	[self updateShowHideButtonTitle:newChipsContainerViewController.isDropDownMenuExtended];
}

- (void)organizationsViewControllerDidSelectSportsNews:(FSPOrganizationsViewController *)organizationsViewController;
{
    FSPSportsNewsContainerViewController *newsContainerViewController = [[FSPSportsNewsContainerViewController alloc] init];
    newsContainerViewController.title = @"SPORTS NEWS";
    
    [self presentNewChipsContainerViewController:newsContainerViewController];
}

- (void)organizationsViewControllerDidSelectAllMyEvents:(FSPOrganizationsViewController *)organizationsViewController
{
    FSPAllMyEventsContainerViewController *newEventsContainerViewController = [[FSPAllMyEventsContainerViewController alloc] init];
    newEventsContainerViewController.title = @"MY EVENTS";
    
    [self presentNewChipsContainerViewController:newEventsContainerViewController];
}


#pragma mark - AdView

- (void)setAdViewVisible:(BOOL)visible animated:(BOOL)animated;
{
    if (visible)
        [self showAdViewAnimated:animated];
    else
        [self hideAdViewAnimated:animated];
}

- (void)showAdViewAnimated:(BOOL)animated;
{
	// TODO: determine if we want to add these timers back in or remove them completely.
	
//	static NSDate *_lastAdShownDate = nil;
//
//	NSTimeInterval timeIntervalSinceLastAd = -[_lastAdShownDate timeIntervalSinceNow];
//	if (_lastAdShownDate && timeIntervalSinceLastAd < 60 * 2) {
//		return;
//	} else {
//		_lastAdShownDate = [NSDate date];
//	}
	
    if (adIsPresented) {
//        if (self.adDismissTimer) {
//            // Reset our timer to show the full time again.
//            [self.adDismissTimer invalidate];
//            self.adDismissTimer = nil;
//            self.adDismissTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(adDismissTimerFired:) userInfo:nil repeats:NO];
//        }
        return;
    }
        
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect frame = self.adView.frame;
        frame.origin.y = CGRectGetMaxY(self.view.bounds) - frame.size.height;
        self.adView.frame = frame;
        self.adView.alpha = 1.0;
    } completion:^(BOOL completed) {
        adIsPresented = YES;
//        self.adDismissTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(adDismissTimerFired:) userInfo:nil repeats:NO];
    }];
}
     
- (void)hideAdViewAnimated:(BOOL)animated;
{
    if (!adIsPresented)
        return;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.adView.frame = orginalAdFrame;
        self.adView.alpha = 0.0;
    } completion:^(BOOL completed) {
        adIsPresented = NO;
    }];
    [self.adDismissTimer invalidate];
    self.adDismissTimer = nil;
}

- (void)dismissAd:(id)sender
{
	[self hideAdViewAnimated:YES];
}

- (void)adDismissTimerFired:(NSTimer *)timer;
{
    self.adDismissTimer = nil;
    [self hideAdViewAnimated:YES];
}

#pragma mark - :: Full Screen Mode ::
- (BOOL)isInFullScreenMode;
{
    return fullScreenFlags.isFullScreen;
}

- (void)toggleFullScreenMode:(BOOL)animated;
{
    if (fullScreenFlags.isFullScreen) {
        [self exitFullScreenMode:animated];
    } else {
        [self enterFullScreenMode:animated];
    }
}
- (void)enterFullScreenMode:(BOOL)animated;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [NSException raise:@"Invalid Device" format:@"enterFullScreenMode: is only available on the iPad"];
    }

    if (fullScreenFlags.inTransition)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FSPRootViewControllerWillTransitionToFullScreenNotification object:self];
    [self performFullScreenTransition:YES animated:animated];   
}

- (void)exitFullScreenMode:(BOOL)animated;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [NSException raise:@"Invalid Device" format:@"exitFullScreenMode: is only available on the iPad"];
    }
    
    if (fullScreenFlags.inTransition)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FSPRootViewControllerWillTransitionFromFullScreenNotification object:self];
    [self performFullScreenTransition:NO animated:animated];   
}

- (void)setMasterViewsInFullScreenMode:(BOOL)inFullScreen animated:(BOOL)animated;
{
    NSTimeInterval duration = FSPTransitionToFromFullScreenModeDuration + FSPTransitionToFromFullScreenModeDelay;
    
    CGAffineTransform transform = inFullScreen ? CGAffineTransformMakeTranslation(-self.organizationsView.bounds.size.width - self.chipsContainerView.bounds.size.width, 0.0) : CGAffineTransformIdentity;
    CGAffineTransform headerTransform = inFullScreen ? CGAffineTransformMakeTranslation(-self.headerContainer.bounds.size.width, 0.0) : CGAffineTransformIdentity;
    [UIView animateWithDuration:animated ? duration : 0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionOverrideInheritedDuration animations:^{
        self.chipsContainerView.transform = transform;
        self.headerContainer.transform = headerTransform;
        self.organizationsView.transform = transform;
        self.customizeButton.transform = transform;
    } completion:nil];
}

- (void)performFullScreenTransition:(BOOL)toFullScreen animated:(BOOL)animated;
{
    NSTimeInterval duration = animated ? FSPTransitionToFromFullScreenModeDuration : 0.0;
    
    //TODO: Once we have a view installed to take up that 56 pixels use that instead for the calculation.
    CGAffineTransform transform = toFullScreen ? CGAffineTransformMakeTranslation(-self.organizationsView.bounds.size.width - self.chipsContainerView.bounds.size.width + 90, 0.0) : CGAffineTransformIdentity;
    
    fullScreenFlags.inTransition = 1;
        
    if (toFullScreen) {
        self.columnBRightShadow.alpha = !toFullScreen;
        self.columnBLeftShadow.alpha = !toFullScreen;
    }
    
    [self updateAllContainerViews];
    [UIView animateWithDuration:duration delay:FSPTransitionToFromFullScreenModeDelay options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        self.eventDetailView.transform = transform;
        // Bring along the rest of the views
        [self setMasterViewsInFullScreenMode:toFullScreen animated:animated];
    } completion:^(BOOL completed) {
        fullScreenFlags.inTransition = 0;
        fullScreenFlags.isFullScreen = !fullScreenFlags.isFullScreen;
        [self updateAllContainerViews];
        
        if (!toFullScreen) {
            self.columnBRightShadow.alpha = !toFullScreen;
            self.columnBLeftShadow.alpha = !toFullScreen;
        }
        
        NSString *noteToPost = toFullScreen ? FSPRootViewControllerDidTransitionToFullScreenNotification : FSPRootViewControllerDidTransitionFromFullScreenNotification;
        [[NSNotificationCenter defaultCenter] postNotificationName:noteToPost object:self];
    }];    
}

#pragma mark - :: Customization Mode ::
- (BOOL)isInCustomizationMode;
{
    return customizationFlags.inCustomizationMode;
}

- (IBAction)toggleCustomizationMode;
{
    if (customizationFlags.inCustomizationMode)
        [self exitCustomizationModeAnimated:YES];
    else 
        [self enterCustomizationModeAnimated:YES];
}

- (void)enterCustomizationModeAnimated:(BOOL)animated;
{
    if (customizationFlags.inCustomizationMode || customizationFlags.inTransition)
        return;
    
	if (self.presentedSlideInViewController) {
		[self slideOutViewControllerAnimated:animated completion:^(){
			[self enterCustomizationModeAnimated:animated];
		}];
		return;
	}
	
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    if (!self.customizationViewController) {
        self.customizationViewController = [[FSPCustomizationViewController alloc] init];
        self.customizationViewController.managedObjectContext = [[FSPCoreDataManager sharedManager] GUIObjectContext];
    }
    
    // Move everything over to the right
    [self performCustomizationModeTransition:YES animated:animated];
    } else {
        customizationFlags.inCustomizationMode = YES;
        customizationFlags.inTransition = NO;
    }
    
    // for iPhone we only need to switch the organizations view controller to editing mode.
    [self.organizationsViewController setInCustomizationMode:YES animated:animated];
}

- (void)exitCustomizationModeAnimated:(BOOL)animated;
{
    if (!customizationFlags.inCustomizationMode || customizationFlags.inTransition)
        return;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self performCustomizationModeTransition:NO animated:animated];
    } else {
        customizationFlags.inCustomizationMode = NO;
        customizationFlags.inTransition = NO;
    }  
    
    [self.organizationsViewController setInCustomizationMode:NO animated:animated];
}

- (void)performCustomizationModeTransition:(BOOL)toCustomization animated:(BOOL)animated;
{
    static CGFloat orgWidths[] = {90.0, 360.0};
    CGFloat orgWidth = toCustomization ? orgWidths[1] : orgWidths[0];
    
    // Update the org view width
    CGRect newOrgFrame = self.organizationsView.frame;
    newOrgFrame.size.width = orgWidth;
    
    NSTimeInterval duration = animated ? FSPCustomizationTranstionDuration : 0.0;
    
    CGAffineTransform headerTransform;
    CGAffineTransform logoTransform;
    CGAffineTransform flareTransform;
    CGAffineTransform rightSideViewsTransform;
    CGAffineTransform leftSideViewsTransform;
    CGAffineTransform buttonTransform;
	CGAffineTransform shadowTransform;
    
    UIImage *customizeImage;
    
    if (toCustomization) {
        headerTransform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - self.headerContainer.frame.size.width + FSPHeaderTransformOffset, 0.0);
        
        //This is to center the flare and logo
        logoTransform = CGAffineTransformMakeTranslation(FSPHeaderLogoTransformOffset, 0.0);
        flareTransform = CGAffineTransformMakeTranslation(FSPHeaderFlareTransformation, 0.0);
        leftSideViewsTransform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - self.chipsContainerView.frame.origin.x, 0.0);
        rightSideViewsTransform  = CGAffineTransformMakeTranslation(self.view.bounds.size.width - orgWidth, 0.0);
		shadowTransform = rightSideViewsTransform;
        
        CGFloat buttonTranslation = self.view.bounds.size.width - self.customizeButton.bounds.size.width - (2 * self.customizeButton.frame.origin.x);
        buttonTransform = CGAffineTransformMakeTranslation(buttonTranslation, 0.0);
        
        self.extraDetailContainerView.hidden = YES;
        
        customizeImage = [UIImage imageNamed:@"done_button"];
    } else {
        headerTransform = buttonTransform = rightSideViewsTransform = leftSideViewsTransform = logoTransform = flareTransform = shadowTransform = CGAffineTransformIdentity;
        customizeImage = [UIImage imageNamed:@"A_Settings"];
    }
    
    customizationFlags.inTransition = 1;
    
	if (toCustomization) {
		self.columnBRightShadow.alpha = !toCustomization;
		self.columnBLeftShadow.alpha = !toCustomization;
		self.columnALeftShadow.alpha = toCustomization;
	}
    
    [self updateAllContainerViews];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.organizationsView.frame = newOrgFrame;
        self.organizationsView.transform = rightSideViewsTransform;
        self.customizationContainer.transform = rightSideViewsTransform;

        self.headerContainer.transform = headerTransform;
        self.chipsContainerView.transform = leftSideViewsTransform;
        self.eventDetailView.transform = leftSideViewsTransform;
        self.customizeButton.transform = buttonTransform;
        
        self.headerTitleLabel.alpha = !toCustomization;
        self.showHideButton.alpha = !toCustomization;
        self.flareImageView.transform = flareTransform;
        self.logoImageView.transform = logoTransform;
		self.columnALeftShadow.transform = shadowTransform;
        
        [self.customizeButton setImage:customizeImage forState:UIControlStateNormal];
		
    } completion:^(BOOL completed) {
        customizationFlags.inCustomizationMode = !customizationFlags.inCustomizationMode;
        customizationFlags.inTransition = 0;
        [self updateAllContainerViews];
        
        if (!toCustomization) {
            self.extraDetailContainerView.hidden = NO;
            
            self.columnBRightShadow.alpha = toCustomization;
            self.columnBLeftShadow.alpha = toCustomization;
			self.columnALeftShadow.alpha = !toCustomization;
        }
        
        [self.organizationsViewController.tableView flashScrollIndicators];
    }];
}


#pragma mark - Settings

- (void)settingsButtonTapped:(UIButton *)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.isInCustomizationMode) {
		[self exitCustomizationModeAnimated:YES];
		return;
	}

	FSPSettingsViewController *vc = [[FSPSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	vc.owner = self;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (!self.popover) {
			
			self.popover = [[UIPopoverController alloc] initWithContentViewController:nav];
			self.popover.delegate = self;
			
			[self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		} else {
			[self.popover dismissPopoverAnimated:YES];
		}
	} else {
		[self presentModalViewController:nav animated:YES];
        vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsDoneButtonWasTapped:)];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
	self.popover = nil;
}

- (void)settingsDoneButtonWasTapped:(id)sender;
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.popover dismissPopoverAnimated:YES];
		self.popover = nil;
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark - Web View Modal Display

- (void)presentModalWebViewControllerWithRequest:(NSURLRequest *)request title:(NSString *)title;
{
    [self presentModalWebViewControllerWithRequest:request title:title modalStyle:UIModalPresentationFormSheet];
}

- (void)presentModalWebViewControllerWithRequest:(NSURLRequest *)request title:(NSString *)title modalStyle:(UIModalPresentationStyle)style;
{
    if (self.popover)
    [self settingsButtonTapped:nil]; // dismiss the settings UI if it was up
    self.popover = nil;

    WebViewController *modalWebViewController = [[WebViewController alloc] initWithNibName:nil bundle:nil];
    modalWebViewController.title = title;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        modalWebViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    modalWebViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalWebViewController)];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:modalWebViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = style;
    }

    [modalWebViewController.myWebView loadRequest:request];
    [self presentModalViewController:nav animated:YES];
}

- (void)dismissModalWebViewController;
{
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //
    }];
}

#pragma mark - Mail Message Handling

- (void)composeMailMessage;
{
    [self settingsButtonTapped:nil]; // dismiss the settings UI if it was up
    self.popover = nil;

    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@"Fox Sports Feedback"];
    [mailViewController setToRecipients:@[@"fs2go@foxsports.com"]];
    [mailViewController setMessageBody:@"\n\n\n\nThank You for your feedback!" isHTML:NO];
    [self presentModalViewController:mailViewController animated:YES];    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error; 
{
    
    [self dismissViewControllerAnimated:YES completion:^(void)
     {
        //
     }];
}


#pragma mark - Video Playback

- (void)playMovieForURL:(NSString *)videoURL
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerViewControllerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayerViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onMovieLoadStateChangedWithNewMoviePlayerController:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:self.moviePlayerViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onMoviePlaybackFinishedWithNewMoviePlayerController:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:self.moviePlayerViewController];

    if (!self.moviePlayerViewController) {
        self.moviePlayerViewController =  [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
    }
    else {
        [self.moviePlayerViewController.moviePlayer setContentURL:[NSURL URLWithString:videoURL]];
    }
    
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
    
}

#pragma mark - TVE Testing
- (void)loginToTve:(UIButton *)sender
{
    // Normally we'd expect things to be initialized before login.
    if ([FSPTveAuthManager sharedManager].isEntitlementLoaded) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:REQUESTOR_FAILURE_NOTIFICATION
                                                      object:nil];
        
        if ([FSPTveAuthManager sharedManager].isAuthenticated) {
            [[FSPTveAuthManager sharedManager] logout];
        }
        else {
            [[FSPTveAuthManager sharedManager] getAuthentication];
        }
    }
    else {
        // Try setting the requestor again
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestorInitializationFailed:)
                                                     name:REQUESTOR_FAILURE_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestorInitializationSucceeded:)
                                                     name:REQUESTOR_SUCCESS_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestorInitializationFailed:) 
                                                     name:CERTIFICATE_FAILURE_NOTIFICATION
                                                   object:nil];
		
        [[FSPTveAuthManager sharedManager] setRequestorName:REQUESTOR_NAME];
    }
}

- (void)requestorInitializationFailed:(NSNotification *)note
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TVE Initialization Failure"
                                                    message:@"There was an error initializing TVE. Please try again later."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTOR_FAILURE_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CERTIFICATE_FAILURE_NOTIFICATION
                                                  object:nil];
}

- (void)requestorInitializationSucceeded:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTOR_SUCCESS_NOTIFICATION
                                                  object:nil];
    // Conitinue with login since everything is good now
    [self loginToTve:nil];
}

#pragma mark - FSPTveAuthManagerDelegate
- (void)setAuthenticationStatus:(int)status errorCode:(NSString *)errorCode
{
    if (status == ACCESS_ENABLER_STATUS_SUCCESS) {
        [[FSPTveAuthManager sharedManager] getSelectedProvider];
    }
    else {
        if ([FSPTveAuthManager sharedManager].didAuthenticateWithProvider == YES) {
            // Web login succeeded, but something else went wrong
            // If the provider is authenticated, but adobe is not, show an alert.
			
            [FSPTveAuthManager sharedManager].didAuthenticateWithProvider = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failure"
                                                                message:errorCode
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
    }
    
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)selectedProvider:(MVPD *)mvpd
{
	
}

- (void)displayProviderDialog:(NSArray *)theProviders
{
    FSPTveLoginViewController *tveLoginViewController = [[FSPTveLoginViewController alloc] initWithNibName:nil bundle:nil];
    tveLoginViewController.providers = theProviders;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tveLoginViewController];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];    
}

- (void)didLogout
{
	
}

#pragma mark - MPMoviePlayerController notifications
- (void)moviePlayerViewControllerPlaybackStateDidChange:(NSNotification *)playBackStateDidChangeNotification 
{
#ifdef FSP_LOG_VIDEO
    NSInteger theLoadstate = [self.moviePlayerViewController.moviePlayer loadState];
    NSString *loadStateString = nil;
    if (theLoadstate == 0) {
        loadStateString = @"MPMovieLoadStateUnknown";
    }
    else if (theLoadstate == MPMovieLoadStatePlayable) {
        loadStateString = @"MPMovieLoadStatePlayable";
    }
    else if (theLoadstate == MPMovieLoadStatePlaythroughOK) {
        loadStateString = @"MPMovieLoadStatePlaythroughOK";
    }
    else if (theLoadstate == MPMovieLoadStateStalled) {
        loadStateString = @"MPMovieLoadStateStalled";
    }
    
    NSString *playbackState = nil;
    switch ([[playBackStateDidChangeNotification object] playbackState]) {
        case 0:
            playbackState = @"MPMoviePlaybackStateStopped";
            break;
        case 1:
            playbackState = @"MPMoviePlaybackStatePlaying";
            break;
        case 2:
            playbackState = @"MPMoviePlaybackStatePaused";
            break;
        case 3:
            playbackState = @"MPMoviePlaybackStateInterrupted";
            break;
        case 4:
            playbackState = @"MPMoviePlaybackStateSeekingForward";
            break;
        case 5:
            playbackState = @"MPMoviePlaybackStateSeekingBackward";
            break;
        default:
            break;
    }

    FSPLogVideo(@"playback state did change to %@", playbackState);
    FSPLogVideo(@"current load state is %@", loadStateString);
#endif
    
    // If the loadstate never became playable, and the video is complete, it likely means there was a problem loading the movie.
    // Regardless, clean up the observer and nil the context, otherwise observers will leak.
    if ([[playBackStateDidChangeNotification object] playbackState] == MPMoviePlaybackStateStopped && [[playBackStateDidChangeNotification object] loadState] == MPMovieLoadStateUnknown) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayerViewController];
    }
}

- (void)onMovieLoadStateChangedWithNewMoviePlayerController:(NSNotification *)notification {
    
#ifdef FSP_LOG_VIDEO
    NSInteger theLoadstate = [self.moviePlayerViewController.moviePlayer loadState];
    NSString *loadStateString = nil;
    if (theLoadstate == 0) {
        loadStateString = @"MPMovieLoadStateUnknown";
    }
    else if (theLoadstate == 1 << 0) {
        loadStateString = @"MPMovieLoadStatePlayable";
    }
    else if (theLoadstate == 1 << 1) {
        loadStateString = @"MPMovieLoadStatePlaythroughOK";
    }
    else if (theLoadstate == 1 << 2) {
        loadStateString = @"MPMovieLoadStateStalled";
    }
	FSPLogVideo(@"moviePlayerViewControllerLoadStateDidChange to %@", loadStateString);	
#endif
    
	if ([self.moviePlayerViewController.moviePlayer loadState] & MPMovieLoadStatePlayable) {
		// this notification might be triggered several times. only need to handle the first playable notifcation
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayerViewController];
	}
}

- (void)onMoviePlaybackFinishedWithNewMoviePlayerController:(NSNotification *)notification {
	FSPLogVideo(@"%@", notification);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:self.moviePlayerViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:self.moviePlayerViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:self.moviePlayerViewController];
    
#ifdef FSP_LOG_VIDEO
    MPMovieFinishReason finishReason = [[[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    NSString *reason = nil;
    
    switch (finishReason) {
        case 0:
            reason = @"MPMovieFinishReasonPlaybackEnded";
            break;
        case 1:
            reason = @"MPMovieFinishReasonPlaybackError";
            break;
        case 2:
            reason = @"MPMovieFinishReasonUserExited";
            break;
        default:
            break;
    }
    FSPLogVideo(@"Finish reason: %@", reason);
#endif
    
    self.moviePlayerViewController = nil;
}



@end

@implementation UIViewController (FSPRootViewController)

- (FSPRootViewController *)fsp_rootViewController;
{
    UIViewController *parent = self.parentViewController;
    FSPRootViewController *root = nil;
    Class rootClass = [FSPRootViewController class];
    BOOL keepChecking = parent != nil;
    do {
        if ([parent isKindOfClass:rootClass])
            root = (FSPRootViewController *)parent;
        else
            parent = parent.parentViewController;
        if (parent == nil || root != nil)
            keepChecking = NO;
    } while (keepChecking);
    return root;
}

@end
