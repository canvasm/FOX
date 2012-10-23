//
//  FSPGameOddsValidator.m
//  FoxSports
//
//  Created by Laura Savino on 4/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameOddsValidator.h"
#import "FSPGame.h"


@implementation FSPGameOddsValidator

- (NSArray *)validOddsArray: (NSArray *)oddsArray forGame:(FSPGame *)game;
{
    NSMutableArray *validatedArray = [[NSMutableArray alloc] init];

    //Make sure the dictionary is valid and corresponds to one of the game's teams
    NSString *homeTeamUID = game.homeTeamIdentifier;
    NSString *awayTeamUID = game.awayTeamIdentifier;
    for(NSDictionary *oddsDictionary in oddsArray)
    {
        NSDictionary *validatedDictionary = [self validateDictionary:oddsDictionary error:nil];
        if(!validatedDictionary)
            continue;

        NSString *oddsTeamUID = [oddsDictionary objectForKey:@"fsId"];
        if([oddsTeamUID isEqualToString:homeTeamUID] || [oddsTeamUID isEqualToString:awayTeamUID])
            [validatedArray addObject:validatedDictionary];
    }
    if([validatedArray count])
        return [NSArray arrayWithArray:validatedArray];
    else 
        return nil;
}

- (NSSet *)requiredKeys
{
    return [NSSet setWithObjects:@"moneyLine", @"pointSpread", @"psMoneyLine", nil];
}

@end
