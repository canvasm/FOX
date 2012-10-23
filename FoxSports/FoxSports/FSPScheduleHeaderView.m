//
//  FSPScheduleHeaderView.m
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleHeaderView.h"
#import "FSPGameDetailSectionDrawing.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

CGFloat const FSPLeagueScheduleHeaderHeight = 60.0;

@interface FSPScheduleHeaderView ()

@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnOneLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnTwoLabel;
@property (nonatomic, retain, readwrite) IBOutlet UILabel *columnThreeLabel;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, copy) NSDate *sectionDate;
/**
 * The dark bar at the top of each section, containing the date label.
 */
@property (nonatomic, strong) FSPStandingsScheduleSectionHeader *topBarView;

@end


@implementation FSPScheduleHeaderView

@synthesize columnOneLabel = _columnOneLabel;
@synthesize columnTwoLabel = _columnTwoLabel;
@synthesize columnThreeLabel = _columnThreeLabel;
@synthesize topBarView = _topBarView;
@synthesize sectionDate = _sectionDate;
@synthesize future = _future;
@synthesize labels = _labels;
@synthesize event = _event;

+(NSDateFormatter *) scheduleHeaderViewDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE M/d/yy";
    });
    return formatter;
}

+ (CGFloat)headerHeght
{
    return 60;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIColor *color = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];
    for (UILabel *label in self.labels) {
        label.font = font;
        label.textColor = color;
    }

    CGRect topBarFrame = CGRectMake(0.0, 0.0, self.frame.size.width, 30.0);
    self.topBarView = [[FSPStandingsScheduleSectionHeader alloc] initWithFrame:topBarFrame];
    [self addSubview:self.topBarView];
    self.backgroundColor = [UIColor fsp_colorWithIntegralRed:242 green:242 blue:242 alpha:1.0];
}

- (void)drawRect:(CGRect)rect
{
    UIColor *shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    for (UILabel *label in self.labels) {
        label.shadowColor = shadowColor;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    FSPDrawGrayWhiteDividerLine(context , rect);
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    if (_event != event) {
        _event = event;
        [self setSectionDate:event.normalizedStartDate];
    }
}

- (void)setSectionDate:(NSDate *)date;
{
    if (_sectionDate != date) {
        _sectionDate = [date copy];
        
        self.topBarView.sectionTitleLabel.text = [[FSPScheduleHeaderView scheduleHeaderViewDateFormatter] stringFromDate:date];
        self.topBarView.accessibilityLabel = [date fsp_accessibleDateString];
        
        if ([date fsp_isToday]) {
            self.future = YES;
        } else {
            NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:date];
            self.future = (comparisonResult == NSOrderedAscending);
        }
    }

	self.columnOneLabel.hidden = NO;
	self.columnTwoLabel.hidden = NO;
	self.columnThreeLabel.hidden = NO;

	if (self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.columnOneLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]]; 
			self.columnTwoLabel.text = @"TV";
		} else {
			self.columnOneLabel.hidden = YES;
			self.columnTwoLabel.text = @"Time/TV";
		}
		
		self.columnThreeLabel.text = @"Calendar";
	}
}

- (NSString *)formattedSeasonType
{
    if ([self.event.seasonType isEqualToString:@"REGULAR_SEASON"]) {
        return @"Regular Season";
    }
    else if ([self.event.seasonType isEqualToString:@"POST_SEASON"]) {
        return @"Post Season";
    }
    else if ([self.event.seasonType isEqualToString:@"PRE_SEASON"]) {
        return @"Pre Season";
    }
	else if ([self.event.seasonType isEqualToString:@"SPRINT_CUP_SERIES"]) {
		return @"Sprint Cup";
	}
	else if ([self.event.seasonType isEqualToString:@"NATIONWIDE_SERIES"]) {
		return @"Nationwide Series";
	}
	else if ([self.event.seasonType isEqualToString:@"CAMPING_WORLD_TRUCK_SERIES"]) {
		return @"Camping World Truck Series";
    } else {
        return @"";
    }
}


@end
