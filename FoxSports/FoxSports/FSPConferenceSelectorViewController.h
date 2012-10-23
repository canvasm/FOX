//
//  FSPConferenceSelectorTableViewController.h
//  FoxSports
//
//  Created by Stephen Spring on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPOrganization;

typedef void(^SelectionChangedBlock)(FSPOrganization *organization);

@interface FSPConferenceSelectorViewController : UITableViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) FSPOrganization *selectedConference;

@property (nonatomic, strong, readonly) NSArray *organizations;
@property (nonatomic, copy, readonly) SelectionChangedBlock selectionChangedBlock;
@property (nonatomic, assign) BOOL includeTeams;
@property (nonatomic, assign) BOOL includeTournaments;

/*!
 @abstract Initializes a UIViewController with a tableView and populates it with organizations.
 @param organizations The organizations to display in the tableView.
 @param selectionCompletion A block object completion handler containing the selected organization. 
 */
- (id)initWithOrganizations:(NSSet *)organizations includeTournamets:(BOOL)includeTournaments style:(UITableViewStyle)style selectionCompletionHandler:(void(^)(FSPOrganization *organization))selectionCompletion;

- (void)populateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withOrganization:(FSPOrganization *)organization;
- (void)updateContentSize;

@end
