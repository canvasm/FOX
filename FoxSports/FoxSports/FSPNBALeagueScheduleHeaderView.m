//
//  FSPNBALeagueScheduleHeaderView.m
//  FoxSports
//
//  Created by Chase Latta on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBALeagueScheduleHeaderView.h"
#import <QuartzCore/QuartzCore.h>


static CGFloat const FSPWinningPlayerHeaderLeftOriginX = 292.0;
static CGFloat const FSPWinningPlayerHeaderRightOriginX = 470.0;

//TODO: Set these values somewhere both header and cells can access them
static CGFloat const FSPTimeLabelHeaderX = 322.0;
static CGFloat const FSPTVLabelHeaderX = 434.0;
static CGFloat const FSPChannelLabelHeaderX = 572.0;

@interface FSPNBALeagueScheduleHeaderView ()
@property (nonatomic, weak) IBOutlet UILabel *timeTVLabel;
@end

@implementation FSPNBALeagueScheduleHeaderView
@synthesize timeTVLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNBALeagueScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];

    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];
	if (!self.isFuture) {
        self.timeTVLabel.hidden = YES;
		self.columnOneLabel.text = @"Top Scorer";
		self.columnTwoLabel.text = @"Top Scorer";

        //Lay out the cell for only 2 labels
        CGRect topPlayerLeftFrame = self.columnOneLabel.frame;
        topPlayerLeftFrame.origin.x = FSPWinningPlayerHeaderLeftOriginX;
        self.columnOneLabel.frame = topPlayerLeftFrame;
        
        CGRect topPlayerRightFrame = self.columnTwoLabel.frame;
        topPlayerRightFrame.origin.x = FSPWinningPlayerHeaderRightOriginX;
        self.columnTwoLabel.frame = topPlayerRightFrame;
        
        self.columnThreeLabel.hidden = YES;

	} else {
        self.timeTVLabel.hidden = NO;
        CGRect columnOneRect = self.columnOneLabel.frame;
        columnOneRect.origin.x = FSPTimeLabelHeaderX;
        self.columnOneLabel.frame = columnOneRect;
        
        CGRect columnTwoRect = self.columnTwoLabel.frame;
        columnTwoRect.origin.x = FSPTVLabelHeaderX;
        self.columnTwoLabel.frame = columnTwoRect;
        
        CGRect columnThreeRect = self.columnThreeLabel.frame;
        columnThreeRect.origin.x = FSPChannelLabelHeaderX;
        self.columnThreeLabel.frame = columnThreeRect;
        self.columnThreeLabel.hidden = NO;
    }

}

@end
