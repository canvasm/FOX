//
//  FSPNewsRegionCell.m
//  FoxSports
//
//  Created by Stephen Spring on 7/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsRegionCell.h"

@implementation FSPNewsRegionCell
@synthesize selectionImageView;
@synthesize regionNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
