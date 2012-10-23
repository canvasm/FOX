//
//  FSPNBATopPlayersView.h
//  FoxSports
//
//  Created by Laura Savino on 3/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPGameTopPlayersViewContainer.h"

@class FSPBasketballPlayer;
@class FSPGameTopPlayerView;

@interface FSPNBATopPlayersViewContainer : FSPGameTopPlayersViewContainer

@property (nonatomic, strong) FSPBasketballPlayer *topPointsPlayer;
@property (nonatomic, strong) FSPBasketballPlayer *topReboundsPlayer;
@property (nonatomic, strong) FSPBasketballPlayer *topAssistsPlayer;

/**
 * Views containing details about players; to be made private and populated another way
 */
@property (weak, nonatomic) IBOutlet FSPGameTopPlayerView *topPointsPlayerView;
@property (weak, nonatomic) IBOutlet FSPGameTopPlayerView *topReboundsPlayerView;
@property (weak, nonatomic) IBOutlet FSPGameTopPlayerView *topAssistsPlayerView;

@end
