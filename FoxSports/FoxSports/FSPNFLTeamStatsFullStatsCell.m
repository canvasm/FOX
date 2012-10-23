//
//  FSPNFLTeamStatsFullStatsCell.m
//  FoxSports
//
//  Created by Ed McKenzie on 7/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamStatsFullStatsCell.h"

@implementation FSPNFLTeamStatsFullStatsCell

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
