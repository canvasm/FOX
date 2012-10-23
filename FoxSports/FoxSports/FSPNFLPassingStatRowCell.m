//
//  FSPNFLPassingStatRowCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//


#import "FSPNFLPassingStatRowCell.h"
#import "FSPFootballPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPNFLPassingStatRowCellReuseIdentifier = @"FSPNFLPassingStatRowCellReuseIdentifier";
NSString * const FSPNFLPassingStatRowCellNibName = @"FSPNFLPassingStatRowCell";

@interface FSPNFLPassingStatRowCell ()


@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *completionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yardsLabel;
@property (weak, nonatomic) IBOutlet UILabel *passingAverageLabel;
@property (weak, nonatomic) IBOutlet UILabel *touchdownsLabel;
@property (weak, nonatomic) IBOutlet UILabel *interceptionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fumblesLabel;
@property (nonatomic, strong) FSPFootballPlayer *currentPlayer;
@end

@implementation FSPNFLPassingStatRowCell
@synthesize playerNameLabel;
@synthesize completionsLabel;
@synthesize yardsLabel;
@synthesize passingAverageLabel;
@synthesize touchdownsLabel;
@synthesize interceptionsLabel;
@synthesize fumblesLabel;
@synthesize currentPlayer;


- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPNFLPassingStatRowCellNibName bundle:nil];
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
    self.completionsLabel = nil;
    self.yardsLabel = nil;
    self.passingAverageLabel = nil;
    self.touchdownsLabel = nil;
    self.interceptionsLabel = nil;
    self.fumblesLabel = nil;
}

- (void)populateWithPlayer:(FSPFootballPlayer *)player;
{
    self.playerNameLabel.text = [player abbreviatedName];
    self.completionsLabel.text = [NSString stringWithFormat:@"%@/%@", player.passingCompletions, player.passingAttempts];
    self.yardsLabel.text = player.passingYards.stringValue;
    self.passingAverageLabel.text = player.passingAverage.stringValue;
    self.touchdownsLabel.text = player.passingTouchdowns.stringValue;
    self.interceptionsLabel.text = player.passingInterceptions.stringValue;
    self.fumblesLabel.text = player.fumblesLost.stringValue;
    self.currentPlayer = player;
    
    for(UILabel *label in self.requiredLabels)
        [label fsp_indicateNoData];
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *completionsString = [NSString stringWithFormat:@"%@/%@", self.currentPlayer.passingCompletions, self.currentPlayer.passingAttempts];
    NSString *passingYardsString = [NSString stringWithFormat:@"%@", self.currentPlayer.passingYards];
    NSString *passingAverageString = [NSString stringWithFormat:@"%@", self.currentPlayer.passingAverage];
    NSString *touchdownsString = [NSString stringWithFormat:@"%@", self.currentPlayer.passingTouchdowns];
    NSString *interceptionsString = [NSString stringWithFormat:@"%@", self.currentPlayer.passingInterceptions];
    NSString *fumblesString = [NSString stringWithFormat:@"%@", self.currentPlayer.fumblesLost];
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@", self.currentPlayer.abbreviatedName, completionsString, passingYardsString, passingAverageString,touchdownsString, interceptionsString, fumblesString];
}

@end
