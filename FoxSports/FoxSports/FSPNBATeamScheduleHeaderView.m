//
//  FSPNBATeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBATeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"

static CGFloat const FSPResultHeaderRightOriginX = 322.0; 
static CGFloat const FSTopScorerHeaderRightOriginX = 434.0;

@interface FSPNBATeamScheduleHeaderView ()
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;

@end

@implementation FSPNBATeamScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNBATeamScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];

    self.columnOneLabel.text = @"Date";
    self.columnTwoLabel.text = @"Opponent";
    self.columnOneLabel.hidden = NO;

	if (!self.isFuture) {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
        self.columnThreeLabel.text = @"Result";
        self.columnThreeLabel.hidden = NO;
        self.columnFourLabel.text = @"Top Scorer";
        self.columnFiveLabel.hidden = YES;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //Lay out the cell for only 4 labels
            CGRect resultFrame = self.columnThreeLabel.frame;
            resultFrame.origin.x = FSPResultHeaderRightOriginX;
            self.columnThreeLabel.frame = resultFrame;
            
            CGRect topPlayerRightFrame = self.columnFourLabel.frame;
            topPlayerRightFrame.origin.x = FSTopScorerHeaderRightOriginX;
            self.columnFourLabel.frame = topPlayerRightFrame;
        }
            
            
	}
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.columnTwoLabel.text = @"Opponent/Time/TV";
            self.columnThreeLabel.hidden = YES;
        }
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
        self.columnThreeLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]];
        self.columnFourLabel.text = @"TV";
        self.columnFiveLabel.text = @"Calendar";
        self.columnFiveLabel.hidden = YES; // TODO: unhide when calendar available.
    }
}

@end
