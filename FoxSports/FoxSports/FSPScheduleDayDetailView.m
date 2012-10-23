//
//  FSPScheduleDayDetailView.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleDayDetailView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@implementation FSPScheduleDayDetailView
@synthesize dayLabel;
@synthesize dayCoverageLabel;
@synthesize timeLabel;
@synthesize channelLabel;
@synthesize valueLabels;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UINib *nib = [UINib nibWithNibName:@"FSPScheduleDayDetailView" bundle:nil];
        NSArray *topLevelObjects = [nib instantiateWithOwner:self options:nil];
        self = [topLevelObjects objectAtIndex:0];
        self.frame = frame;
        [self styleLabels];
    }
    return self;
}

- (void)styleLabels
{
    for (UILabel *label in self.valueLabels) {
        label.textColor = [UIColor fsp_darkBlueColor];
        label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    }
}

@end
