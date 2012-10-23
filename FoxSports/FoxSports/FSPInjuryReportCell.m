//
//  FSPNBAInjuryReportCell.m
//  FoxSports
//
//  Created by Jason Whitford on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPInjuryReportCell.h"
#import "FSPPlayerInjury.h"
#import "UILabel+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

NSString * const FSPInjuryReportCellIdentifier = @"FSPInjuryReportCell";

@interface FSPInjuryReportCell ()
@property(nonatomic, weak) IBOutlet UIImageView *playerImageView;
@property(nonatomic, weak) IBOutlet UILabel *playerNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *playerInjuryLabel;
@property(nonatomic, weak) IBOutlet UILabel *playerStatusLabel;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *requiredDataLabels;
@end


@implementation FSPInjuryReportCell

@synthesize playerImageView;
@synthesize playerNameLabel, playerInjuryLabel, playerStatusLabel;
@synthesize playerNameLabelHome, playerInjuryLabelHome, playerStatusLabelHome;
@synthesize requiredDataLabels = _requiredDataLabels;


- (void)awakeFromNib
{
    self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.playerNameLabelHome.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    
    self.playerInjuryLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    self.playerInjuryLabelHome.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    self.playerInjuryLabel.textColor = [UIColor fsp_lightBlueColor];
    self.playerInjuryLabelHome.textColor = [UIColor fsp_lightBlueColor];
    
    self.playerStatusLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    self.playerStatusLabelHome.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    self.playerStatusLabel.textColor = [UIColor fsp_lightBlueColor];
    self.playerStatusLabelHome.textColor = [UIColor fsp_lightBlueColor];
}

- (void)populateWithPlayerInjury:(FSPPlayerInjury *)playerInjury;
{
    if(playerInjury.firstName.length && playerInjury.lastName) {
        self.playerNameLabel.text = [NSString stringWithFormat:@"%c %@", [playerInjury.firstName characterAtIndex:0], playerInjury.lastName];
	}

    self.playerInjuryLabel.text = playerInjury.injury;
    self.playerStatusLabel.text = playerInjury.status;

    for(UILabel *label in self.requiredDataLabels) {
        [label fsp_indicateNoData];
	}
}

- (void)populateWithAwayPlayerInjury:(FSPPlayerInjury *)playerInjury homePlayerInjury:(FSPPlayerInjury *)homePlayerInjury;
{
    if(playerInjury.firstName.length && playerInjury.lastName) {
        self.playerNameLabel.text = [NSString stringWithFormat:@"%c %@", [playerInjury.firstName characterAtIndex:0], playerInjury.lastName];
	}
	
    self.playerInjuryLabel.text = playerInjury.injury;
    self.playerStatusLabel.text = playerInjury.status;

	if(homePlayerInjury.firstName.length && homePlayerInjury.lastName) {
        self.playerNameLabelHome.text = [NSString stringWithFormat:@"%c %@", [homePlayerInjury.firstName characterAtIndex:0], homePlayerInjury.lastName];
	}
	
    self.playerInjuryLabelHome.text = homePlayerInjury.injury;
    self.playerStatusLabelHome.text = homePlayerInjury.status;

    for(UILabel *label in self.requiredDataLabels) {
        [label fsp_indicateNoData];
	}
	
}

- (void)prepareForReuse
{
    self.playerNameLabel.text = nil;
    self.playerStatusLabel.text = nil;
    self.playerInjuryLabel.text = nil;
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    return [NSString stringWithFormat:@"%@, %@ with %@", self.playerNameLabel.text, self.playerStatusLabel.text, self.playerInjuryLabel.text];
}

@end
