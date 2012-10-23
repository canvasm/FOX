//
//  FSPNFLTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"

static CGFloat FSPChannelOriginX = 355.0;
static CGFloat FSPPassingOriginX = 332.0;

@interface FSPNFLTeamScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnSixLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnSevenLabel;

@end

@implementation FSPNFLTeamScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;
@synthesize columnSixLabel = _columnSixLabel;
@synthesize columnSevenLabel = _columnSevenLabel;

- (id)init
{
    UINib *nib = [UINib nibWithNibName:@"FSPNFLTeamScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
    
    self.columnOneLabel.text = @"Wk";
    self.columnTwoLabel.text = @"Date";
    self.columnThreeLabel.text = @"Opponent";
    
    if (!self.isFuture) {
        
        self.columnSixLabel.hidden = NO;
        self.columnSevenLabel.hidden = NO;
        self.columnFourLabel.hidden = NO;

        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

        self.columnFourLabel.text = @"Result";
        self.columnFiveLabel.text = @"Passing Yds";
        CGRect col5Frame = self.columnFiveLabel.frame;
        col5Frame.origin.x = FSPPassingOriginX;
        self.columnFiveLabel.frame = col5Frame;
        self.columnSixLabel.text = @"Rushing Yds";
        self.columnSevenLabel.text = @"Receiving Yds";
    }
    else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

        self.columnSixLabel.hidden = YES;
        self.columnSevenLabel.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.columnFourLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]];
            self.columnFiveLabel.text = @"TV";
            CGRect col5Frame = self.columnFiveLabel.frame;
            col5Frame.origin.x = FSPChannelOriginX;
            self.columnFiveLabel.frame = col5Frame;
        }
        else {
            self.columnOneLabel.hidden = NO;
            self.columnFourLabel.hidden = YES;
            self.columnThreeLabel.text = @"Opponent/Time/TV";
        }
    }
}

@end
