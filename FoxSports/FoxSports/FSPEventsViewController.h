//
//  FSPEventsViewController.h
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPAdManager.h"

#define ADS_ENABLED NO

/**
 * This is the "column b" table view controller, containing chips related to a given organization.
 */

extern const NSInteger FSPAdRowIndex;
extern const NSInteger FSPAdSectionIndex;

@class FSPEvent;
@class FSPNewsStory;
@class FSPNewsHeadline;
@class FSPVideo;
@class FSPOrganization;

@protocol FSPEventsViewControllerDelegate;

@interface FSPEventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FSPAdViewDelegate, NSFetchedResultsControllerDelegate>

// The delegate that responds to the selection of chips
@property (nonatomic, weak) id <FSPEventsViewControllerDelegate> delegate;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UILabel *noDataAvailable;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, strong) NSIndexPath *currentSelectedEventPath;
@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) FSPEvent *selectedEvent;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 The designated initializer.
 */
- (id)initWithOrganization:(FSPOrganization *)organization managedObjectContext:(NSManagedObjectContext *)context;


/**
 convenience method that takes a tableView index path, and returns a new index path adjusted for the ad row
 */
- (NSIndexPath *)adjustedIndexPath:(NSIndexPath *)indexPath;

- (void)selectCurrentEventOnTable;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end


@protocol FSPEventsViewControllerDelegate <NSObject>

- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectEvent:(FSPEvent *)event;
- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectNewsHeadline:(FSPNewsHeadline *)headline;
- (void)eventsViewController:(FSPEventsViewController *)viewController didSelectVideo:(FSPVideo *)video;

@end
