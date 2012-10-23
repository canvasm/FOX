//
//  FSPNASCAREventPreEventViewController.h
//  FoxSports
//
//  Created by greay on 7/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"
#import "FSPGamePreGameViewController.h"

@interface FSPNASCAREventPreEventViewController : FSPGamePreGameViewController <FSPExtendedEventDetailManaging,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic, weak, readonly) UILabel *locationLabel;
@property (nonatomic, weak, readonly) UILabel *trackTypeLabel;
@property (nonatomic, weak, readonly) UIImageView *trackImageView;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UILabel *trackTypeTitleLabel;
@property (nonatomic, weak, readonly) UILabel *locationTitleLabel;
@property (nonatomic, weak, readonly) UILabel *noStoryLabel;

@end
