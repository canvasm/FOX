//
//  FSPSoccerTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerLeagueScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "NSDate+FSPExtensions.h"

@interface FSPSoccerLeagueScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnFiveLabel;

@end

@implementation FSPSoccerLeagueScheduleHeaderView

@synthesize columnFourLabel = _columnFourLabel;
@synthesize columnFiveLabel = _columnFiveLabel;

+ (CGFloat)headerHeght;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 60;
    } else {
        return 60;
    }
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPSoccerLeagueScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];
    
    self.columnOneLabel.text = @"Time";
    self.columnTwoLabel.text = @"Home";
    self.columnThreeLabel.text = @"Result";
    self.columnFourLabel.text = @"Away";

    self.topBarView.sectionTitleLabel.text = [event.normalizedStartDate fsp_weekdayMonthSlashDay];
    
	if (!self.isFuture) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            for (UILabel *label in self.labels)
                label.hidden = NO;
        }
		self.columnFiveLabel.text = @"Venue";
        self.columnOneLabel.hidden = YES;
	}
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            for (UILabel *label in self.labels)
                label.hidden = YES;
        }
		self.columnFiveLabel.text = @"TV";
        self.columnOneLabel.hidden = NO;
	}
}

@end
