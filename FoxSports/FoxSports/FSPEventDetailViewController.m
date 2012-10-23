//
//  EventDetailViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventDetailViewController.h"
#import "FSPEvent.h"
#import "FSPDataCoordinator.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPGameHeaderView.h"
#import "FSPSegmentedNavigationControl.h"
#import "FSPStoryViewController.h"
#import "FSPGamePreGameViewController.h"
#import "FSPEventVideosViewController.h"
#import "FSPAlertsViewController.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "FSPSecondarySegmentedControl.h"
#import "FSPUFCPreEventViewController.h"
#import "FSPUFCEvent.h"

#import "NSDate+FSPExtensions.h"

// TVE Testing
#import "FSPTveLoginViewController.h"

NSString * const FSPExtendedInformationViewControllersKey = @"viewControllers";
NSString * const FSPExtendedInformationTitlesKey = @"titles";

@interface FSPEventDetailViewController ()

// Container Support
@property (weak, nonatomic) IBOutlet UIView *lowerContainerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet FSPSegmentedNavigationControl *navigationView;
@property (weak, nonatomic) FSPGameHeaderView *gameHeaderView;
@property (strong, nonatomic) FSPEventVideosViewController *videosViewController;
@property (nonatomic, weak) FSPAlertsViewController *alertsViewController;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

+ (NSMutableDictionary *)savedTabs;

// MOC Observing methods
- (void)startObservingMOC;
- (void)stopObservingMOC;
- (void)managedObjectContextDidChange:(NSNotification *)note;

// Segmented control support

/**
 * The display string for the segmented control segment whose contents depend on game state: "Preview" is displayed when the game has not
 * completed, and "Recap" is displayed when the game is over.
 */
@property (nonatomic, readonly) NSString *previewRecapSegmentTitle;

- (void)layoutForNavigationChange;

@end

@implementation FSPEventDetailViewController {
    BOOL isObservingMOC;
    NSUInteger currentExtendedInformationIndex;
}

@synthesize event = _event;
@synthesize lowerContainerView = _lowerContainerView;
@synthesize headerView = _headerView;
@synthesize gameHeaderView = _gameHeaderView;
@synthesize navigationView = _navigationView;
@synthesize pregameViewController = _pregameViewController;
@synthesize storyViewController = _storyViewController;
@synthesize extendedInformationDictionary = _extendedInformationDictionary;
@synthesize popover;
@synthesize segmentIndex;
@synthesize videosViewController = _videosViewController;
@synthesize alertsViewController;

- (void)setEvent:(FSPEvent *)event;
{
    if (_event != event) {
        [self stopObservingMOC];
        _event = event;
        [self eventDidChange];
        [self startObservingMOC];
        [self.dataCoordinator beginUpdatingEvent:event.objectID];
    }
}

#pragma mark - Memory Management

- (id)init
{
    self = [super initWithNibName:@"FSPEventDetailViewController" bundle:nil];
    if (self) {
        currentExtendedInformationIndex = NSNotFound;
        _dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    }
    return self;
}


- (void)dealloc;
{
    [self stopObservingMOC];
}

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startObservingMOC];

    self.headerView.backgroundColor = [UIColor clearColor];

    //Game Header View
    self.gameHeaderView = [[FSPGameHeaderView alloc] init];
    [self.headerView addSubview:self.gameHeaderView];
    [self.gameHeaderView.shareButton addTarget:self action:@selector(displayShareOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.gameHeaderView.toggleFullScreenButton addTarget:self action:@selector(toggleFullScreenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.gameHeaderView.alertButton addTarget:self action:@selector(showAlertPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    //TVE Testing
    [FSPTveAuthManager sharedManager].delegate = self;
    
    self.gameHeaderView.tveLoginButton.hidden = YES;
    self.gameHeaderView.deleteKeychainItemsButton.hidden = YES;
#if TVE_DEBUG
    [[FSPTveAuthManager sharedManager] checkAuthentication];
    [self.gameHeaderView.tveLoginButton addTarget:self 
                                           action:@selector(loginToTve:)
                                 forControlEvents:UIControlEventTouchUpInside];
    
	[self.gameHeaderView.deleteKeychainItemsButton addTarget:self
                                   action:@selector(deleteKeychainItems:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    self.gameHeaderView.tveLoginButton.hidden = NO;
    self.gameHeaderView.deleteKeychainItemsButton.hidden = NO;
#endif
    
    //Game Segmented Control
    [self.extendedInformationTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        [self.navigationView insertSegmentWithTitle:title atIndex:index animated:NO];
    }];
    [self.navigationView addTarget:self action:@selector(changeExtendedInformation:) forControlEvents:UIControlEventValueChanged];

    NSInteger eventIndex = self.segmentIndex.integerValue;
    if (eventIndex >= 0)
        [self selectExtendedViewAtIndex:eventIndex];
    else
        [self selectExtendedViewAtIndex:0];
}

- (void)deleteKeychainItems:(id)sender
{
    [[FSPTveAuthManager sharedManager] deletePrivateKey];
}

- (void)viewDidUnload;
{
    [self setLowerContainerView:nil];
    [self setHeaderView:nil];
    [self stopObservingMOC];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Segmented Controller support

+ (NSMutableDictionary *)savedTabs
{
	static NSMutableDictionary *savedTabs = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        savedTabs = [NSMutableDictionary dictionary];
		NSString *savedTab = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedExtendedView"];
		NSArray *components = [savedTab componentsSeparatedByString:@"::"];
		if (components.count == 2) {
			NSNumber *index = @([[components objectAtIndex:0] intValue]);
			NSString *eventIdentifier = [components objectAtIndex:1];
			[savedTabs setValue:index forKey:eventIdentifier];
		}

    });
	return savedTabs;
}


- (void)selectExtendedViewAtIndex:(NSUInteger)index;
{
	[[FSPEventDetailViewController savedTabs] setValue:@(index) forKey:self.event.uniqueIdentifier];
	[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d::%@", index, self.event.uniqueIdentifier] forKey:@"selectedExtendedView"];
    
	NSUInteger oldIndex = currentExtendedInformationIndex;
	
    if ((index < [self.extendedInformationViewControllers count])) {
        if ([self isViewLoaded]) currentExtendedInformationIndex = index;
        
        for (UIViewController *vc in self.extendedInformationViewControllers) {
            if (vc.isViewLoaded && vc.view.superview) {
                [vc willMoveToParentViewController:nil];
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
        
        // add the new view controller
        UIViewController <FSPExtendedEventDetailManaging> *newViewController = [self.extendedInformationViewControllers objectAtIndex:index];
		if (![newViewController conformsToProtocol:@protocol(FSPExtendedEventDetailManaging)]) {
			[NSException raise:@"Does not conform to protocol" format:@"%@ must conform to the FSPExtendedEventDetailManaging protocol", newViewController];
		}
        newViewController.managedObjectContext = self.event.managedObjectContext;

		if (self.lowerContainerView) {
//			self.lowerContainerView.layer.borderWidth = 1.0;
//			self.lowerContainerView.layer.borderColor = [UIColor redColor].CGColor;
			newViewController.view.frame = self.lowerContainerView.bounds;
		}
        if ([newViewController respondsToSelector:@selector(segmentedControl)]) {
			FSPSegmentedControl *segmentedControl = [newViewController segmentedControl];
			if ([segmentedControl isKindOfClass:[FSPSecondarySegmentedControl class]] && [newViewController respondsToSelector:@selector(segmentTitlesForEvent:)]) {
				[segmentedControl removeAllSegments];
				NSArray *segments = [newViewController segmentTitlesForEvent:self.event];
				for (NSUInteger i = 0; i < [segments count]; i++) {
					[segmentedControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i animated:NO];
				}
				segmentedControl.selectedSegmentIndex = 0;
			} else {
				segmentedControl.selectedSegmentIndex = -1;
			}
		}
		
        [self addChildViewController:newViewController];
        [newViewController didMoveToParentViewController:self];
        [self.lowerContainerView addSubview:newViewController.view];
        newViewController.currentEvent = self.event;
		[newViewController.view setNeedsLayout];
		
        // Update the event and moc for the view controllers
        if (![newViewController conformsToProtocol:@protocol(FSPExtendedEventDetailManaging)]) {
            [NSException raise:@"Does not conform to protocol" format:@"%@ must conform to the FSPEventDetailLoading protocol", newViewController];
        }
        
        // update the index in our db
        self.segmentIndex = @(index);
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			if ([newViewController respondsToSelector:@selector(selectGameDetailViewAtIndex:)]) {
				[newViewController selectGameDetailViewAtIndex:self.navigationView.selectedSubsegmentIndex];
			}
		}
		
        [self.navigationView setSelectedSegmentIndex:index];
		if (index != oldIndex) [self.navigationView setSelectedSubsegmentIndex:0];

    	// adjust the view for change in sub-sections on iPhone
		[self layoutForNavigationChange];
	}
}

- (void)layoutForNavigationChange
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self.navigationView sizeToFit];
		
		CGRect headerRect, navigationRect, contentRect;
		CGRectDivide(self.view.bounds, &headerRect, &contentRect, self.headerView.bounds.size.height, CGRectMinYEdge);
		CGRectDivide(contentRect, &navigationRect, &contentRect, self.navigationView.bounds.size.height, CGRectMinYEdge);
		
		self.headerView.frame = headerRect;
		self.navigationView.frame = navigationRect;
		self.lowerContainerView.frame = contentRect;
	}
}

- (void)changeExtendedInformation:(FSPSegmentedNavigationControl *)sender;
{
    [self selectExtendedViewAtIndex:sender.selectedSegmentIndex];
}


- (BOOL)recapIsPreview;
{
    return NO;
}

- (NSDictionary *)updatedExtendedInformationDictionary;
{
    NSArray *viewControllers;
    NSArray *titles;
    
    if (!_videosViewController) {
        self.videosViewController = [[FSPEventVideosViewController alloc] init];
    }
    
	// create the view controllers dictionary
	UIViewController *previewRecapViewController;
	
	if (self.event.eventCompleted.boolValue == YES && ![self recapIsPreview]) {
		previewRecapViewController = self.storyViewController;
	}
	else {
		previewRecapViewController = (id)self.pregameViewController;
	}

	viewControllers = @[previewRecapViewController, _videosViewController];
	titles = @[self.previewRecapSegmentTitle, @"Videos"];

    return @{FSPExtendedInformationViewControllersKey: viewControllers,
            FSPExtendedInformationTitlesKey: titles};
}

- (UIViewController *)pregameViewController
{
    if (!_pregameViewController)
        _pregameViewController = [[[self preEventViewControllerClass] alloc] init];
    return _pregameViewController;
}

- (Class)preEventViewControllerClass
{
    // Changing this behavior because if the branch is nil (bad data), then this will crash
    // due to the way we figure out the preEvent class (see [FSPRootViewController detailViewControllerClassForEvent:]
    // NSAssert(false, @"[FSPEventDetailViewController preEventViewControllerClass] must be overrriden by subclass");
    return [FSPGamePreGameViewController class];
}

- (FSPStoryViewController *)storyViewController
{
    if (!_storyViewController) {
        _storyViewController = [[FSPStoryViewController alloc] initWithStoryType:FSPStoryTypeRecap];
	}
    return _storyViewController;
}


- (NSArray *)extendedInformationViewControllers;
{
    return [self.extendedInformationDictionary objectForKey:FSPExtendedInformationViewControllersKey];
}

- (NSArray *)extendedInformationTitles;
{
    return [self.extendedInformationDictionary objectForKey:FSPExtendedInformationTitlesKey];
}

- (void)setExtendedInformationDictionary:(NSDictionary *)extendedInformationDictionary
{
    if (_extendedInformationDictionary != extendedInformationDictionary) {
        _extendedInformationDictionary = extendedInformationDictionary;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.extendedInformationTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
                [self.navigationView setSegmentTitle:title atIndex:idx];
            }];
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				[self.extendedInformationViewControllers enumerateObjectsUsingBlock:^(id <FSPExtendedEventDetailManaging> viewController, NSUInteger idx, BOOL *stop) {
					if ([viewController respondsToSelector:@selector(segmentTitlesForEvent:)]) {
						[self.navigationView setSubsegmentTitles:[viewController segmentTitlesForEvent:self.event] forSection:idx];
					}
				}];
				[self layoutForNavigationChange];
			}
        });
    }
}

- (NSString *)previewRecapSegmentTitle;
{
    if ([self.event.eventCompleted boolValue] == YES)
        return @"Recap";
    else
        return @"Preview";
}

#pragma mark - Observations
- (void)startObservingMOC;
{
    if (isObservingMOC)
        return;
    
    if (self.event) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.event.managedObjectContext];
        isObservingMOC = YES;
    }
}

- (void)stopObservingMOC;
{
    if (!isObservingMOC)
        return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.event.managedObjectContext];
    isObservingMOC = NO;
}

- (void)managedObjectContextDidChange:(NSNotification *)note;
{
    NSDictionary *userInfo = [note userInfo];
    NSMutableSet *updatedObjects = [[NSMutableSet alloc] init];
    [updatedObjects unionSet:[userInfo objectForKey:NSInsertedObjectsKey]];
    [updatedObjects unionSet:[userInfo objectForKey:NSUpdatedObjectsKey]];
    [updatedObjects unionSet:[userInfo objectForKey:NSRefreshedObjectsKey]];
    if ([updatedObjects containsObject:self.event]) {
        [self eventDidUpdate];
    }
}

- (void)eventDidChange;
{
	NSUInteger index = [[[FSPEventDetailViewController savedTabs] valueForKey:self.event.uniqueIdentifier] unsignedIntValue];
    self.segmentIndex = @(index);
    self.extendedInformationDictionary = [self updatedExtendedInformationDictionary];
    
    [self.navigationView removeAllSegments];
    
    [self.extendedInformationTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        [self.navigationView insertSegmentWithTitle:title atIndex:index animated:NO];
    }];
    
	currentExtendedInformationIndex = -1;
	[self selectExtendedViewAtIndex:index];
	
	self.gameHeaderView.dateTimeChannelLabel.text = [NSString stringWithFormat:@"%@ %@", [self.event.startDate fsp_lowercaseMeridianDateString], self.event.channelDisplayName];

}

- (void)eventDidUpdate;
{
    self.extendedInformationDictionary = [self updatedExtendedInformationDictionary];
    
    NSNumber *alertsMask = [[self.event getPrimaryOrganization] alertMask];
    self.gameHeaderView.alertButton.hidden = [self.event.eventCompleted boolValue] && alertsMask;
}


#pragma mark - Alerts / Actions

- (void)showAlertError:(NSError *)error
{
	NSLog(@"there was an error subscribing to the alert. %@", error);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error subscribing to the alert." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)subscribeToAlert:(NSDictionary *)alertPrefs
{
	[[self.dataCoordinator profileClient] subscribeToAlertForEvent:self.event.objectID
                                                       preferences:alertPrefs
                                                           success:^{
                                                               NSLog(@"we successfully subscribed to the alert.");
                                                           }
                                                           failure:^(NSError *error){
                                                               [self showAlertError:error];
                                                           }];
}

- (void)trySubscribeToAlert:(NSDictionary *)alertPrefs
{
	// FOR TESTING: REMOVE THESE TWO LINES
    //	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:100000000000000303] forKey:@"profileId"];
    //	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([[NSUserDefaults standardUserDefaults] valueForKey:@"profileId"]) {
		// subscribe to alert
		[self subscribeToAlert:alertPrefs];
	} else {
		[[self.dataCoordinator profileClient] createProfile:^(NSDictionary *response){
			dispatch_async(dispatch_get_main_queue(), ^{
				// subscribe to alert
				[self subscribeToAlert:alertPrefs];
			});
		} failure:^(NSError *error){
			[self showAlertError:error];
		}];
	}
}


- (void)showAlertView:(UIButton *)sender
{
	[self trySubscribeToAlert:nil];
}

- (void)showAlertPopover:(UIButton *)sender
{
	FSPAlertsViewController *vc = [[FSPAlertsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	self.alertsViewController = vc;
	[self.alertsViewController populateWithEvent:self.event];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (!self.popover) {
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
			self.popover = [[UIPopoverController alloc] initWithContentViewController:nav];
			self.popover.delegate = self;
			
			[self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			
		} else {
			[self.popover dismissPopoverAnimated:YES];
		}
	} else {
		FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
		if (vc) [appDelegate.rootViewController displayModalViewController:vc animated:YES];
	}
	
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
    //	NSDictionary *prefs = [NSDictionary dictionaryWithObjectsAndKeys:
    //					   [NSNumber numberWithBool:YES], @"startAlert",
    //					   [NSNumber numberWithBool:YES], @"finishAlert",
    //					   [NSNumber numberWithBool:YES], @"phaseBasedAlert",
    //					   [NSNumber numberWithBool:YES], @"scoreBasedAlert",
    //					   [NSNumber numberWithBool:YES], @"updateAlert",
    //					   [NSNumber numberWithBool:YES], @"excitingGameAlert",
    //					   nil];
	NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
	NSNumber *yes = @(YES);
	
	if (self.alertsViewController.gameStartAlerts) [prefs setValue:yes forKey:@"startAlert"];
	if (self.alertsViewController.eachScoringPlayAlerts) [prefs setValue:yes forKey:@"scoreBasedAlert"];
	if (self.alertsViewController.eachQuarterAlerts) [prefs setValue:yes forKey:@"phaseBasedAlert"];
	if (self.alertsViewController.finalAlerts) [prefs setValue:yes forKey:@"finishAlert"];
    
	self.popover = nil;
	
	[self trySubscribeToAlert:prefs];
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
    if (mvpd.displayName) {
        [self.gameHeaderView.tveLoginButton setTitle:mvpd.displayName forState:UIControlStateNormal];
    }
    else {
        [self.gameHeaderView.tveLoginButton setTitle:@"Tve Logout" forState:UIControlStateNormal];
    }
}

- (void)displayProviderDialog:(NSArray *)theProviders
{
    FSPTveLoginViewController *tveLoginViewController = [[FSPTveLoginViewController alloc] initWithNibName:nil bundle:nil];
    tveLoginViewController.providers = theProviders;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tveLoginViewController];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];    
}

- (void) didLogout
{
    [self.gameHeaderView.tveLoginButton setTitle:@"Tve Login" forState:UIControlStateNormal];
}
@end



//#import "FSPVideoPlayerViewController.h"
//#import "FSPVideoPlayerView.h"
//@property(nonatomic, strong) FSPVideoPlayerViewController *videoPlayerController;
//@synthesize videoPlayerController;

//#pragma mark - FSPEventDetailLoading
//- (void)setCurrentEvent:(FSPEvent *)currentEvent;
//{
//    if (_currentEvent != currentEvent) {
//        _currentEvent = currentEvent;
//        
//        //TODO: testing video player.. 
//        if (self.videoPlayerController) {
//            [self.videoPlayerController.view removeFromSuperview];
//            self.videoPlayerController = nil;
//        }
//        
//        self.videoPlayerController = [[FSPVideoPlayerViewController alloc] initWithURL:@"http://devimages.apple.com/samplecode/adDemo/ad.m3u8"];
//        [self.view addSubview:videoPlayerController.view];
//        self.videoPlayerController.view.frame = CGRectMake((self.view.frame.size.width/2) - 200, 0, 400, 200);
//        
//    }
//}
