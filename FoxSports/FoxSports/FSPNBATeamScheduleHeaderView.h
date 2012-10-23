//
//  FSPNBATeamScheduleHeaderView.h
//  FoxSports
//
//  Created by Joshua Dubey on 6/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleHeaderView.h"
#import "FSPTeamScheduleHeaderView.h"

@interface FSPNBATeamScheduleHeaderView : FSPTeamScheduleHeaderView

@property (nonatomic, retain, readonly) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnFiveLabel;
@end
