//
//  FSPNBAStatRowCell.m
//  FoxSports
//
//  Created by Chase Latta on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBAStatRowCell.h"
#import "FSPBasketballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNBAStatRowCellReuseIdentifier = @"FSPNBAStatRowCellReuseIdentifier";
NSString * const FSPNBAStatRowCellNibName = @"FSPNBAStatRowCell";

@interface FSPNBAStatRowCell ()
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldGoalsLabel;
@property (weak, nonatomic) IBOutlet UILabel *threePointLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeThrowsLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensiveReboundsLabel;
@property (weak, nonatomic) IBOutlet UILabel *assistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *blocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *turnoversLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalFoulsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (nonatomic, strong) FSPBasketballPlayer *currentPlayer;
@end

@implementation FSPNBAStatRowCell
@synthesize playerNameLabel;
@synthesize minutesPlayedLabel;
@synthesize fieldGoalsLabel;
@synthesize threePointLabel;
@synthesize freeThrowsLabel;
@synthesize defensiveReboundsLabel;
@synthesize assistsLabel;
@synthesize blocksLabel;
@synthesize turnoversLabel;
@synthesize personalFoulsLabel;
@synthesize pointsLabel;
@synthesize currentPlayer;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNBAStatRowCellNibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

- (void)awakeFromNib
{
    self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    UIColor *color = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.requiredLabels) {
        label.font = font;
        label.textColor = color;
    }
}

- (void)prepareForReuse
{
    self.playerNameLabel.text = nil;
    
    self.minutesPlayedLabel.text = nil;
    self.fieldGoalsLabel.text = nil;
    self.threePointLabel.text = nil;
    self.freeThrowsLabel.text = nil;
    self.defensiveReboundsLabel.text = nil;
    self.assistsLabel.text = nil;
    self.blocksLabel.text = nil;
    self.turnoversLabel.text = nil;
    self.personalFoulsLabel.text = nil;
    self.pointsLabel.text = nil;
}

- (void)populateWithPlayer:(FSPBasketballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
    
    self.minutesPlayedLabel.text = player.minutesPlayed.stringValue;
    self.fieldGoalsLabel.text = [NSString stringWithFormat:@"%@-%@", player.fieldGoalsMade, player.fieldGoalsAttempted];
    self.threePointLabel.text = [NSString stringWithFormat:@"%@-%@", player.threePointsMade, player.threePointsAttempted];
    self.freeThrowsLabel.text = [NSString stringWithFormat:@"%@-%@", player.freeThrowsMade, player.freeThrowsAttempted];
    self.defensiveReboundsLabel.text = player.defensiveRebounds.stringValue;
    self.assistsLabel.text = player.assists.stringValue;
    self.blocksLabel.text = player.blocks.stringValue;
    self.turnoversLabel.text = player.turnovers.stringValue;
    self.personalFoulsLabel.text = player.personalFouls.stringValue;
    self.pointsLabel.text = player.points.stringValue;
    
    self.currentPlayer = player;

    for(UILabel *label in self.requiredLabels)
        [label fsp_indicateNoData];
}

- (void)populateWithTeam:(FSPTeam *)team;
{
    self.playerNameLabel.text = @"Total";
    //TODO: the fsp_indicateNoData method doesn't work here, because the placeholder text from the nib makes it look as though it's populated.
    //We should either make sure that method works everywhere or not use it.
    for(UILabel *label in self.requiredLabels)
        label.text = @"--";
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *defensiveReboundString = [NSString stringWithFormat:@"%@ defensive %@", self.currentPlayer.defensiveRebounds, [self.currentPlayer.defensiveRebounds integerValue] == 1 ? @"rebound" : @"rebounds"];
    NSString *assistString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.assists, [self.currentPlayer.assists integerValue] == 1 ? @"assist" : @"assists"];
    NSString *stealsString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.steals, [self.currentPlayer.steals integerValue] == 1 ? @"steal" : @"steals"];
    NSString *blockString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.blocks, [self.currentPlayer.blocks integerValue] == 1 ? @"block" : @"blocks"];
    NSString *turnoverString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.turnovers, [self.currentPlayer.turnovers integerValue] == 1 ? @"turnover" : @"turnovers"];
    NSString *pfString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.personalFouls, [self.currentPlayer.personalFouls integerValue] == 1 ? @"personal foul" : @"personal fouls"];
    NSString *pointsString = [NSString stringWithFormat:@"%@ %@", self.currentPlayer.points, [self.currentPlayer.points integerValue] == 1 ? @"point" : @"points"];
    //5 points
    return [NSString stringWithFormat:@"%@, %@ minutes played, %@ of %@ field goals, %@ of %@ three pointers, %@ of %@ free throws, %@, %@, %@, %@, %@, %@, %@ plus minus, %@", [self.currentPlayer abbreviatedName], self.currentPlayer.minutesPlayed, self.currentPlayer.fieldGoalsMade, self.currentPlayer.fieldGoalsAttempted, self.currentPlayer.threePointsMade, self.currentPlayer.threePointsAttempted, self.currentPlayer.freeThrowsMade, self.currentPlayer.freeThrowsAttempted, defensiveReboundString, assistString, stealsString, blockString, turnoverString, pfString, self.currentPlayer.plusMinus, pointsString];
}
@end
