//
//  FSPGameEventScheduleHeaderView.m
//  FoxSports
//
//  Created by Laura Savino on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameEventScheduleHeaderViewFuture.h"

@interface FSPGameEventScheduleHeaderViewFuture () {}

@property (nonatomic, strong, readwrite) IBOutlet UILabel *timeLabel;

@end

@implementation FSPGameEventScheduleHeaderViewFuture
@synthesize timeLabel = _timeLabel;

- (void)awakeFromNib
{
    //Display time zone next to 'time' heading for upcoming games
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSString *timeZoneDisplayString = [NSString stringWithFormat:@"TIME %@", [localTimeZone abbreviation]];
    self.timeLabel.text = timeZoneDisplayString;
}

- (NSString *)accessibilityLabel
{
    //Display time zone next to 'time' heading for upcoming games
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSString *label = [NSString stringWithFormat:@"date, opponent, time (%@), tv, calendar", [localTimeZone localizedName:NSTimeZoneNameStyleStandard locale:[NSLocale currentLocale]]];

    return label;
}

@end
