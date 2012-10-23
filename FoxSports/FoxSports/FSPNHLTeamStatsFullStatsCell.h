//
//  FSPNHLTeamStatsFullStatsCell.h
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPNHLTeamStatsFullStatsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *rowHeaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *rowSubheaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamAValue;
@property (nonatomic, strong) IBOutlet UILabel *teamBValue;

@end
