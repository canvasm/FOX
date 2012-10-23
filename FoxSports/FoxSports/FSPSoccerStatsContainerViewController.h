//
//  FSPSoccerStatsContainerViewController.h
//  FoxSports
//
//  Created by Ryan McPherson on 7/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPGameDetailContainerViewController.h"

@class FSPGameStatsViewController;
@class FSPSoccerMatchStatsViewController;
@class FSPSoccerPlayerStatsViewController;

@interface FSPSoccerStatsContainerViewController : FSPGameDetailContainerViewController

@property (nonatomic, strong) FSPSoccerMatchStatsViewController *matchStatsViewController;
@property (nonatomic, strong) FSPSoccerPlayerStatsViewController *playerStatsViewController;

@property (nonatomic, assign, readonly) IBOutlet UIView *lowerContainerView;

@end
