//
//  FSPOrganizationsViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This is the "column a" view controller, displaying a list of organizations to the user.
 */

enum {
	FSPOrganizationsPersistentCellsVideoRow = 0,
	FSPOrganizationsPersistentCellsNewsRow,
	FSPOrganizationsPersistentCellsRowCount
};


@class FSPOrganization;

@protocol FSPOrganizationsViewControllerDelegate;

@interface FSPOrganizationsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly) FSPOrganization *currentOrganization;

@property (nonatomic, weak) id<FSPOrganizationsViewControllerDelegate> delegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch;
- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch animated:(BOOL)animated;
- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch animated:(BOOL)animated retryOnReload:(BOOL)retry;

- (void)setInCustomizationMode:(BOOL)customizationMode animated:(BOOL)animated;

@end


@protocol FSPOrganizationsViewControllerDelegate <NSObject>

@optional
- (void)organizationsViewController:(FSPOrganizationsViewController *)organizationsViewController didSelectNewOrganization:(FSPOrganization *)newOrganization;
- (void)organizationsViewControllerDidSelectSportsNews:(FSPOrganizationsViewController *)organizationsViewController;
- (void)organizationsViewControllerDidSelectAllMyEvents:(FSPOrganizationsViewController *)organizationsViewController;

@end
