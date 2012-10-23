//
//  FSPTennisScheduleCell.m
//  FoxSports
//
//  Created by Matthew Fay on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisScheduleCell.h"
#import "FSPScheduleTennisEvent.h"
#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPGameDetailSectionDrawing.h"

@interface FSPTennisScheduleCell ()
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * locationLabel;
@property (nonatomic, weak) IBOutlet UILabel * surfaceLabel;
@property (nonatomic, weak) IBOutlet UILabel * winnerTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * moneyChannelLabel;
@property (nonatomic, weak) IBOutlet UILabel * timeTVHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel * winnerHeaderLabel;
@end

@implementation FSPTennisScheduleCell
@synthesize dateLabel;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize surfaceLabel;
@synthesize winnerTimeLabel;
@synthesize moneyChannelLabel;
@synthesize timeTVHeaderLabel;
@synthesize winnerHeaderLabel;

+(NSDateFormatter *) scheduleDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"M/d";
    });
    return formatter;
}

+ (CGFloat)heightForEvent:(FSPScheduleEvent *)event;
{
    NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:event.startDate];
    BOOL isFuture = (comparisonResult == NSOrderedAscending);
    BOOL isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    if (isFuture) {
        //TODO: This will need to expand based on how many days they are playing
        if (isPhone)
            return 70;
        else
            return 46;
    } else {
        if (isPhone)
            return 95;
        else
            return 46;
    }
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPTennisScheduleCell" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (void)populateWithEvent:(FSPScheduleTennisEvent *)event
{
    // Figure out if this is a future date or not
    if ([event.endDate fsp_isToday]) {
        self.future = YES;
    } else {
        NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:event.endDate];
        self.future = (comparisonResult == NSOrderedAscending);
    }
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ - %@",
                           [[FSPTennisScheduleCell scheduleDateFormatter] stringFromDate:event.startDate],
                           [[FSPTennisScheduleCell scheduleDateFormatter] stringFromDate:event.endDate]];
    self.nameLabel.text = event.eventTitle;
    self.locationLabel.text = event.location;
    self.surfaceLabel.text = event.surface;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.isFuture) {
            self.winnerTimeLabel.text = [self startDateStringFromEvent:event];
            self.moneyChannelLabel.text = event.channelDisplayName;
        } else {
            self.winnerTimeLabel.text = event.winnerName;
            self.moneyChannelLabel.text = event.winningPrize;
        }
    } else {
        if (self.isFuture) {
            self.timeTVHeaderLabel.hidden = NO;
            self.winnerHeaderLabel.hidden = YES;
            self.winnerTimeLabel.hidden = YES;
        } else {
            self.timeTVHeaderLabel.hidden = YES;
            self.winnerHeaderLabel.hidden = NO;
            self.winnerTimeLabel.hidden = NO;
            self.winnerTimeLabel.text = [NSString stringWithFormat:@"%@   %@", event.winnerName, event.winningPrize];
            self.winnerHeaderLabel.text = @"Winner:";
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    UIColor *shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    for (UILabel *label in self.valueLabels) {
        label.shadowColor = shadowColor;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        FSPDrawGrayWhiteDividerLine(context , CGRectMake(0, 0, rect.size.width, 23));
    }
}

@end
