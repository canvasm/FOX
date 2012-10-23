//
//  FSPNFLTeamScheduleHeaderView.h
//  FoxSports
//
//  Created by Joshua Dubey on 6/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleHeaderView.h"

@interface FSPNFLTeamScheduleHeaderView : FSPTeamScheduleHeaderView

@property (nonatomic, retain, readonly) IBOutlet UILabel *columnFourLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnFiveLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnSixLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnSevenLabel;

@end
