//
//  FSPUFCScheduleCell.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCScheduleCell.h"

#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPScheduleEvent.h"

#import "FSPEvent.h"

@interface FSPUFCScheduleCell ()
@property (weak, nonatomic) IBOutlet UILabel *fightTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightWinnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightStartTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *channelList;
@property (weak, nonatomic) IBOutlet UILabel *fightWinMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightEndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightFinalRoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTVLabel;

@end


@implementation FSPUFCScheduleCell
@synthesize fightTitleLabel;
@synthesize fightLocationLabel;
@synthesize fightDateLabel;
@synthesize fightWinnerLabel;
@synthesize winnerLabel;
@synthesize methodLabel;
@synthesize fightStartTimeLabel;
@synthesize channelList;
@synthesize fightWinMethodLabel;
@synthesize timeLabel;
@synthesize fightEndTimeLabel;
@synthesize roundLabel;
@synthesize fightFinalRoundLabel;
@synthesize timeTVLabel;

+ (CGFloat)heightForEvent:(FSPScheduleEvent *)event;
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return 70.0;
	} else {
        if ([[event valueForKey:@"eventState"] isEqualToString:@"PRE-FIGHT"]) {
            return 100;
        } else {
            return 144.0;
        }
	}
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.winnerLabel.hidden = YES;
        self.methodLabel.hidden = YES;
        self.timeLabel.hidden = YES;
        self.roundLabel.hidden = YES;
    }
    
    self.fightTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.winnerLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.methodLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.roundLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (void)populateWithEvent:(FSPScheduleEvent *)event;
{
    self.fightTitleLabel.text = [event valueForKey:@"eventTitle"];    
    self.fightLocationLabel.text = [event valueForKey:@"locationName"];
    self.fightDateLabel.text = [event.startDate fsp_weekdayMonthSlashDay];
    self.fightStartTimeLabel.text = [event.startDate fsp_lowercaseMeridianTimeStringWithTimezone];
    self.channelList.text = [event channelDisplayName];

    NSArray *stats = (NSArray *)[event valueForKey:@"stats"];
    if (stats.count) {
        
        self.fightWinnerLabel.text = [[stats objectAtIndex:0] valueForKey:@"name"];
        self.fightWinMethodLabel.text = [[stats objectAtIndex:0] valueForKey:@"value"];
        
        self.fightEndTimeLabel.text = [[stats objectAtIndex:1] valueForKey:@"value2"];
        self.fightFinalRoundLabel.text = [[stats objectAtIndex:1] valueForKey:@"value"];
    }

    
	if ([[event valueForKey:@"eventState"] isEqualToString:@"PRE-FIGHT"]) {

        self.fightStartTimeLabel.hidden = NO;   
        self.channelList.hidden = NO;
        self.timeTVLabel.hidden = NO;
        
        self.fightWinMethodLabel.hidden = YES;
        self.fightWinnerLabel.hidden = YES;
        self.fightEndTimeLabel.hidden = YES;
        self.fightFinalRoundLabel.hidden = YES;
        self.methodLabel.hidden = YES;
        self.winnerLabel.hidden = YES;
        self.roundLabel.hidden = YES;
        self.timeLabel.hidden = YES;
        		
	} else {
        // PAST EVENT
        
        self.fightStartTimeLabel.hidden = YES;   
        self.channelList.hidden = YES;
        self.timeTVLabel.hidden = YES;
        
        self.fightWinMethodLabel.hidden = NO;
        self.fightWinnerLabel.hidden = NO;
        self.fightEndTimeLabel.hidden = NO;
        self.fightFinalRoundLabel.hidden = NO;
        self.methodLabel.hidden = NO;
        self.winnerLabel.hidden = NO;
        self.roundLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        
        CGFloat height = 36;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            CGSize winnerSize = [self.fightWinnerLabel.text sizeWithFont:self.fightWinnerLabel.font constrainedToSize:CGSizeMake(self.fightWinnerLabel.frame.size.width, height)];
            CGRect winnerFrame = self.fightWinnerLabel.frame;
            winnerFrame.size.height = winnerSize.height;
            self.fightWinnerLabel.frame = winnerFrame;
        }
        
        CGSize methodSize = [self.fightWinMethodLabel.text sizeWithFont:self.fightWinMethodLabel.font constrainedToSize:CGSizeMake(self.fightWinMethodLabel.frame.size.width, height)];
        CGRect methodFrame = self.fightWinMethodLabel.frame;
        methodFrame.size.height = methodSize.height;
        self.fightWinMethodLabel.frame = methodFrame;
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
        label = @"future UFC event";
    } else {
        label = @"past UFC event";
    }
    return label;
}

@end
