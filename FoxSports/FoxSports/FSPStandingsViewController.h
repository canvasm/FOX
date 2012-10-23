//
//  FSPNBAConferencesViewController.h
//  FoxSports
//
//  Created by Matthew Fay on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPOrganization;

@interface FSPStandingsViewController : UIViewController <NSFetchedResultsControllerDelegate>

/**
 * Initializes the receiver with a conference, and the managed object context.
 */
- (id)initWithOrganization:(FSPOrganization *)organization managedObjectContext:(NSManagedObjectContext *)context;

@end
