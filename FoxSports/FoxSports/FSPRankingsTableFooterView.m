//
//  FSPRankingsTableFooterView.m
//  FoxSports
//
//  Created by Joshua Dubey on 9/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRankingsTableFooterView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPRankingsTableFooterView ()

@property (nonatomic, strong) UILabel *droppedTeamsLabel;
@property (nonatomic, strong) UILabel *otherTeamsLabel;

@end

@implementation FSPRankingsTableFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.droppedTeamsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 0)];
        self.droppedTeamsLabel.numberOfLines = 0;
        self.droppedTeamsLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.droppedTeamsLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        self.droppedTeamsLabel.textColor = [UIColor fsp_darkBlueColor];
        
        self.otherTeamsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 0)];
        self.otherTeamsLabel.numberOfLines = 0;
        self.otherTeamsLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.otherTeamsLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        self.otherTeamsLabel.textColor = [UIColor fsp_darkBlueColor];
        
        [self addSubview:self.droppedTeamsLabel];
        [self addSubview:self.otherTeamsLabel];

    }
    return self;
}

- (void)layoutSubviews
{
    if (self.droppedTeams) {
        CGSize constraintSize = CGSizeMake(self.frame.size.width - 20 ,1000);
        UIFont  *labelFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        CGSize labelSize = [self.droppedTeams sizeWithFont:labelFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        self.droppedTeamsLabel.frame = CGRectMake(10,0,labelSize.width, labelSize.height);
        self.droppedTeamsLabel.text = self.droppedTeams;
    }
    
    if (self.otherTeams) {
        CGSize constraintSize = CGSizeMake(self.frame.size.width - 20 ,1000);
        UIFont  *labelFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        CGSize labelSize = [self.otherTeams sizeWithFont:labelFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        self.otherTeamsLabel.frame = CGRectMake(10,0,labelSize.width, labelSize.height);
        self.otherTeamsLabel.text = self.otherTeams;
    }
    
    CGRect droppedFrame = self.droppedTeamsLabel.frame;
    droppedFrame.origin.y = 5;
    self.droppedTeamsLabel.frame = droppedFrame;
    
    CGRect otherFrame = self.otherTeamsLabel.frame;
    otherFrame.origin.y = CGRectGetMaxY(self.droppedTeamsLabel.frame) + 5;
    self.otherTeamsLabel.frame = otherFrame;
    
    CGRect viewFrame = self.frame;
    viewFrame.size.height = CGRectGetMaxY(self.otherTeamsLabel.frame) + 60;
    self.frame = viewFrame;

    if ([self.delegate respondsToSelector:@selector(rankingsFooterDidFinishLayout)]) {
        [self.delegate rankingsFooterDidFinishLayout];
    }
}


@end
