//
//  FSPNFLStatsContainerViewController.h
//  FoxSports
//
//  Created by Joshua Dubey on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPGameDetailContainerViewController.h"

@class FSPGameStatsViewController;
@class FSPNFLTeamStatsViewController;
@class FSPNFLPlayerStatsViewController;

@interface FSPNFLStatsContainerViewController : FSPGameDetailContainerViewController

@property (nonatomic, strong) FSPNFLTeamStatsViewController *teamStatsViewController;
@property (nonatomic, strong) FSPNFLPlayerStatsViewController *playerStatsViewController;

@property (nonatomic, assign, readonly) IBOutlet UIView *lowerContainerView;

@end
