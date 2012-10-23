//
//  FSPScheduleRacingEvent.h
//  FoxSports
//
//  Created by greay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleEvent.h"

@interface FSPScheduleRacingEvent : FSPScheduleEvent

@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *winnerName;
@property (nonatomic, strong) NSString *winnerCar;
@property (nonatomic, strong) NSString *poleWinnerName;
@property (nonatomic, strong) NSString *poleWinnerCar;

@end
