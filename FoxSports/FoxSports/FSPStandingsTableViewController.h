//
//  FSPStandingsTableViewController.h
//  FoxSports
//
//  Created by Laura Savino on 4/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPOrganization.h"
#import "FSPRankingsTableFooterView.h"

/**
 * This class manages a standings table view for a given conference. 
 */

extern NSString * const FSPStandingsCellReuseIdentifier;

@protocol FSPStandingsTableViewControllerDelegate

- (void)standingsTableViewDidUpdate:(UITableView *)tableView;

@end

typedef enum {
    FSPStandingsTypeConference = 0,
    FSPStandingsTypeDivision
} FSPStandingsSegmentSelected;

@class FSPOrganization;

@interface FSPStandingsTableViewController : UITableViewController <FSPRankingsTableFooterViewDelegate>

/**
 * Receives notifications that the table view has successfully updated its contents
 */
@property (nonatomic, strong) id<FSPStandingsTableViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) FSPOrganization *organization;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
/**
 * Initializes the receiver with a table view to be populated with teams from
 * the given organization belonging to the given conference name.
 */
- (id)initWithOrganization:(FSPOrganization *)organization conferenceName:(NSString *)conferenceName
      managedObjectContext:(NSManagedObjectContext *)context segment:(FSPStandingsSegmentSelected)standingsTypeSelected;

- (void)refreshStandings;

// Reload with a new organization. Used by e.g. NCAA football, where the search predicate must change with the
// selected conference.
- (void)resetWithNewOrganization:(FSPOrganization *)organization;

// Sets which poll to show in the rankings, e.g. "AP"
@property (nonatomic, strong) NSString *pollType;

@end
