//
//  FSPNFLTeamStatsFullStatsCell.h
//  FoxSports
//
//  Created by Ed McKenzie on 7/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPNFLTeamStatsFullStatsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *rowHeaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *rowSubheaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamAValue;
@property (nonatomic, strong) IBOutlet UILabel *teamBValue;

@end
