//
//  FSPNHLTeamStatsFullStatsHeaderView.h
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGameDetailTeamHeader;

@interface FSPNHLTeamStatsFullStatsHeaderView : UIView

@property (nonatomic, strong) IBOutlet FSPGameDetailTeamHeader *teamAHeader;
@property (nonatomic, strong) IBOutlet FSPGameDetailTeamHeader *teamBHeader;

@end
