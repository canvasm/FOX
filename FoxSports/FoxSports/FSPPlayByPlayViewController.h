//
//  FSPNBAPlayByPlayViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 2/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@interface FSPPlayByPlayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FSPExtendedEventDetailManaging, NSFetchedResultsControllerDelegate>

@end
