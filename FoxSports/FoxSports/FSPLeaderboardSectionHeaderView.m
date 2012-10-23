//
//  FSPLeaderboardSectionHeaderView.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLeaderboardSectionHeaderView.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPGameDetailSectionHeader.h"

@implementation FSPLeaderboardSectionHeaderView

@synthesize titleLabel = _titleLabel;
@synthesize headerLabels = _headerLabels;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)styleHeader
{
    [self addTopView];
    [self addEtches];
    [self styleLabels];
}

- (void)addEtches
{
    UIView *topEtch = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 2.0, self.frame.size.width, 1.0)];
    topEtch.backgroundColor = [UIColor fsp_topEtchColor];
    [self addSubview:topEtch];
    
    UIView *bottomEtch = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 1.0, self.frame.size.width, 1.0)];
    bottomEtch.backgroundColor = [UIColor fsp_bottomEtchColor];
    [self addSubview:bottomEtch];
}

- (void)addTopView
{
    FSPGameDetailSectionHeader *topView = [[FSPGameDetailSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width + 4.0, 36.0)];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 8.0, 300.0, 21.0)];
    self.titleLabel.text = @"Full Leaderboard";
    [topView addSubview:self.titleLabel];
    [self addSubview:topView];
}

- (void)styleLabels
{
    UIFont *labelFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIColor *fontColor = [UIColor whiteColor];
    for (UILabel *label in _headerLabels) {
        label.font = labelFont;
        label.textColor = fontColor;
    }
    self.titleLabel.font = labelFont;
    self.titleLabel.textColor = fontColor;
    self.titleLabel.backgroundColor = [UIColor clearColor];
}

@end
