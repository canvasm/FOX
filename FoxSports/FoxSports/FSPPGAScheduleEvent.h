//
//  FSPPGAScheduleEvent.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleEvent.h"

@interface FSPPGAScheduleEvent : FSPScheduleEvent

/*!
 @abstract The evnt winner's final amount of strokes under, or over par.
 */
@property (strong, nonatomic) NSString *winnerStrokesRelativeToPar;

/*!
 @abstract The event winner earnings amount.
 */
@property (strong, nonatomic) NSString *winnerEarnings;

@end
