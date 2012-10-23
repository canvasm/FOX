//
//  FSPNFLLeagueScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLLeagueScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "FSPScheduleNFLGame.h"

@implementation FSPNFLLeagueScheduleHeaderView

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNFLLeagueScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
    NSString *preseasonString = @"";
    if ([event.seasonType isEqualToString:@"EXHIBITION"]) {
        preseasonString = @"Preseason ";
        if (((FSPScheduleNFLGame *)event).weekNumber == 0) {
            self.topBarView.sectionTitleLabel.text = @"Hall of Fame Game";
            return;
        }
    }
    self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@Week %d", preseasonString, ((FSPScheduleNFLGame *)event).weekNumber];
}

+ (CGFloat) headerHeght
{
    return FSPLeagueScheduleHeaderHeight / 2;
}
@end
