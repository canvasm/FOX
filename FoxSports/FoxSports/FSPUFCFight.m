//
//  FSPUFCFight.m
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFight.h"
#import "FSPUFCEvent.h"
#import "FSPUFCPlayer.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPUFCFight

@dynamic decision;
@dynamic time;
@dynamic round;
@dynamic weightClass;
@dynamic fightStatus;
@dynamic event;
@dynamic fighter1;
@dynamic fighter2;
@dynamic ordinal;

- (void)populateWithDictionary:(NSDictionary *)fightDictionary
{
    self.weightClass = [fightDictionary fsp_objectForKey:@"wcTitle" defaultValue:@""];
    self.ordinal = [fightDictionary fsp_objectForKey:@"ordinal" expectedClass:NSNumber.class];

    NSDictionary *fightStatus = [fightDictionary fsp_objectForKey:@"fightStatus" expectedClass:NSDictionary.class];
    if (fightStatus) {
        self.decision = [fightStatus fsp_objectForKey:@"decision" defaultValue:@""];
        self.fightStatus = [fightStatus fsp_objectForKey:@"status" defaultValue:@""];
        self.round = [fightStatus fsp_objectForKey:@"rounds" expectedClass:NSNumber.class];
        self.time = [fightStatus fsp_objectForKey:@"time" defaultValue:@""];
    }
    NSDictionary *fighter1Dict = [fightDictionary objectForKey:@"fighter1"];
    NSDictionary *fighter2Dict = [fightDictionary objectForKey:@"fighter2"];
    
    if (self.fighter1 && fighter1Dict)
        [self.fighter1 updateStatsFromDictionary:fighter1Dict withContext:self.managedObjectContext];
        
    if (self.fighter2 && fighter2Dict)
        [self.fighter2 updateStatsFromDictionary:fighter2Dict withContext:self.managedObjectContext];
}

@end
