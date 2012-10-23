//
//  FSPNHLTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"


@interface FSPNHLTeamScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnSixLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnSevenLabel;

@end

@implementation FSPNHLTeamScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;
@synthesize columnSixLabel = _columnSixLabel;
@synthesize columnSevenLabel = _columnSevenLabel;

- (id)init
{
    UINib *nib = [UINib nibWithNibName:@"FSPNHLTeamScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
    
    self.columnTwoLabel.text = @"Date";
    self.columnThreeLabel.text = @"Opponent";
    
    if (!self.isFuture) {
        
        self.columnFourLabel.hidden = YES;
        self.columnSevenLabel.hidden = YES;
        self.columnSixLabel.text = @"Result";
        self.columnFiveLabel.text = @"Top Performer";

        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
    }
    else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

        self.columnFourLabel.hidden = NO;
        self.columnSevenLabel.hidden = NO;
        self.columnSixLabel.hidden = YES;
        self.columnFiveLabel.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.columnFourLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]];
        }
        else {
            self.columnFourLabel.hidden = YES;
            self.columnThreeLabel.text = @"Opponent/Time/TV";
        }
    }
}

@end
