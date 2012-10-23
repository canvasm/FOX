//
//  FSPUFCFightersAndRoundInfoView.h
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-22.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPUFCPlayer.h"

@interface FSPUFCFightersAndRoundInfoView : UIView

//ROUND INFO
@property (strong, nonatomic) IBOutlet UILabel *roundNumber;
@property (strong, nonatomic) IBOutlet UILabel *roundTimeLeft;
@property (strong, nonatomic) IBOutlet UILabel *currentPositionLabel;

//FIGHTER ONE
@property (strong, nonatomic) FSPUFCPlayer *fighter1;
@property (strong, nonatomic) IBOutlet UILabel *fighterOneName;
@property (strong, nonatomic) IBOutlet UILabel *fighterOneNickName;
@property (strong, nonatomic) IBOutlet UILabel *fighterOneStats;
@property (strong, nonatomic) IBOutlet UIButton *viewFighterOneProfileButton;
@property (strong, nonatomic) IBOutlet UIImageView *fighterOneProfileImage;

//FIGHTER TWO
@property (strong, nonatomic) FSPUFCPlayer *fighter2;
@property (strong, nonatomic) IBOutlet UILabel *fighterTwoName;
@property (strong, nonatomic) IBOutlet UILabel *fighterTwoNickName;
@property (strong, nonatomic) IBOutlet UILabel *fighterTwoStats;
@property (strong, nonatomic) IBOutlet UIButton *viewFighterTwoProfileButton;
@property (strong, nonatomic) IBOutlet UIImageView *fighterTwoProfileImage;

- (void)setFightersInfo:(FSPUFCPlayer *)fighterOne:(FSPUFCPlayer *)fighterTwo;

@end
