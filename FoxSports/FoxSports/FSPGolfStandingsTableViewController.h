//
//  FSPGolfStandingsTableViewController.h
//  FoxSports
//
//  Created by greay on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsTableViewController.h"

@interface FSPGolfStandingsTableViewController : FSPStandingsTableViewController

- (id)initWithOrganization:(FSPOrganization *)organization conferenceName:(NSString *)conferenceName
      managedObjectContext:(NSManagedObjectContext *)context standingsType:(NSString *)standingsType;

@property (assign) BOOL drawDivider;

@end
