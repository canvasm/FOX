//
//  FSPSoccerTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "NSDate+FSPExtensions.h"

@interface FSPSoccerTeamScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;

@end

@implementation FSPSoccerTeamScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;

+ (CGFloat)headerHeght;
{
    return 60;
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPSoccerTeamScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];
    
    self.columnOneLabel.text = @"Date";
    self.columnTwoLabel.text = @"Home";
    self.columnThreeLabel.text = @"Result";
    self.columnFourLabel.text = @"Away";
    
    
	if (!self.isFuture) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            for (UILabel *label in self.labels)
                label.hidden = NO;
        }
        
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

		self.columnFiveLabel.text = @"Venue";
        self.columnOneLabel.hidden = YES;
        self.columnThreeLabel.hidden = NO;
	}
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            for (UILabel *label in self.labels)
                label.hidden = YES;
        }
        
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

		self.columnFiveLabel.text = @"TV";
        self.columnOneLabel.hidden = NO;
        self.columnThreeLabel.hidden = YES;
	}
}

@end
