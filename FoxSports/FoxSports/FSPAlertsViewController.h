//
//  FSPAlertsViewController.h
//  FoxSports
//
//  Created by greay on 5/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPEvent, FSPOrganization;

@interface FSPAlertsViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UILabel *teamsLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UISwitch *switchControl;

@property (assign) BOOL gameStartAlerts;
@property (assign) BOOL eachScoringPlayAlerts;
@property (assign) BOOL eachQuarterAlerts;
@property (assign) BOOL finalAlerts;
@property (assign) BOOL updateAlerts;
@property (assign) BOOL excitingAlerts;

- (void)populateWithEvent:(FSPEvent *)event;
- (void)populateWithOrganization:(FSPOrganization *)org;

@end
