//
//  FSPLeaderboardContainerViewController.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@class FSPEvent;
@class FSPSecondarySegmentedControl;

@interface FSPLeaderboardContainerViewController : UIViewController <FSPExtendedEventDetailManaging>

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet FSPSecondarySegmentedControl *segmentedControl;

/*!
 @abstract Initializes an instance with an event
 @param event The event to be used by the contained view controllers
 */
- (id)initWithEvent:(FSPEvent *)event;

/*!
 @abstract Reloads the table views in each tab with the event data
 @param event The event to populate the contained table views with
 */
- (void)reloadTableviewsWithEvent:(FSPEvent *)event;

@end
