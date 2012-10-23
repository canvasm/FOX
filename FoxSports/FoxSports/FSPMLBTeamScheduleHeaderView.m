//
//  FSPMLBTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"

static CGFloat FSPCalendarOriginXiPhone = 253.0;

@interface FSPMLBTeamScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnSixLabel;

@end

@implementation FSPMLBTeamScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;
@synthesize columnSixLabel = _columnSixLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPMLBTeamScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];
    
    self.columnOneLabel.text = @"Date";
    self.columnTwoLabel.text = @"Opponent";

	if (!self.isFuture) {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter] stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
        self.columnThreeLabel.text = @"Result";
        self.columnFourLabel.text = @"Win";
        self.columnFiveLabel.text = @"Loss";
        self.columnFiveLabel.hidden = NO;
        self.columnSixLabel.text = @"Save";
        self.columnSixLabel.textAlignment = UITextAlignmentCenter;
	}
    else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter] stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.columnThreeLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]];
            self.columnFourLabel.text = @"TV";
            self.columnSixLabel.text = @"Calendar";
            self.columnSixLabel.textAlignment = UITextAlignmentRight;
            self.columnFiveLabel.hidden = YES;
        }
        else {
            self.columnOneLabel.hidden = NO;
            self.columnTwoLabel.text = @"Opponent/Time/TV";
            CGRect col3Frame = self.columnThreeLabel.frame;
            col3Frame.origin.x = FSPCalendarOriginXiPhone;
            self.columnThreeLabel.frame = col3Frame;
            self.columnThreeLabel.text = @"Calendar";
}
    }
}

@end
