//
//  FSPNASCARLeaderboardQualifyingCell.m
//  FoxSports
//
//  Created by Stephen Spring on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardQualifyingCell.h"
#import "FSPRacingPlayer.h"

NSString * const FSPNASCARLeaderboardQualifyingCellIdentifier = @"FSPNASCARLeaderboardQualifyingCellIdentifier";

@interface FSPNASCARLeaderboardQualifyingCell()

@property (strong, nonatomic) FSPRacingPlayer *driver;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end

@implementation FSPNASCARLeaderboardQualifyingCell

@synthesize timeLabel = _timeLabel;
@synthesize speedLabel = _speedLabel;
@synthesize driver = _driver;

- (void)populateWithPlayer:(FSPRacingPlayer *)driver
{
    [super populateWithPlayer:driver];
    
    self.driver = driver;
    self.timeLabel.text = self.driver.qualifyingTime ? self.driver.qualifyingTime : @"0";
    self.speedLabel.text = [self.driver.qualifyingSpeed stringValue];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end
