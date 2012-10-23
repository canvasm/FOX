//
//  FSPNASCARScheduleCell.m
//  FoxSports
//
//  Created by Matthew Fay on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARScheduleCell.h"
#import "FSPScheduleRacingEvent.h"

#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPNASCARScheduleCell ()
@property (nonatomic, weak) IBOutlet UILabel *col1SubLabel;
@property (nonatomic, weak) IBOutlet UILabel *col2SubLabel;
@property (nonatomic, weak) IBOutlet UILabel *col3SubLabel;
@end


@implementation FSPNASCARScheduleCell
@synthesize col1SubLabel, col2SubLabel, col3SubLabel;

+ (CGFloat)heightForEvent:(FSPScheduleEvent *)event
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return 44.0;
	} else {
		return [super heightForEvent:event];
	}
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
	self.col1Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
}

- (void)populateWithEvent:(FSPScheduleRacingEvent *)event;
{
	[super populateWithEvent:event];

    self.col0Label.text = [event.startDate fsp_weekdayMonthSlashDay];
	self.col1Label.text = event.eventTitle;
	self.col1SubLabel.text = event.venue;

	self.col0Label.hidden = NO;
	self.col1Label.hidden = NO;
	self.col2Label.hidden = NO;
	self.col3Label.hidden = NO;
	
	if (!self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			self.col2Label.text = event.winnerName; // abbreviated name...
			self.col2SubLabel.text = nil;
		} else {
			self.col2Label.text = event.winnerName;
			self.col2SubLabel.text = event.winnerCar;

			self.col3Label.text = event.poleWinnerName;
			self.col3SubLabel.text = event.poleWinnerCar;
		}
		
	} else {
		self.col2Label.text = [event.startDate fsp_lowercaseMeridianTimeString];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			self.col2SubLabel.text = event.channelDisplayName;
			self.col2SubLabel.hidden = NO;
		} else {
			self.col2SubLabel.text = nil;
			
			self.col3Label.text = event.channelDisplayName;
			self.col3SubLabel.text = nil;
		}
	}
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		CGRect frame = self.col1Label.frame;		
		CGSize labelSize = [self.col1Label.text sizeWithFont:self.col1Label.font constrainedToSize:CGSizeMake(frame.size.width, 33)];
		frame.size.height = labelSize.height;
		self.col1Label.frame = frame;

	}
}

- (void)updateSubviewPositions;
{
	// nothing, for now...
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *label;
    if (self.isFuture) {
        label = @"future NASCAR event";
    } else {
        label = @"past NASCAR event";
    }
    return label;
}

@end
