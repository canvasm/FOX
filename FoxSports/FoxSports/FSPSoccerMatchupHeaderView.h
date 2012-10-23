//
//  FSPSoccerMatchupHeaderView.h
//  FoxSports
//
//  Created by Matthew Fay on 8/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGameDetailTeamHeader;

@interface FSPSoccerMatchupHeaderView : UIView
@property (nonatomic, weak) IBOutlet FSPGameDetailTeamHeader *teamHeaderAway;
@property (nonatomic, weak) IBOutlet FSPGameDetailTeamHeader *teamHeaderHome;
@end
