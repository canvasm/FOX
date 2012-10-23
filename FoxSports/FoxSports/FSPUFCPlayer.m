//
//  FSPUFCPlayer.m
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCPlayer.h"
#import "FSPUFCFight.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPUFCPlayer

@dynamic age;
@dynamic draws;
@dynamic fightsOutOf;
@dynamic height;
@dynamic homeTown;
@dynamic losses;
@dynamic reach;
@dynamic weight;
@dynamic wins;
@dynamic nickname;
@dynamic isBeltHolder;

@dynamic strikesAbsorbedPerMinute;
@dynamic strikesLandedPerMinute;
@dynamic strikingAccuracy;
@dynamic strikingDefense;
@dynamic submissionAverage;
@dynamic takedownAccuracy;
@dynamic takedownAverage;
@dynamic takedownDefense;

@dynamic fightAsFighter1;
@dynamic fightAsFighter2;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    NSNumber * noValue = @-1;
    self.firstName = [stats fsp_objectForKey:@"firstName" defaultValue:@""];
    self.lastName = [stats fsp_objectForKey:@"lastName" defaultValue:@""];
    self.nickname = [stats fsp_objectForKey:@"nickName" defaultValue:@""];
    self.isBeltHolder = [stats fsp_objectForKey:@"beltHolder" defaultValue:noValue];
    
    //TODO: remove this once the feed is fixed
    id LEID = [stats fsp_objectForKey:@"nativeId" defaultValue:noValue];
    if ([LEID isKindOfClass:[NSString class]]) {
        self.liveEngineID = @(((NSString*)LEID).intValue);
        self.uniqueIdentifier = LEID;
    } else if ([LEID isKindOfClass:[NSNumber class]]) {
        self.liveEngineID = LEID;
        self.uniqueIdentifier = ((NSNumber *)LEID).stringValue;
    } else 
        NSLog(@"liveEngineIdentifier = %@", LEID);
    
    self.photoURL = [stats fsp_objectForKey:@"photoUrl" defaultValue:@""];
    
    NSDictionary * grappling = [stats fsp_objectForKey:@"grappling" expectedClass:NSDictionary.class];
    if (grappling) {
        self.submissionAverage = [grappling fsp_objectForKey:@"SBAVG" defaultValue:noValue];
        self.takedownAccuracy = [grappling fsp_objectForKey:@"TDACC" defaultValue:noValue];
        self.takedownAverage = [grappling fsp_objectForKey:@"TDAVG" defaultValue:noValue];
        self.takedownDefense = [grappling fsp_objectForKey:@"TDD" defaultValue:noValue];
    }
    
    NSDictionary * striking = [stats fsp_objectForKey:@"striking" expectedClass:NSDictionary.class];
    if (striking) {
        self.strikesAbsorbedPerMinute = [striking fsp_objectForKey:@"SAPM" defaultValue:noValue];
        self.strikesLandedPerMinute = [striking fsp_objectForKey:@"SLPM" defaultValue:noValue];
        self.strikingAccuracy = [striking fsp_objectForKey:@"SA" defaultValue:noValue];
        self.strikingDefense = [striking fsp_objectForKey:@"SD" defaultValue:noValue];
    }
    
    NSDictionary * taleTape = [stats fsp_objectForKey:@"taleTape" expectedClass:NSDictionary.class];
    if (taleTape) {
        self.age = [taleTape fsp_objectForKey:@"age" defaultValue:noValue];
        self.fightsOutOf = [taleTape fsp_objectForKey:@"fightsOutOf" defaultValue:@"--"];
        self.height = [taleTape fsp_objectForKey:@"height" defaultValue:noValue];
        self.homeTown = [taleTape fsp_objectForKey:@"hometown" defaultValue:@"--"];
        self.reach = [taleTape fsp_objectForKey:@"reach" defaultValue:noValue];
        self.weight = [taleTape fsp_objectForKey:@"weight" defaultValue:noValue];
        NSDictionary *record = [taleTape fsp_objectForKey:@"fightRecord" expectedClass:NSDictionary.class];
        if (record) {
            self.draws = [record fsp_objectForKey:@"draws" defaultValue:@0];
            self.losses = [record fsp_objectForKey:@"losses" defaultValue:@0];
            self.wins = [record fsp_objectForKey:@"wins" defaultValue:@0];
        }
    }
}

- (NSString *)getFormattedStats
{
    return [NSString stringWithFormat:@"%@-%@-%@", self.wins, self.losses, self.draws];
}

@end
