//
//  FSPUFCFighterPersonalDetailsView.h
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-05.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPUFCPlayer.h"

@interface FSPUFCFighterPersonalDetailsView : UIView

@property (strong, nonatomic) IBOutlet UILabel *fighterName;
@property (strong, nonatomic) IBOutlet UILabel *fighterNickName;
@property (strong, nonatomic) IBOutlet UILabel *fighterStats;
@property (strong, nonatomic) IBOutlet UIButton *viewProfileButton;
@property (strong, nonatomic) IBOutlet UIImageView *fighterProfileImage;

@property (strong, nonatomic) FSPUFCPlayer *currentFighter;

- (void)setFighterInfo:(FSPUFCPlayer *)fighter;

@end