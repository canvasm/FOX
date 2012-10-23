//
//  FSPNFLRushingStatRowCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//


#import "FSPNFLRushingStatRowCell.h"
#import "FSPFootballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNFLRushingStatRowCellReuseIdentifier = @"FSPNFLRushingStatRowCellReuseIdentifier";
NSString * const FSPNFLRushingStatRowCellNibName = @"FSPNFLRushingStatRowCell";

@interface FSPNFLRushingStatRowCell ()

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rushingAttemptsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rushingYardsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rushingAverageLabel;
@property (weak, nonatomic) IBOutlet UILabel *rushingTouchdownsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rushingLongestLabel;
@property (weak, nonatomic) IBOutlet UILabel *fumblesLostLabel;
@property (nonatomic, strong) FSPFootballPlayer *currentPlayer;
@end

@implementation FSPNFLRushingStatRowCell
@synthesize playerNameLabel;
@synthesize rushingAttemptsLabel;
@synthesize rushingYardsLabel;
@synthesize rushingAverageLabel;
@synthesize rushingTouchdownsLabel;
@synthesize rushingLongestLabel;
@synthesize fumblesLostLabel;
@synthesize currentPlayer;


- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNFLRushingStatRowCellNibName bundle:nil];
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
    self.rushingAttemptsLabel.text = nil;
    self.rushingYardsLabel.text = nil;
    self.rushingAverageLabel.text = nil;
    self.rushingTouchdownsLabel.text = nil;
    self.rushingLongestLabel.text = nil;
    self.fumblesLostLabel.text = nil;
}

- (void)populateWithPlayer:(FSPFootballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
    self.rushingAttemptsLabel.text = player.rusingAttempts.stringValue;
    self.rushingYardsLabel.text = player.rushingYards.stringValue;
    self.rushingAverageLabel.text = player.rushingAverage.stringValue;
    self.rushingTouchdownsLabel.text = player.rushingTouchdowns.stringValue;
    self.rushingLongestLabel.text = player.rushingLongestLength.stringValue;
    self.fumblesLostLabel.text = player.fumblesLost.stringValue;
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
    NSString *rushingString = [NSString stringWithFormat:@"%@", self.currentPlayer.rusingAttempts];
    NSString *rushingYardsString = [NSString stringWithFormat:@"%@", self.currentPlayer.rushingYards];
    NSString *rushingAverageString = [NSString stringWithFormat:@"%@", self.currentPlayer.rushingAverage];
    NSString *touchdownsString = [NSString stringWithFormat:@"%@", self.currentPlayer.rushingTouchdowns];
    NSString *rushingLongestString = [NSString stringWithFormat:@"%@", self.currentPlayer.rushingLongestLength];
    NSString *fumblesString = [NSString stringWithFormat:@"%@", self.currentPlayer.fumblesLost];
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@", self.currentPlayer.abbreviatedName, rushingString, rushingYardsString, rushingAverageString,touchdownsString, rushingLongestString, fumblesString];
}

@end
