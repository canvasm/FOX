//
//  FSPNASCARStandingsCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARStandingsPowerRankingsCell.h"
#import "FSPRacingPlayer.h"

@interface FSPNASCARStandingsPowerRankingsCell ()

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *polesLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *topFiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *topTenLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;


@end

@implementation FSPNASCARStandingsPowerRankingsCell
@synthesize rankLabel;
@synthesize driverNameLabel;
@synthesize pointsLabel;
@synthesize polesLabel;
@synthesize winsLabel;
@synthesize topFiveLabel;
@synthesize topTenLabel;
@synthesize winningsLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)populateWithStats:(FSPRacingSeasonStats *)stats
{
    self.driverNameLabel.text = stats.name;
    self.rankLabel.text = stats.rank.stringValue;
    self.pointsLabel.text = stats.points.stringValue;
    self.polesLabel.text = stats.poles.stringValue;
    self.winsLabel.text = stats.wins.stringValue;
    self.topFiveLabel.text = stats.top5.stringValue;
    self.topTenLabel.text = stats.top10.stringValue;
    self.winningsLabel.text = stats.winnings.stringValue;
    
}


@end
