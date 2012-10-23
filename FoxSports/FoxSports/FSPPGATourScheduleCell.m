//
//  FSPPGATourScheduleCell.m
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGATourScheduleCell.h"
#import "FSPPGAEvent.h"
#import "NSDate+FSPExtensions.h"
#import "FSPScheduleEvent.h"
#import "FSPCoreDataManager.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPPGAScheduleEvent.h"
#import "FSPChannel.h"
#import "FSPScheduleDayDetailView.h"

#define kCellHeightFutureEventIphone 230.0
#define kCellHeightFutureEventIpad 164.0
#define kCellHeightPastEventIphone 84.0
#define kCellHeightPastEventIpad 44.0
#define kTopMargin 10.0

NSString * const FSPPGATourScheduleCellIdentifier = @"FSPPGATourScheduleCellIdentifier";

@interface FSPPGATourScheduleCell()

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *tournamentLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel1;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel2;
@property (weak, nonatomic) IBOutlet UILabel *winnerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIphoneLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *iphoneTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dayDetailLabels;
@property (strong, nonatomic) FSPPGAScheduleEvent *scheduleEvent;
@property (strong, nonatomic) FSPPGAEvent *pgaEvent;

- (NSString *)startTimeStringFromEvent:(FSPScheduleEvent *)event;
- (NSString *)startDateStringFromEvent:(FSPScheduleEvent *)event;

/**
 * Returns a string appropriate for display in the prize money field.
 */
- (NSString *)prizeMoneyFormat:(NSNumber *)prizeMoneyAmount;

@end

@implementation FSPPGATourScheduleCell
@synthesize auxiliaryLabel2;
@synthesize winnerTitleLabel;
@synthesize timeIphoneLabel;
@synthesize iphoneTitleLabels;
@synthesize dayDetailLabels;
@synthesize auxiliaryLabel1;

@synthesize dateLabel, tournamentLabel, locationLabel, scheduleEvent = _scheduleEvent, pgaEvent = _pgaEvent;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[UILabel appearanceWhenContainedIn:[self class], nil] setShadowColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.9]];
    [[UILabel appearanceWhenContainedIn:[self class], nil] setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    self.tournamentLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
    self.tournamentLabel.textColor = [UIColor fsp_darkBlueColor];
    
    self.locationLabel.font = [UIFont fontWithName:FSPClearViewMediumFontName size:12.0];
    self.locationLabel.textColor = [UIColor fsp_darkBlueColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        for (UILabel *label in self.iphoneTitleLabels) {
            label.textColor = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];
            label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
        }
        
        self.winnerTitleLabel.textColor = [UIColor fsp_darkBlueColor];
        self.winnerTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
        self.auxiliaryLabel1.textColor = [UIColor fsp_darkBlueColor];
        self.auxiliaryLabel1.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
        self.locationLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    }
}

+ (CGFloat)heightForEvent:(FSPScheduleEvent *)game
{
    FSPPGAScheduleEvent *event = (FSPPGAScheduleEvent *)game;
    if ([FSPPGATourScheduleCell eventFromPast:event]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            return kCellHeightPastEventIphone;
        }
        return kCellHeightPastEventIpad;
    }
    else {
        NSInteger numberOfChannels = [game.channels count];
        CGFloat baseHeight;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            baseHeight = 32.0 + kTopMargin;
        } else {
            baseHeight = 59.0 + kTopMargin;
        }
        return baseHeight + ([FSPPGATourScheduleCell dayDetailViewHeight] * numberOfChannels);
    }
}

- (void)populateWithEvent:(FSPScheduleEvent *)event
{
    self.scheduleEvent = (FSPPGAScheduleEvent *)event;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [self formattedDate:self.scheduleEvent.startDate], [self formattedDate:self.scheduleEvent.endDate]];
    self.tournamentLabel.text = [event valueForKey:@"eventTitle"];
    self.locationLabel.text = [event valueForKey:@"venueName"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPPGAEvent"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventTitle MATCHES %@", [self.scheduleEvent valueForKey:@"eventTitle"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [[FSPCoreDataManager sharedManager].GUIObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count]) {
        self.pgaEvent = [results objectAtIndex:0];
    }
    
    if ([FSPPGATourScheduleCell eventFromPast:self.scheduleEvent]) {
        [self populatePastEventLabels];
        self.timeIphoneLabel.hidden = YES;
    } else {
        [self populateFutureEventLabels];
        self.timeIphoneLabel.hidden = NO;
    }
    
    [self setCellForPastEvent:[FSPPGATourScheduleCell eventFromPast:self.scheduleEvent]];
}

- (void)setCellForPastEvent:(BOOL)pastEvent
{
    // Hide/show appropriate labels
    for (UILabel *label in self.dayDetailLabels) {
        if (pastEvent) {
            [label removeFromSuperview];
        } else {
            [self addSubview:label];
        }
    }
    
    self.winnerTitleLabel.hidden = !pastEvent;
    self.auxiliaryLabel1.hidden = !pastEvent;
    self.auxiliaryLabel2.hidden = !pastEvent;
    self.frame = pastEvent ? CGRectMake(0.0, 0.0, 320.0, kCellHeightPastEventIphone) : CGRectMake(0.0, 0.0, 320.0, kCellHeightFutureEventIpad);
}

+ (BOOL)eventFromPast:(FSPPGAScheduleEvent *)event
{
    NSDate *currentDate = [NSDate date];
    if ([[event.startDate laterDate:currentDate] isEqualToDate:currentDate]) {
        return YES;
    }
    return NO;
}

- (NSString *)formattedDate:(NSDate *)date
{
    NSDateComponents *currentDayComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    NSDate *currentDate = [[NSCalendar currentCalendar] dateFromComponents:currentDayComponents];
    NSDateComponents *dayComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:date];
    NSDate *dayDate = [[NSCalendar currentCalendar] dateFromComponents:dayComponents];
    
    if ([currentDate isEqualToDate:dayDate]) {
        return @"Today";
    }
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    [dateFormatter setDateFormat:@"M/d"];
     // On iPhone Tour result dates have the day as well.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [FSPPGATourScheduleCell eventFromPast:self.scheduleEvent]) {
        [dateFormatter setDateFormat:@"EEE M/d"];
    }

    return [dateFormatter stringFromDate:date];
}

- (void)populatePastEventLabels
{
    NSString *eventWinner = self.scheduleEvent.name;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.auxiliaryLabel1.text = eventWinner ? [NSString stringWithFormat:@"%@ (%@)", self.scheduleEvent.name, self.scheduleEvent.winnerStrokesRelativeToPar] : @"--";
        self.auxiliaryLabel2.text = self.scheduleEvent.winnerEarnings ? self.scheduleEvent.winnerEarnings : @"--";

    } else {
        self.auxiliaryLabel1.text = eventWinner ? [NSString stringWithFormat:@"%@ (%@), %@", self.scheduleEvent.name, self.scheduleEvent.winnerStrokesRelativeToPar, self.scheduleEvent.winnerEarnings] : @"--";
    }
}

- (void)populateFutureEventLabels
{
    self.auxiliaryLabel1.text = [self.scheduleEvent displayStartTime] ? [self.scheduleEvent displayStartTime] : @"--";
    self.auxiliaryLabel2.text = self.scheduleEvent.channelDisplayName ? self.scheduleEvent.channelDisplayName : @"--";
    
    NSTimeInterval twentyFourHours = 60 * 60 * 24;
    if ([self.scheduleEvent.channels count]) {
        for (FSPChannel *channel in self.scheduleEvent.channels) {
            NSInteger channelIndex = [self.scheduleEvent.channels indexOfObject:channel];
            CGFloat dayDetailViewHeight = [FSPPGATourScheduleCell dayDetailViewHeight];
            CGFloat verticalMultiplier = dayDetailViewHeight * (CGFloat)channelIndex;
            FSPScheduleDayDetailView *dayDetailView = [[FSPScheduleDayDetailView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.locationLabel.frame) + kTopMargin + verticalMultiplier, self.frame.size.width, dayDetailViewHeight)];
            
            dayDetailView.timeLabel.text = [channel formattedBroadcastDate];
            dayDetailView.channelLabel.text = channel.callSign;
            dayDetailView.dayCoverageLabel.text = [NSString stringWithFormat:@"Day %i Coverage", channelIndex + 1];
            
            dayDetailView.dayLabel.text = [FSPScheduleEvent dateFormattedForDisplayInSectionHeader:[self.scheduleEvent.startDate dateByAddingTimeInterval:twentyFourHours * channelIndex]];
            [self addSubview:dayDetailView];
        }
    }
}

+ (CGFloat)dayDetailViewHeight
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 28.0;
    } else {
        return 40.0;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    NSString *emptyString = @"";
    self.dateLabel.text = emptyString;
    self.tournamentLabel.text = emptyString;
    self.locationLabel.text = emptyString;
    self.auxiliaryLabel1.text = emptyString;
    self.auxiliaryLabel2.text = emptyString;
    
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[FSPScheduleDayDetailView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (NSString *)startTimeStringFromEvent:(FSPEvent *)event;
{
    NSString *displayString;
    BOOL gameStarted = [event.eventStarted boolValue];
    BOOL gameCompleted = [event.eventCompleted boolValue];
    
    if (gameStarted && !gameCompleted) {
        displayString = @"LIVE NOW";
    } else {
        static NSDateFormatter *formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"hh:mm a";
        });
        displayString = [formatter stringFromDate:event.startDate];
    }
    return displayString;
}

- (NSString *)startDateStringFromEvent:(FSPEvent *)event;
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd";
    });
    
    return [formatter stringFromDate:event.startDate];
}

- (NSString *)prizeMoneyFormat:(NSNumber *)prizeMoneyAmount;
{
    if(!prizeMoneyAmount)
        return @"";

    static NSNumberFormatter *prizeMoneyFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prizeMoneyFormatter = [[NSNumberFormatter alloc] init];
        prizeMoneyFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    NSString *prizeMoneyAmountDisplayString = [prizeMoneyFormatter stringFromNumber:prizeMoneyAmount];
    return [NSString stringWithFormat:@"$%@", prizeMoneyAmountDisplayString];
}

+ (CGFloat)cellHeightForSheduleEvent:(FSPScheduleEvent *)scheduleEvent
{
    NSInteger numberOfChannels = [scheduleEvent.channels count];
    CGFloat baseHeight;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        baseHeight = 32.0 + kTopMargin;
    } else {
        baseHeight = 59.0 + kTopMargin;
    }
    return baseHeight + ([FSPPGATourScheduleCell dayDetailViewHeight] * numberOfChannels);
}

@end
