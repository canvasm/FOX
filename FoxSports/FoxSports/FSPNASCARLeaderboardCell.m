//
//  FSPNASCARLeaderboardCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardCell.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPNASCARLeaderboardCell()

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stLabel;

@end

@implementation FSPNASCARLeaderboardCell

@synthesize pointsLabel = _pointsLabel;
@synthesize statusLabel = _statusLabel;
@synthesize winningsLabel = _winningsLabel;
@synthesize makeLabel = _makeLabel;
@synthesize lapsLabel = _lapsLabel;
@synthesize stLabel = _stLabel;
@synthesize numberImageView = _numberImageView;

- (void)awakeFromNib
{
    
    [super awakeFromNib];
}

- (void)populateWithPlayer:(FSPRacingPlayer *)driver
{
    [super populateWithPlayer:driver];
    
    self.driver = driver;
    self.lapsLabel.text = [driver.laps stringValue];
    self.pointsLabel.text = [NSString stringWithFormat:@"%@/%@", [self.driver.points stringValue], [self.driver.bonus stringValue]];
    self.makeLabel.text = driver.vehicleDescription;
    self.winningsLabel.text = [driver winningsInCurrencyFormat];
    self.positionLabel.text = [driver.positionInRace stringValue];
    self.stLabel.text = [driver.raceStartPosition stringValue];
    self.statusLabel.text = driver.status ? driver.status : @"--";
}

- (void)setLabelFonts
{
    [super setLabelFonts];
    
    UIColor *blueLabelColor = [UIColor fsp_lightBlueColor];
    self.makeLabel.textColor = blueLabelColor;
    self.makeLabel.font = [UIFont fontWithName:FSPClearViewMediumFontName size:13];
}

@end
