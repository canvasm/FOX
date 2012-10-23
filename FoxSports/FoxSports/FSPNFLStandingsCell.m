//
//  FSPNFLStandingsCell.m
//  FoxSports
//
//  Created by Laura Savino on 4/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLStandingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"

@interface FSPNFLStandingsCell () {}

@property (weak, nonatomic) IBOutlet UILabel *pointsForLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsAgainstLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiesLabel;

@end

@implementation FSPNFLStandingsCell

@synthesize pointsForLabel;
@synthesize pointsAgainstLabel;
@synthesize tiesLabel;

- (void)populateWithTeam:(FSPTeam *)team
{
    [super populateWithTeam:team];
    self.pointsForLabel.text = team.pointsFor;
    self.pointsAgainstLabel.text = team.pointsAgainst;
    self.tiesLabel.text = [team.overallRecord.ties stringValue];
}

@end
