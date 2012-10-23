//
//  FSPNFLLeagueScheduleCell.h
//  FoxSports
//
//  Created by Joshua Dubey on 6/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleCell.h"

@interface FSPNFLLeagueScheduleCell : FSPScheduleCell

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, weak, readonly) UIView *gameContentView;
@property (nonatomic, assign) BOOL showDateHeader;

@end
