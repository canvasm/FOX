//
//  FSPTeamScheduleHeaderView.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleHeaderView.h"

@implementation FSPTeamScheduleHeaderView

+ (NSDateFormatter *)teamScheduleYearDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy";
    });
    return formatter;
}

@end
