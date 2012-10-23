//
//  FSPTeamScheduleCell.m
//  FoxSports
//
//  Created by greay on 6/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleCell.h"

@implementation FSPTeamScheduleCell
@synthesize team;

- (NSString *)lastNameFromFullName:(NSString *)fullName
{
    NSArray *names = [fullName componentsSeparatedByString:@" "];
    return names.count > 1 ? [names objectAtIndex:1] : [names objectAtIndex:0];
}

@end
