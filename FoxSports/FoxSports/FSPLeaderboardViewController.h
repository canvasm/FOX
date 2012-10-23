//
//  FSPLeaderboardViewController~ipad.h
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPEvent;
@class FSPRacingEvent;

@interface FSPLeaderboardViewController : UIViewController

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *noDataAvailableLabel;

/*!
 @abstract Initializes an instance of FSPLeaderboardViewController and populates it with event data.
 @param event The event to populate the view with
 */
- (id)initWithEvent:(FSPEvent *)event;

/*!
 @abstract Fetches data to display in tableView
 @discussion This is meant to be overridden by subclasses
 */
- (void)fetchData;

/*!
 @abstract Returns the two index paths that that will be reloaded when user selects a cell in the table view.
 @param indexPath The index path the user has selected.
 @return Returns an array of two NSIndexPath objects that represent the rows that need to reload.
 @discussion Use this method to open up a cell and disclose additional information in the cell.
 */
- (NSArray *)setIndexPathsForReloadWithSelectedIndexPath:(NSIndexPath *)indexPath;

/*!
 @abstract Checks to see if there is any data do display in the view. If so, the "No Data Available" label is hidden and the table view is displayed.
 */
- (void)updateViewForNewData;

@end
