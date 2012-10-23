//
//  FSPTennisScheduleHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "FSPScheduleTennisEvent.h"
#import "NSDate+FSPExtensions.h"

@interface FSPTennisScheduleHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel * timeWinnerHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel * prizeChannelLabel;

@end

@implementation FSPTennisScheduleHeaderView

+ (CGFloat)headerHeght;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 30;
    } else {
        return 60;
    }
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPTennisScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleTennisEvent *)event
{
	[super setEvent:event];
    
    if ([event.endDate fsp_isToday]) {
        self.future = YES;
    } else {
        NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:event.endDate];
        self.future = (comparisonResult == NSOrderedAscending);
    }
    
    NSString *headerString = [NSString stringWithFormat:@"%@ Season", event.seasonType];
    
	if (self.isFuture) {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ Schedule", headerString];
		self.timeWinnerHeaderLabel.text = @"Time";
        self.prizeChannelLabel.text = @"Channel";
	} else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ Results", headerString];
        self.timeWinnerHeaderLabel.text = @"Winner";
        self.prizeChannelLabel.text = @"Prize";
    }
}

@end
