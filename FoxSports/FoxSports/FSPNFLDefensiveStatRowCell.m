//
//  FSPNFLDefensiveStatRowCell.m
//  FoxSports
//
//  Created by greay on 9/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLDefensiveStatRowCell.h"
#import "FSPFootballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNFLDefensiveStatRowCellReuseIdentifier = @"FSPNFLDefensiveStatRowCellReuseIdentifier";
NSString * const FSPNFLDefensiveStatRowCellNibName = @"FSPNFLDefensiveStatRowCell";

@interface FSPNFLDefensiveStatRowCell ()

@property (nonatomic, strong) FSPFootballPlayer *currentPlayer;

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tacklesLabel;
@property (weak, nonatomic) IBOutlet UILabel *assistLabel;
@property (weak, nonatomic) IBOutlet UILabel *sacksLabel;
@property (weak, nonatomic) IBOutlet UILabel *passDefendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *forceFumbleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fumbleRecoveryLabel;
@property (weak, nonatomic) IBOutlet UILabel *touchdownsLabel;

@end

@implementation FSPNFLDefensiveStatRowCell

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNFLDefensiveStatRowCellNibName bundle:nil];
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
	self.tacklesLabel.text = nil;
	self.assistLabel.text = nil;
	self.sacksLabel.text = nil;
	self.passDefendedLabel.text = nil;
	self.forceFumbleLabel.text = nil;
	self.fumbleRecoveryLabel.text = nil;
	self.touchdownsLabel.text = nil;
}

- (void)populateWithPlayer:(FSPFootballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
	self.tacklesLabel.text = [player.defensiveTackles stringValue];
	self.assistLabel.text = [player.assistedTackles stringValue];
	self.sacksLabel.text = [player.defensiveSacks stringValue];
	self.passDefendedLabel.text = [player.defendedPasses stringValue];
	self.forceFumbleLabel.text = [player.defensiveForcedFumbles stringValue];
	self.fumbleRecoveryLabel.text = [player.fumblesRecovered stringValue];
    self.touchdownsLabel.text = [player.totalTouchdowns stringValue];
	
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
	return nil;
}

@end
