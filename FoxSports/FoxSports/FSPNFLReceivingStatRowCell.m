//
//  FSPNFLReceivingStatRowCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//


#import "FSPNFLReceivingStatRowCell.h"
#import "FSPFootballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNFLReceivingStatRowCellReuseIdentifier = @"FSPNFLReceivingStatRowCellReuseIdentifier";
NSString * const FSPNFLReceivingStatRowCellNibName = @"FSPNFLReceivingStatRowCell";

@interface FSPNFLReceivingStatRowCell ()

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *receptionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *receptionYardsLabel;
@property (weak, nonatomic) IBOutlet UILabel *receptionAverageLabel;
@property (weak, nonatomic) IBOutlet UILabel *receptionTouchdownsLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivingLongestLabel;
@property (weak, nonatomic) IBOutlet UILabel *fumblesLostLabel;
@property (nonatomic, strong) FSPFootballPlayer *currentPlayer;
@end

@implementation FSPNFLReceivingStatRowCell
@synthesize playerNameLabel;
@synthesize receptionsLabel;
@synthesize receptionYardsLabel;
@synthesize receptionAverageLabel;
@synthesize receptionTouchdownsLabel;
@synthesize receivingLongestLabel;
@synthesize fumblesLostLabel;
@synthesize currentPlayer;


- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNFLReceivingStatRowCellNibName bundle:nil];
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
    self.receptionsLabel.text = nil;
    self.receptionYardsLabel.text = nil;
    self.receptionAverageLabel.text = nil;
    self.receptionTouchdownsLabel.text = nil;
    self.receivingLongestLabel.text = nil;
    self.fumblesLostLabel.text = nil;
}

- (void)populateWithPlayer:(FSPFootballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
    self.receptionsLabel.text = player.receptions.stringValue;
    self.receptionYardsLabel.text = player.receptionYards.stringValue;
    self.receptionAverageLabel.text = player.receptionAverage.stringValue;
    self.receptionTouchdownsLabel.text = player.receptionTouchdowns.stringValue;
    self.receivingLongestLabel.text = player.receptionLongestLength.stringValue;
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
    NSString *receptionsString = [NSString stringWithFormat:@"%@", self.currentPlayer.receptions];
    NSString *receptionYardsString = [NSString stringWithFormat:@"%@", self.currentPlayer.receptionYards];
    NSString *receptionAverageString = [NSString stringWithFormat:@"%@", self.currentPlayer.receptionAverage];
    NSString *touchdownsString = [NSString stringWithFormat:@"%@", self.currentPlayer.receptionTouchdowns];
    NSString *receptionLongestString = [NSString stringWithFormat:@"%@", self.currentPlayer.receptionLongestLength];
    NSString *fumblesString = [NSString stringWithFormat:@"%@", self.currentPlayer.fumblesLost];
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@", self.currentPlayer.abbreviatedName, receptionsString, receptionYardsString, receptionAverageString,touchdownsString, receptionLongestString, fumblesString];
}

@end
