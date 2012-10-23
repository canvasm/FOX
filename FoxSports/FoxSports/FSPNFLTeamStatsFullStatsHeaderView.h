//
//  FSPNFLTeamStatsFullStatsHeaderView.h
//  FoxSports
//
//  Created by Ed McKenzie on 7/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGameDetailTeamHeader;

@interface FSPNFLTeamStatsFullStatsHeaderView : UIView

@property (nonatomic, strong) IBOutlet FSPGameDetailTeamHeader *teamAHeader;
@property (nonatomic, strong) IBOutlet FSPGameDetailTeamHeader *teamBHeader;

@end
