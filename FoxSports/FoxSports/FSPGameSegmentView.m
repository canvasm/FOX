//
//  FSPGameSegmentView.m
//  FoxSports
//
//  Created by Laura Savino on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameSegmentView.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPGameSegmentView () {}

@property (nonatomic, strong) IBOutlet UILabel *gameSegmentLabel;
@property (nonatomic, strong) IBOutlet UILabel *homeTeamScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *awayTeamScoreLabel;

@end

@implementation FSPGameSegmentView

@synthesize gameSegmentLabel;
@synthesize homeTeamScoreLabel = _homeTeamScoreLabel;
@synthesize awayTeamScoreLabel = _awayTeamScoreLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = nil;
    UINib *nib = [UINib nibWithNibName:@"FSPGameSegmentView" bundle:nil];
    NSArray *objs = [nib instantiateWithOwner:nil options:nil];
    self = [objs lastObject];
    
    if (self) {
        self.gameSegmentLabel.textColor = [UIColor fsp_lightMediumBlueColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setXPosition:(CGFloat)xPosition
{
	CGRect frame = self.frame;
	frame.origin.x = xPosition;
	self.frame = frame;
}

- (void)setScoreLabelFonts:(UIFont *)font
{
    NSString *fontName = [font fontName];
    self.gameSegmentLabel.font = [UIFont fontWithName:fontName size:13.0f];
	self.homeTeamScoreLabel.font = font;
	self.awayTeamScoreLabel.font = font;
}

@end
