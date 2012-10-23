//
//  FSPNASCARStandingsCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARStandingsCell.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPNASCARStandingsCell ()

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *polesLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *topFiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *topTenLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;

@property (nonatomic, strong) NSNumberFormatter *winningsFormatter;

@end

@implementation FSPNASCARStandingsCell
@synthesize rankLabel;
@synthesize driverNameLabel;
@synthesize pointsLabel;
@synthesize polesLabel;
@synthesize winsLabel;
@synthesize topFiveLabel;
@synthesize topTenLabel;
@synthesize winningsLabel;
@synthesize winningsFormatter;

- (void)awakeFromNib
{
	[super awakeFromNib];
    self.driverNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
	self.winningsFormatter = [[NSNumberFormatter alloc] init];
	self.winningsFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	self.winningsFormatter.maximumFractionDigits = 0;
    self.rankLabel.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];
}

- (void)populateWithStats:(FSPRacingSeasonStats *)stats
{
	if ([stats.rank integerValue] > 0) {
		self.rankLabel.text = stats.rank.stringValue;
	} else {
		self.rankLabel.text = nil;
	}
	
	FSPRacingPlayer *racer = [stats.racers anyObject];
	if (racer) {
		self.driverNameLabel.text = racer.abbreviatedName;
	} else {
		self.driverNameLabel.text = stats.racerName;
	}
    self.pointsLabel.text = (stats.points.integerValue > 0) ? stats.points.stringValue : @"--";
    self.polesLabel.text = (stats.poles.integerValue > 0) ? stats.poles.stringValue : @"--";
    self.winsLabel.text = (stats.wins.integerValue > 0) ? stats.wins.stringValue : @"--";
    self.topFiveLabel.text = (stats.top5.integerValue > 0) ? stats.top5.stringValue : @"--";
    self.topTenLabel.text = (stats.top10.integerValue > 0) ? stats.top10.stringValue : @"--";
    self.winningsLabel.text = (stats.winnings.integerValue > 0) ? [self.winningsFormatter stringFromNumber:stats.winnings] : @"--";
    
}


@end
