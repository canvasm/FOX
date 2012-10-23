//
//  FSPNFLKickingStatRowCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//


#import "FSPNFLKickingStatRowCell.h"
#import "FSPFootballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNFLKickingStatRowCellReuseIdentifier = @"FSPNFLKickingStatRowCellReuseIdentifier";
NSString * const FSPNFLKickingStatRowCellNibName = @"FSPNFLKickingStatRowCell";

@interface FSPNFLKickingStatRowCell ()

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldGoalsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldGoalPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldGoalLongestLabel;
@property (weak, nonatomic) IBOutlet UILabel *kickingExtraPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldGoalPointsLabel;
@property (nonatomic, strong) FSPFootballPlayer *currentPlayer;
@end

@implementation FSPNFLKickingStatRowCell
@synthesize playerNameLabel;
@synthesize fieldGoalsLabel;
@synthesize fieldGoalPercentageLabel;
@synthesize fieldGoalLongestLabel;
@synthesize kickingExtraPointsLabel;
@synthesize fieldGoalPointsLabel;
@synthesize currentPlayer;


- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNFLKickingStatRowCellNibName bundle:nil];
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
    self.playerNameLabel.textColor = [UIColor whiteColor];
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
    self.fieldGoalsLabel.text = nil;
    self.fieldGoalPercentageLabel.text = nil;
    self.fieldGoalLongestLabel.text = nil;
    self.kickingExtraPointsLabel.text = nil;
    self.fieldGoalPointsLabel.text = nil;
}

- (void)populateWithPlayer:(FSPFootballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
    self.fieldGoalsLabel.text = [NSString stringWithFormat:@"%@/%@", player.fieldGoalsMade, player.fieldGoalAttempts];
    self.fieldGoalPercentageLabel.text = player.fieldGoalPercentage.stringValue;
    self.fieldGoalLongestLabel.text = player.fieldGoalLongestLength.stringValue;
    self.kickingExtraPointsLabel.text = player.kickingExtraPointsMade.stringValue;
    self.fieldGoalPointsLabel.text = player.foxPointsKicking.stringValue;
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
    NSString *fieldGoalsString = [NSString stringWithFormat:@"%@/%@", self.currentPlayer.fieldGoalsMade, self.currentPlayer.fieldGoalAttempts];
    NSString *fieldGoalPercentageString = [NSString stringWithFormat:@"%@", self.currentPlayer.fieldGoalPercentage];
    NSString *fieldGoalLongestString = [NSString stringWithFormat:@"%@", self.currentPlayer.fieldGoalLongestLength];
    NSString *extraPointsString = [NSString stringWithFormat:@"%@", self.currentPlayer.kickingExtraPointsMade];
    NSString *kickingPointsString = [NSString stringWithFormat:@"%@", self.currentPlayer.foxPointsKicking];
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", self.currentPlayer.abbreviatedName, fieldGoalsString, fieldGoalPercentageString, fieldGoalLongestString, extraPointsString, kickingPointsString];
}

@end
