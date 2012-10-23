//
//  FSPNHLStatsContainerViewController.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailContainerViewController.h"

@class FSPGameStatsViewController;
@class FSPNHLPlayerStatsViewController;
@class FSPNHLTeamStatsViewController;

@interface FSPNHLStatsContainerViewController : FSPGameDetailContainerViewController

@property (strong, nonatomic) FSPNHLPlayerStatsViewController *playerStatsViewController;
@property (strong, nonatomic) FSPNHLTeamStatsViewController *teamStatsViewController;
@property (nonatomic, assign, readonly) IBOutlet UIView *lowerContainerView;

@end
