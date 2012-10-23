//
//  FSPMassRelevanceViewController.h
//  FoxSports
//
//  Created by Rowan Christmas on 7/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPUFCFightCardTableViewCell.h"

@class FSPEvent;

@interface FSPMassRelevanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FSPEvent *currentEvent;
- (void)topBarButtonClicked:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *topBarButtons;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end