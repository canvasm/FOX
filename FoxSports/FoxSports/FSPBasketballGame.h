//
//  FSPBasketballGame.h
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGame.h"


@interface FSPBasketballGame : FSPGame

@property (nonatomic, retain) NSString * highPointsLosing;
@property (nonatomic, retain) NSString * highPointsLosingPlayerName;
@property (nonatomic, retain) NSString * highPointsWinning;
@property (nonatomic, retain) NSString * highPointsWinningPlayerName;
@property (nonatomic, retain) NSString * highRebounds;
@property (nonatomic, retain) NSString * highReboundsPlayerName;


- (void)populateWithDictionary:(NSDictionary *)eventData;

@end
