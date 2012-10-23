//
//  EventDetailViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPStoryViewController.h"

// TVE Testing
#import "FSPTveAuthManager.h"

/**
 * This is the "column c" view controller, displaying details about an individual event.
 */

@class FSPEvent;
@class FSPSegmentedNavigationControl;
@class FSPGameHeaderView;
@class FSPStoryViewController;
@class FSPGamePreGameViewController;

extern NSString * const FSPExtendedInformationViewControllersKey;
extern NSString * const FSPExtendedInformationTitlesKey;

@interface FSPEventDetailViewController : UIViewController <FSPTveAuthManagerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic, readonly) UIView *lowerContainerView;
@property (weak, nonatomic, readonly) UIView *headerView;
@property (weak, nonatomic, readonly) FSPSegmentedNavigationControl *navigationView;
@property (weak, nonatomic, readonly) FSPGameHeaderView *gameHeaderView;


// Segmented controller support
@property (nonatomic, strong, readonly) NSArray *extendedInformationViewControllers;
@property (nonatomic, strong, readonly) NSArray *extendedInformationTitles;

@property (nonatomic, strong) FSPGamePreGameViewController *pregameViewController;
@property (nonatomic, strong) FSPStoryViewController *storyViewController;

/**
 * Maps segmented control titles to associated view controllers. 
 */
@property (nonatomic, strong) NSDictionary *extendedInformationDictionary;

/**
 * Returns an updated dictionary with view controllers for extended information to reflect
 * game state (completed or not completed).
 * 
 * Subclasses should extend this to include any titles/view controllers in addition to Preview/Recap
 * and Test Preview/Test Recap.
 *
 * TODO: Replace Test titles with other common title when available.
 */
- (NSMutableDictionary *)updatedExtendedInformationDictionary;

/**
 The current event that the detail view controller is showing.
 This class will set up all of the observations on the event
 when it is set.
 */
@property (nonatomic, strong) FSPEvent *event;


@property (nonatomic, retain) UIPopoverController *popover;

/**
 The selected state of the segmented control
 */
@property (nonatomic, strong) NSNumber *segmentIndex;

/**
 Called when the event changes.  This is a good time to propagate
 the event object down to subviews that may need it.
 
 Subclasses MUST call super.
 */
- (void)eventDidChange;

/**
 Called when the event updates.  This is when the view should update
 itself to reflect the changes in the UI.
 
 Subclasses MUST call super.
 */
- (void)eventDidUpdate;


- (void)selectExtendedViewAtIndex:(NSUInteger)index;
- (void)changeExtendedInformation:(id)sender;

// PreEvent view controller class, specified in subclasses
- (Class)preEventViewControllerClass;

@end
