//
//  FSPHockeyGameStatCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPHockeyGameStatCell.h"
#import "FSPHockeyPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

NSString * const FSPHockeyPlayerStatCellReuseIdentifier = @"FSPHockeyPlayerStatCellReuseIdentifier";

@interface FSPHockeyGameStatCell()

@property (nonatomic) FSPHockeyGameStatCellType cellType;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalsLabel;
@property (weak, nonatomic) IBOutlet UILabel *assistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusMinusLabel;
@property (weak, nonatomic) IBOutlet UILabel *shotsOnGoalLabel;
@property (weak, nonatomic) IBOutlet UILabel *hitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockedShotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *penaltiesInMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shiftsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeOnIceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalsAllowedLabel;
@property (weak, nonatomic) IBOutlet UILabel *savesLabel;
@property (weak, nonatomic) IBOutlet UILabel *savePercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *shotsAllowedLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statValueLabels;

@end

@implementation FSPHockeyGameStatCell
@synthesize nameLabel;
@synthesize goalsLabel;
@synthesize assistsLabel;
@synthesize plusMinusLabel;
@synthesize shotsOnGoalLabel;
@synthesize hitsLabel;
@synthesize blockedShotsLabel;
@synthesize penaltiesInMinutesLabel;
@synthesize shiftsLabel;
@synthesize timeOnIceLabel;
@synthesize goalsAllowedLabel;
@synthesize savesLabel;
@synthesize savePercentageLabel;
@synthesize shotsAllowedLabel;
@synthesize statValueLabels;
@synthesize cellType;

- (id)initWithType:(FSPHockeyGameStatCellType)type
{
    UINib *nib;
    switch (type) {
        case FSPHockeyGameStatCellTypeSkater:
            nib = [UINib nibWithNibName:@"FSPHockeyGameSkaterStatCell" bundle:nil];
            break;
        case FSPHockeyGameStatCellTypeGoaltender:
            nib = [UINib nibWithNibName:@"FSPHockeyGameGoaltenderStatCell" bundle:nil];
            break;
    }
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    
    if (self) {
        cellType = type;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self styleLabels];
}

- (void)populateWithPlayer:(FSPHockeyPlayer *)player
{
    NSString *noValue = @"--";
    self.nameLabel.text = [player abbreviatedName] ? [player abbreviatedName] : noValue;
    self.penaltiesInMinutesLabel.text = [player.penaltyMinutes stringValue] ? [player.penaltyMinutes stringValue] : noValue;
    self.shiftsLabel.text = [player.shifts stringValue] ? [player.shifts stringValue] : noValue;
    self.timeOnIceLabel.text = [player timeOnIce] ? [player timeOnIce] : noValue;
    
    switch (self.cellType) {
        case FSPHockeyGameStatCellTypeSkater:
            self.goalsLabel.text = [player.goalsScored stringValue] ? [player.goalsScored stringValue] : noValue;
            self.assistsLabel.text = [player.assists stringValue] ? [player.assists stringValue] : noValue;
            self.plusMinusLabel.text = [player.plusMinus stringValue] ? [player.plusMinus stringValue] : noValue;
            self.shotsOnGoalLabel.text = [player.shotsOnGoal stringValue] ? [player.shotsOnGoal stringValue] : noValue;
            self.hitsLabel.text = [player.hits stringValue] ? [player.hits stringValue] : noValue;
            self.blockedShotsLabel.text = [player.blockedShots stringValue] ? [player.blockedShots stringValue] : noValue;
            break;
        case FSPHockeyGameStatCellTypeGoaltender:
            self.shotsAllowedLabel.text = [player.totalShotsOnGoal stringValue] ? [player.totalShotsOnGoal stringValue] : noValue;
            self.goalsAllowedLabel.text = [player.goalsAllowed stringValue] ? [player.goalsAllowed stringValue] : noValue;
            self.savesLabel.text = [player.saves stringValue] ? [player.saves stringValue] : noValue;
            self.savePercentageLabel.text = [player.savePercentage stringValue] ? [player.savePercentage stringValue] : noValue;
            break;
    }
}

- (void)styleLabels
{
    self.nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
    self.nameLabel.textColor = [UIColor whiteColor];
    for (UILabel *label in self.statValueLabels) {
        label.font = [UIFont fontWithName:FSPClearViewBoldFontName size:14];
        label.textColor = [UIColor fsp_lightBlueColor];
    }
}

@end
