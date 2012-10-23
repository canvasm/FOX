//
//  FSPMLBLeagueScheduleHeaderView.m
//  FoxSports
//
//  Created by Chase Latta on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARScheduleHeaderView.h"
#import "FSPTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"

@interface FSPNASCARScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;

@end

@implementation FSPNASCARScheduleHeaderView
@synthesize columnFourLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNASCARScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
  
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
    
    self.columnOneLabel.text = @"Date";
    self.columnTwoLabel.text = @"Event / Location";
    
    if (!self.isFuture) {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
		
        self.columnThreeLabel.text = @"Winner";
		self.columnFourLabel.text = @"Pole Winner";
    }
    else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

		NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
		self.columnThreeLabel.text = [NSString stringWithFormat:@"Time (%@)", [localTimeZone abbreviation]];
		self.columnFourLabel.text = @"TV";

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        }
        else {

        }
    }
}


@end
