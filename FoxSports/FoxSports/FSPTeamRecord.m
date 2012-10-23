//
//  FSPTeamRecord.m
//  FoxSports
//
//  Created by Chase Latta on 2/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamRecord.h"
#import "FSPTeam.h"
#import "NSDictionary+FSPExtensions.h"

NSString * const FSPOverallRecordKey = @"overall";
NSString * const FSPHomeRecordKey = @"home";
NSString * const FSPAwayRecordKey = @"away";
NSString * const FSPConferenceRecordKey = @"conference";
NSString * const FSPDivisionRecordKey = @"division";
NSString * const FSPLastTenRecordKey = @"last10";

NSString * const FSPTeamRecordTypeKey = @"record";
NSString * const FSPTeamRecordWinsKey = @"w";
NSString * const FSPTeamRecordLossesKey = @"l";
NSString * const FSPTeamRecordTiesKey = @"t";

@implementation FSPTeamRecord

@dynamic wins;
@dynamic losses;
@dynamic type;
@dynamic team;
@dynamic ties;

- (void)populateWithDictionary:(NSDictionary *)dict;
{
    NSNumber *zeroNumber = @0;
    self.wins = [dict fsp_objectForKey:FSPTeamRecordWinsKey defaultValue:zeroNumber];
    self.ties = [dict fsp_objectForKey:FSPTeamRecordTiesKey defaultValue:zeroNumber];
    self.losses = [dict fsp_objectForKey:FSPTeamRecordLossesKey defaultValue:zeroNumber];
    self.type = [dict fsp_objectForKey:FSPTeamRecordTypeKey defaultValue:@""];
}

- (NSString *)winLossRecordString
{
    return [NSString stringWithFormat:@"%@-%@", self.wins, self.losses];
}

@end
