//
//  FSPNHLTeamStatsFullStatsCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLTeamStatsFullStatsCell.h"

@implementation FSPNHLTeamStatsFullStatsCell

@synthesize rowHeaderLabel = _rowHeaderLabel;
@synthesize rowSubheaderLabel = _rowSubheaderLabel;
@synthesize teamAValue = _teamAValue;
@synthesize teamBValue = _teamBValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
