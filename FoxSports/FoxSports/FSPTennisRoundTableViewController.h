//
//  FSPTennisRoundTableViewController.h
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@interface FSPTennisRoundTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, FSPExtendedEventDetailManaging>

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) NSInteger round;

@end
