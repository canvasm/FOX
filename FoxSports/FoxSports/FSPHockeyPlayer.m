//
//  FSPHockeyPlayer.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/3/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPHockeyPlayer.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPHockeyPlayer

@dynamic goalsScored;
@dynamic assists;
@dynamic plusMinus;
@dynamic shotsOnGoal;
@dynamic hits;
@dynamic blockedShots;
@dynamic penaltyMinutes;
@dynamic shifts;
@dynamic timeOnIceMins;
@dynamic timeOnIceSecs;
@dynamic totalShotsOnGoal;
@dynamic goalsAllowed;
@dynamic saves;
@dynamic savePercentage;
@dynamic star;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    NSNumber * noValue = @0;
    
    self.goalsScored = [stats fsp_objectForKey:@"GS" defaultValue:noValue];
    self.assists = [stats fsp_objectForKey:@"A" defaultValue:noValue];
    self.plusMinus = [stats fsp_objectForKey:@"PM" defaultValue:noValue];
    self.shotsOnGoal = [stats fsp_objectForKey:@"SOG" defaultValue:noValue];
    self.hits = [stats fsp_objectForKey:@"H" defaultValue:noValue];
    self.blockedShots = [stats fsp_objectForKey:@"BL" defaultValue:noValue];
    self.penaltyMinutes = [stats fsp_objectForKey:@"PIM" defaultValue:noValue];
    self.shifts = [stats fsp_objectForKey:@"SHFT" defaultValue:noValue];
    self.timeOnIceMins= [stats fsp_objectForKey:@"TOIM" defaultValue:noValue];
    self.timeOnIceSecs = [stats fsp_objectForKey:@"TOIS" defaultValue:noValue];
    self.star = [stats fsp_objectForKey:@"STAR" defaultValue:noValue];
    
    //Goalie Stats
    self.totalShotsOnGoal = [stats fsp_objectForKey:@"FSH" defaultValue:noValue];
    self.goalsAllowed = [stats fsp_objectForKey:@"GA" defaultValue:noValue];
    self.saves = [stats fsp_objectForKey:@"SV" defaultValue:noValue];
    self.savePercentage = [stats fsp_objectForKey:@"SVP" defaultValue:noValue];
}

- (NSString *)timeOnIce
{
    unsigned unitFlags = NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:currentDate];
    [dateComponents setMinute:[self.timeOnIceMins integerValue]];
    [dateComponents setSecond:[self.timeOnIceSecs integerValue]];
    NSDate *timeOnIceDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter stringFromDate:timeOnIceDate];
    [dateFormatter setDateFormat:@"mm:ss"];
    return [dateFormatter stringFromDate:timeOnIceDate];
}

@end
