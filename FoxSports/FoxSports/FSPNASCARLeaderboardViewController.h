//
//  FSPNASCARLeaderboardViewController~ipad.h
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@class FSPEvent;
@class FSPRacingEvent;

@interface FSPNASCARLeaderboardViewController : UIViewController <FSPExtendedEventDetailManaging>

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) IBOutlet UILabel *noDataAvailableLabel;

/*!
 @abstract Initializes an instance of FSPNASCARLeaderboardViewController and populates it with event data.
 @param event The event to populate the view with
 */
- (id)initWithEvent:(FSPRacingEvent *)event;

/*!
 @abstract Fetches data to display in tableView
 @discussion This is meant to be overridden by subclasses
 */
- (void)fetchData;

@end
