//
//  FSPNASCARLeaderboardCell.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLeaderboardCell.h"
#import "FSPRacingPlayer.h"

@interface FSPNASCARLeaderboardCell : FSPLeaderboardCell

@property (strong, nonatomic) FSPRacingPlayer *driver;
@property (weak, nonatomic) IBOutlet UILabel *makeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *numberImageView;

@end
