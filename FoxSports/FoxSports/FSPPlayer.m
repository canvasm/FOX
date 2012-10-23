//
//  FSPPlayer.m
//  FoxSports
//
//  Created by Chase Latta on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayer.h"
#import "FSPTeam.h"

NSString * const FSPUpdateStatsException = @"";

@implementation FSPPlayer

@dynamic firstName;
@dynamic lastName;
@dynamic uniqueIdentifier;
@dynamic liveEngineID;
@dynamic photoURL;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    //Must be over written by subclasses
    [NSException raise:FSPUpdateStatsException format:@"The method updateStatsFromDictionary: must be overwritten when inherriting from FSPPlayer"];
}

- (NSString *)abbreviatedName
{
	NSString *playerName;
    if ([self.firstName length] > 0) {
        playerName = [NSString stringWithFormat:@"%@ %@", [self.firstName substringToIndex:1], self.lastName];
    } else {
        playerName = self.lastName;
    }
    return playerName;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
