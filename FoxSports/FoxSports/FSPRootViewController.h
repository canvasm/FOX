//
//  RootViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventsViewController.h"
#import "FSPChipsContainerViewController.h"
#import "FSPOrganizationsViewController.h"
#import "FSPTveAuthManager.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "FSPMassRelevanceViewController.h"

@class FSPCustomizationViewController;

extern NSString * const FSPRootViewControllerWillTransitionToFullScreenNotification;
extern NSString * const FSPRootViewControllerDidTransitionToFullScreenNotification;
extern NSString * const FSPRootViewControllerWillTransitionFromFullScreenNotification;
extern NSString * const FSPRootViewControllerDidTransitionFromFullScreenNotification;

@interface FSPRootViewController : UIViewController <FSPChipsContainerViewControllerDelegate, FSPDropDownContainerViewControllerDelegate, FSPEventsViewControllerDelegate, FSPOrganizationsViewControllerDelegate, UIPopoverControllerDelegate, FSPTveAuthManagerDelegate, MFMailComposeViewControllerDelegate>

/**
 * The view controller containing a list of events, which can be selected to
 * change the contenst of the detail view controller.
 */
@property (nonatomic, strong) FSPChipsContainerViewController *chipsContainerViewController; // NOTE: On the iPhone, this is a UINavigationController
@property (nonatomic, strong) FSPOrganizationsViewController *organizationsViewController;
@property (nonatomic, strong, readonly) UIViewController *detailViewController;
@property (nonatomic, strong) UIViewController *extraDetailViewController;
@property (nonatomic, strong) FSPCustomizationViewController *customizationViewController;

+ (FSPRootViewController *)rootViewController;
+ (UIView *)rootDNAView;
+ (FSPMassRelevanceViewController *)massRelevanceView;
- (void)setNewMassRelevance:(Class)newClass;

- (void)performInitialLaunchUpdating;

/**
 On iPhone this moves the event view controller to the right of the screen.  On iPad this does nothing.
 */
- (void)setChipsContainerViewControllerHidden:(BOOL)hidden animated:(BOOL)animated;

// Full Screen mode is only available on iPad
- (void)toggleFullScreenMode:(BOOL)animated;
- (void)enterFullScreenMode:(BOOL)animated;
- (void)exitFullScreenMode:(BOOL)animated;
@property (nonatomic, readonly) BOOL isInFullScreenMode;

// Customization - only available on the iPad
- (void)enterCustomizationModeAnimated:(BOOL)animated;
- (void)exitCustomizationModeAnimated:(BOOL)animated;
@property (nonatomic, readonly) BOOL isInCustomizationMode;

// settings
- (void)settingsDoneButtonWasTapped:(id)sender;

// drop down menu
- (void)dropDownContainerViewController:(FSPDropDownContainerViewController *)viewController didChangeDropDownMenuState:(BOOL)showMenu;

// events popover
- (void)dismissPopover;

// modal webviews
- (void)presentModalWebViewControllerWithRequest:(NSURLRequest *)request title:(NSString *)title;
- (void)presentModalWebViewControllerWithRequest:(NSURLRequest *)request title:(NSString *)title modalStyle:(UIModalPresentationStyle)style;
- (void)dismissModalWebViewController;

// mail
- (void)composeMailMessage;

// display/dismiss scores, schedules
- (void)slideInViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)slideOutViewControllerAnimated:(BOOL)animated;
@property (nonatomic, strong, readonly) UIViewController *presentedSlideInViewController;

- (void)displayModalViewController:(UIViewController *)placeholder animated:(BOOL)animated;
- (void)closeModalViewController;

// Play movies
- (void)playMovieForURL:(NSString *)videoURL;

@end



@interface UIViewController (FSPRootViewController)

/**
 Returns the FSPRootViewController if the view controller has one in its ancestry.  If not returns nil.
 */
@property (nonatomic, strong, readonly) FSPRootViewController *fsp_rootViewController;

@end
