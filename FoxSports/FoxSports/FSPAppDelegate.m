//
//  FSPAppDelegate.m
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import "FSPAppDelegate.h"
#import "FSPCoreDataManager.h"
#import "FSPRootViewController.h"

#import "FSPEventDetailViewController.h"
#import "FSPEventsViewController.h"
#import "FSPOrganizationsViewController.h"

#import "FSPDataCoordinator.h"

#import "FSPPGAEvent.h"
#import "UAirship.h"

#import "UIColor+FSPExtensions.h"
#import "FSPSettingsBundleHelper.h"

#if FSP_USE_DC_INTROSPECT
#import "DCIntrospect.h"
#endif // FSP_USE_DC_INROSPECT

@interface FSPAppDelegate ()

/**
 * Sets appearance proxy for common app elements.
 */
- (void)customizeAppearance;
- (void)fetchAlerts;

@end

NSString* FSPAppDidResetEnvironmentConfigurationNotification = @"FSPAppDidResetEnvironmentConfiguration";

@implementation FSPAppDelegate

@synthesize window = _window, rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
#if (defined(FSP_ENABLE_ALERTS) && !TARGET_IPHONE_SIMULATOR)
	//Init Airship launch options
	NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
	[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
	
	// Create Airship singleton that's used to talk to Urban Airship servers.
	// Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
	[UAirship takeOff:takeOffOptions];
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |  UIRemoteNotificationTypeAlert)];
#endif

    [self setupPreferences];
    [self customizeAppearance];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:FSPAppDidResetEnvironmentConfigurationNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setupRootViewController];
                                                  }];
    [self setupRootViewController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[FSPCoreDataManager sharedManager] synchronizeSavingAndWait];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
#if FSP_USE_DC_INTROSPECT
    [[DCIntrospect sharedIntrospector] start];
#endif //FSP_USE_DC_INTROSPECT

    [[NSUserDefaults standardUserDefaults] synchronize];

    [(FSPRootViewController *)self.rootViewController performInitialLaunchUpdating];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[FSPCoreDataManager sharedManager] synchronizeSavingAndWait];

#if (defined(FSP_ENABLE_ALERTS) && !TARGET_IPHONE_SIMULATOR)
	[UAirship land];
#endif
}

- (void)setupRootViewController {
    self.rootViewController = [[FSPRootViewController alloc] init];
    
    FSPOrganizationsViewController *organizationsViewController = [[FSPOrganizationsViewController alloc] init];
    organizationsViewController.managedObjectContext = [[FSPCoreDataManager sharedManager] GUIObjectContext];
    organizationsViewController.delegate = self.rootViewController;
    
    self.rootViewController.organizationsViewController = organizationsViewController;

	// fetch existing alerts & update the UI
	if ([[NSUserDefaults standardUserDefaults] valueForKey:@"profileId"]) {
		[self fetchAlerts];
	} else {
		[[[FSPDataCoordinator defaultCoordinator] profileClient] createProfile:^(NSDictionary *response){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self fetchAlerts];
			});
		} failure:^(NSError *error){
#ifndef DEBUG
			NSLog(@"there was an error creating the alert. %@", error);
#endif
		}];
	}
	
    if (self.window) {
        self.window.hidden = YES;
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
}

- (void)setupPreferences {
    [FSPSettingsBundleHelper initialize];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{FSPSettingsBundleAppEnvironmentKey : FSPSettingsBundleAppEnvironmentStaging}];
}

- (void)customizeAppearance;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];
        UIColor *tintColor = [UIColor fsp_colorWithIntegralRed:0 green:92 blue:170 alpha:1.0];
        // This only affects the back button tint color.  Other buttons have images.
        [[UIBarButtonItem appearance] setTintColor:tintColor];
    }
}


- (void)fetchAlerts
{
	[[[FSPDataCoordinator defaultCoordinator] profileClient] fetchAlertsWithSuccess:^(NSArray *alerts) {
		FSPLogDataCoordination(@"successfully fetched alerts.");
	} failure:^(NSError *error) {
		NSLog(@"failed to fetch alerts. %@", error);
	}];
	
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// Updates the device token and registers the token with UA
	NSLog(@"got device token:%@", deviceToken);
#if (defined(FSP_ENABLE_ALERTS) && !TARGET_IPHONE_SIMULATOR)
	[[UAirship shared] registerDeviceToken:deviceToken];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"failed to register for notifications:%@", error);
}


@end
