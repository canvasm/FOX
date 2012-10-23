//
//  FSPTournamentChip.m
//  FoxSports
//
//  Created by Laura Savino on 1/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTournamentChipCell.h"
#import "FSPTournamentEvent.h"
#import "FSPEventChipHeader.h"
#import "FSPLabel.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPTournamentChipCell () {}

@property (nonatomic, weak) IBOutlet FSPLabel *tournamentTitleLabel;
@property (nonatomic, weak) IBOutlet FSPLabel *tournamentSubtitleLabel;
@property (nonatomic, weak) IBOutlet FSPLabel *locationLabel;

@end


@implementation FSPTournamentChipCell

@synthesize tournamentTitleLabel;
@synthesize tournamentSubtitleLabel;
@synthesize locationLabel;

- (void)awakeFromNib
{
    self.tournamentTitleLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.tournamentTitleLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.tournamentTitleLabel.normalFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];
    self.tournamentTitleLabel.highlightedFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];

    self.tournamentSubtitleLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.tournamentSubtitleLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.tournamentSubtitleLabel.normalFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];
    self.tournamentSubtitleLabel.highlightedFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];
    
    self.locationLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.locationLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.locationLabel.normalFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0f];
    self.locationLabel.highlightedFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0f];
}

- (void)populateCellWithEvent:(FSPEvent<FSPTournamentEvent> *)event;
{
    [super populateCellWithEvent:event];
    
    if(![event conformsToProtocol:@protocol(FSPTournamentEvent)])
        return;
    self.tournamentTitleLabel.text = event.tournamentTitle;
    self.tournamentSubtitleLabel.text = event.tournamentSubtitle;
    self.locationLabel.text = event.location;
}

#pragma mark - accessibility
- (NSString *)inProgressAccessibilityLabel;
{
    NSString *videoAvailabilityText = self.isStreamable ? @"Video is available" : @"Video is not available";
    return [NSString stringWithFormat:@"Now playing, %@, %@, at %@. Playing on channel %@. %@.", self.tournamentTitleLabel.text, self.tournamentSubtitleLabel.text, self.locationLabel.text, self.header.networkLabel.text, videoAvailabilityText];
}

- (NSString *)notInProgressAccessibilityLabel;
{
    NSString *videoAvailabilityText = self.isStreamable ? @"Video is available" : @"Video is not available";
    return [NSString stringWithFormat:@"%@, %@, %@, %@ on channel %@. %@.", self.tournamentTitleLabel.accessibilityLabel, self.tournamentSubtitleLabel.accessibilityLabel, self.locationLabel.accessibilityLabel, self.header.gameStateLabel.text, self.header.networkLabel.text, videoAvailabilityText];
}

@end
