//
//  FSPStandingsCell.h
//  FoxSports
//
//  Created by Laura Savino on 4/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPTeam;

@interface FSPStandingsCell : UITableViewCell

@property (nonatomic, weak, readonly) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *winsLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *lossesLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *percentLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *homeRecordLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *awayRecordLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *conferenceRecordLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *divisionRecordLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *streakLabel;
@property (nonatomic, weak) IBOutlet UILabel *rankLabel;

/**
 * Labels containing values for a team's standings details (e.g., ".756" for winning percent, or "W9" for streak)
 */
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *standingsValues;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *lightBlueLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *darkBlueLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *orangeLabels;

/**
 * Sets display values for cell's subviews based on team object.
 */
- (void)populateWithTeam:(FSPTeam *)team;
@end
