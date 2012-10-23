//
//  FSPScheduleNBAGame.m
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleNBAGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleNBAGame

@synthesize highPointsAwayPlayerName;
@synthesize highPointsHomePlayerName;
@synthesize highPointsHomePlayerPoints;
@synthesize highPointsAwayPlayerPoints;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
    
    NSArray * stats = [dictionary objectForKey:@"stats"];
    for (NSDictionary * d in stats) {
        if ([@"PTS" isEqualToString:[d objectForKey:@"stat"]]) {
            if ([@"h" isEqualToString:[d objectForKey:@"team"]]) {
                self.highPointsHomePlayerName = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.highPointsHomePlayerPoints = [d objectForKey:@"value"];
            } else {
                self.highPointsAwayPlayerName = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.highPointsAwayPlayerPoints = [d objectForKey:@"value"];
            }
        }
    }
}

@end
