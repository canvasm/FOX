//
//  FSPScheduleCell.m
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleCell.h"

#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPScheduleGame.h"
#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

CGFloat const FSPTimeLabelX = 322.0;
CGFloat const FSPTVLabelX = 434.0;
CGFloat const FSPChannelLabelX = 572.0;

@interface FSPScheduleCell ()

@property (nonatomic, weak) IBOutlet UILabel *col0Label;
@property (nonatomic, weak) IBOutlet UILabel *col1Label;
@property (nonatomic, weak) IBOutlet UILabel *col2Label;
@property (nonatomic, weak) IBOutlet UILabel *col3Label;


@end

@implementation FSPScheduleCell

@synthesize col0Label = _col0Label;
@synthesize col1Label = _col1Label;
@synthesize col2Label = _col2Label;
@synthesize col3Label = _col3Label;
@synthesize valueLabels = _valueLabels;
@synthesize future = _future;
@synthesize lightLabels;
@synthesize darkLabels;
@synthesize orangeLabels;

+ (CGFloat) heightForEvent:(FSPScheduleEvent *)game
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 30.0;
    }
    else {
        return 52;
    }
}

- (void)awakeFromNib
{
    self.col0Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.col0Label.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];

    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    for (UILabel *label in self.valueLabels) {
        label.font = font;
    }
    
    for (UILabel *label in self.lightLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0f];
    }
    for (UILabel *label in self.darkLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:1.0];
    }
    for (UILabel *label in self.orangeLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];
    }
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		self.col0Label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
		self.col2Label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:13.0];
	}
	
    self.future = YES;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    for (UILabel *label in self.valueLabels) {
        label.shadowColor = shadowColor;
    }

    self.col0Label.shadowColor = shadowColor;
}

- (void)setFuture:(BOOL)future
{
    if (_future != future) {
        _future = future;
        [self updateSubviewPositions];
    }
}

- (void)populateWithGame:(FSPScheduleGame *)game;
{
	[self populateWithEvent:game];
    
    if (self.isFuture) {
        NSString *homeTeamText = [game.homeTeam.primaryRank intValue] > 0 ? [NSString stringWithFormat:@"%@ %@", game.homeTeam.primaryRank, game.homeTeamName]: game.homeTeam.name;
        NSString *awayTeamText = [game.awayTeam.primaryRank intValue] > 0 ? [NSString stringWithFormat:@"%@ %@", game.awayTeam.primaryRank, game.awayTeamName] : game.awayTeam.name;
        // Set the rank
        self.col0Label.text = [NSString stringWithFormat:@"%@ @ %@", homeTeamText, awayTeamText];
    }
}

- (void)populateWithEvent:(FSPScheduleEvent *)event
{
	// Figure out if this is a future date or not
    if ([event.normalizedStartDate fsp_isToday]) {
        self.future = YES;
    } else {
        NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:event.normalizedStartDate];
        self.future = (comparisonResult == NSOrderedAscending);
    }

	if (self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.col1Label.text = [self startDateStringFromEvent:event];
			self.col2Label.text = event.channelDisplayName;
		} else {
			self.col1Label.hidden = YES;
			self.col2Label.text = [NSString stringWithFormat:@"%@ %@ %@", [self startDateStringFromEvent:event], [[NSTimeZone localTimeZone] abbreviation], event.channelDisplayName];
			
		}
        self.col3Label.text = @""; //TODO:Calendar goes here
        self.col3Label.hidden = YES; //TODO: remove when calendar available
    }

}

- (void)updateSubviewPositions;
{
    if (self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			CGRect col0Frame = self.col0Label.frame;
			col0Frame.size.width = self.col2Label.frame.origin.x - 5 - col0Frame.origin.x;
			col0Frame.size.height = 41.0f;
			self.col0Label.frame = col0Frame;
		} else {
			//Lay out subviews for 3-column view
			CGRect timeFrame = self.col1Label.frame;
			timeFrame.origin.x = FSPTimeLabelX;
			self.col1Label.frame = timeFrame;
			
			CGRect TVFrame = self.col2Label.frame;
			TVFrame.origin.x = FSPTVLabelX;
			self.col2Label.frame = TVFrame;
			
			CGRect channelFrame = self.col3Label.frame;
			channelFrame.origin.x = FSPChannelLabelX;
			self.col3Label.frame = channelFrame;
		}
    } else {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			CGRect col0Frame = self.col0Label.frame;
			col0Frame.size.width = 296;
			col0Frame.size.height = 21.0f;
			self.col0Label.frame = col0Frame;
		}
	}
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.col0Label.text = nil;
	self.col0Label.hidden = NO;
    self.col1Label.text = nil;
	self.col1Label.hidden = NO;
    self.col2Label.text = nil;
	self.col2Label.hidden  =NO;
    self.col3Label.text = nil;
	self.col3Label.hidden = NO;

}

- (NSString *)startDateStringFromEvent:(FSPScheduleGame *)game;
{
    NSString *displayString;

    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"h:mma";
    });
    displayString = [[formatter stringFromDate:game.startDate] lowercaseString];

    return displayString;
}


@end
