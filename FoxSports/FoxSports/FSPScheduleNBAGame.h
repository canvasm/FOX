//
//  FSPScheduleNBAGame.h
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleGame.h"

@interface FSPScheduleNBAGame : FSPScheduleGame

@property (nonatomic, strong) NSString * highPointsHomePlayerName;
@property (nonatomic, strong) NSNumber * highPointsHomePlayerPoints;

@property (nonatomic, strong) NSString * highPointsAwayPlayerName;
@property (nonatomic, strong) NSNumber * highPointsAwayPlayerPoints;

@end
