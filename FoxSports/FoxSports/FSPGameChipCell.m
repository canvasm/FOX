//
//  FSPGameChip.m
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameChipCell.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPFootballGame.h"
#import "FSPBaseballGame.h"
#import "FSPEventChipHeader.h"
#import "FSPFieldPositionView.h"
#import "FSPBaseballChipIndicatorView.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPTeamRanking.h"

enum {
    FSPGameChipGame = 0,
    FSPGameChipFootballGame,
    FSPGameChipBaseballGame
};
typedef NSInteger FSPGameChipGameType;

static CGFloat teamWidths[] = {164.0, 214.0};
static CGFloat scorePaddings[] = {70.0, 12.0};


@interface FSPGameChipCell ()
// Home team
@property (nonatomic, weak) IBOutlet FSPLabel *homeTeamLabel;
@property (nonatomic, weak) IBOutlet FSPLabel *homeTeamScoreLabel;
@property (nonatomic, weak) IBOutlet UIImageView *homeTeamPossessionView;

// Away Team
@property (nonatomic, weak) IBOutlet FSPLabel *awayTeamLabel;
@property (nonatomic, weak) IBOutlet FSPLabel *awayTeamScoreLabel;
@property (nonatomic, weak) IBOutlet UIImageView *awayTeamPossessionView;

@property (nonatomic, weak) IBOutlet FSPFieldPositionView *fieldPositionIndicator;
@property (nonatomic, weak) IBOutlet FSPBaseballChipIndicatorView *baseballView;

@property (nonatomic) FSPGameChipGameType gameType;

- (void)updateFootballInformationWithGame:(FSPFootballGame *)game;
- (void)updateBaseballInformationWithGame:(FSPBaseballGame *)game;

- (NSString *)footballAccessibilityLabel;
- (NSString *)baseballAccessibilityLabel;
- (NSString *)regularInProgressGameAccessibilityLabel;
- (NSString *)regularNotInProgressGameAccessibilityLabel;

- (void)setLabel:(UILabel *)label originX:(CGFloat)x;
- (void)setLabel:(UILabel *)label originXOffsetFromLabel:(UILabel *)offsetLabel amount:(CGFloat)amount;
- (void)setLabel:(UILabel *)label width:(CGFloat)width;

- (void)updatePossessionArrows;
@end

@implementation FSPGameChipCell
@synthesize homeTeamLabel = _homeTeamLabel;
@synthesize homeTeamScoreLabel = _homeTeamScoreLabel;
@synthesize homeTeamPossessionView = _homeTeamPossessionView;
@synthesize awayTeamLabel = _awayTeamLabel;
@synthesize awayTeamScoreLabel = _awayTeamScoreLabel;
@synthesize awayTeamPossessionView = _awayTeamPossessionView;
@synthesize fieldPositionIndicator = _fieldPositionIndicator;
@synthesize baseballView = _baseballView;
@synthesize teamPossession = _teamPossession;
@synthesize gameType = _gameType;

@synthesize isAdView=_isAdView;

- (void)awakeFromNib
{
    UIFont *teamFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];
    UIFont *scoreFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:16.0f];
    UIColor *teamColor = [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:1];
    UIColor *scoreColor = [UIColor fsp_colorWithIntegralRed:58 green:84 blue:112 alpha:1];

    self.homeTeamLabel.font = teamFont;
    self.awayTeamLabel.font = teamFont;
    self.homeTeamScoreLabel.font = scoreFont;
    self.awayTeamScoreLabel.font = scoreFont;
    self.homeTeamLabel.textColor = teamColor;
    self.awayTeamLabel.textColor = teamColor;
    self.homeTeamScoreLabel.textColor = scoreColor;
    self.awayTeamScoreLabel.textColor = scoreColor;
    
    
    self.homeTeamLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.homeTeamLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.awayTeamLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.awayTeamLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.homeTeamScoreLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.homeTeamScoreLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    self.awayTeamScoreLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.awayTeamScoreLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];

    
}

- (void)setIsAdView:(BOOL)isAdView
{
    if (_isAdView != isAdView) {
        _isAdView = isAdView;
           
        if (_isAdView) {
            self.header.hidden = YES;
            self.homeTeamLabel.hidden = YES;
            self.homeTeamScoreLabel.hidden = YES;
            self.awayTeamLabel.hidden = YES;
            self.awayTeamScoreLabel.hidden = YES;
            self.homeTeamLabel.hidden = YES;
            self.baseballView.hidden = YES;
            self.homeTeamPossessionView.hidden = YES;
            self.awayTeamPossessionView.hidden = YES;
            self.adView.hidden = NO;
        }
        else {
            self.header.hidden = NO;
            self.homeTeamLabel.hidden = NO;
            self.homeTeamScoreLabel.hidden = NO;
            self.awayTeamLabel.hidden = NO;
            self.awayTeamScoreLabel.hidden = NO;
            self.homeTeamLabel.hidden = NO;
            self.adView.hidden = YES;
            self.homeTeamScoreLabel.text = @"";
            self.awayTeamScoreLabel.text = @"";
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.fieldPositionIndicator setSelected:selected];
    [self.baseballView setSelected:selected];
    [self updatePossessionArrows];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.fieldPositionIndicator.hidden = YES;
    self.baseballView.hidden = YES;
}

- (void)populateCellWithEvent:(FSPGame *)game;
{
    [super populateCellWithEvent:game];
    
    if (![game isKindOfClass:[FSPGame class]])
        return;
    
    // Set all home team values
    NSString *homeTeamName = game.homeTeam.longNameDisplayString;
    if(!homeTeamName)
        homeTeamName = @"--";
    
    self.homeTeamLabel.text = homeTeamName;
    self.homeTeamScoreLabel.text = [game.homeTeamScore stringValue];
    
    // Set all away team values
    NSString *awayTeamName = game.awayTeam.longNameDisplayString;
    if(!awayTeamName)
        awayTeamName = @"--";
    
    self.awayTeamLabel.text = awayTeamName;
    self.awayTeamScoreLabel.text = [game.awayTeamScore stringValue];
    
    BOOL labelsHidden = !([game.eventStarted boolValue] || [game.eventCompleted boolValue]);
    self.awayTeamScoreLabel.hidden = labelsHidden;
    self.homeTeamScoreLabel.hidden = labelsHidden;
    
    [self updateFootballInformationWithGame:(FSPFootballGame *)game];
    [self updateBaseballInformationWithGame:(FSPBaseballGame *)game];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat teamWidth = 0.0;
    CGFloat scorePadding = 0.0;
    if (self.gameType == FSPGameChipBaseballGame && self.isInProgress && !self.baseballView.hidden) {
        teamWidth = teamWidths[0]; // short
        scorePadding = scorePaddings[0]; // short
    } else {
        teamWidth = teamWidths[1]; // full
        scorePadding = scorePaddings[1]; // full
    }
    
    [self setLabel:self.homeTeamLabel width:teamWidth];
    [self setLabel:self.awayTeamLabel width:teamWidth];
    
    [self setLabel:self.homeTeamScoreLabel originXOffsetFromRightWithPadding:scorePadding];
    [self setLabel:self.awayTeamScoreLabel originXOffsetFromRightWithPadding:scorePadding];
}

- (void)setLabel:(UILabel *)label originXOffsetFromRightWithPadding:(CGFloat)padding
{
    float a = label.bounds.size.width;
    float xOrigin = self.contentView.bounds.size.width - (a + padding);
    CGRect frame = label.frame;
    frame.origin.x = xOrigin;
    label.frame = frame;
}

- (void)setLabel:(UILabel *)label originX:(CGFloat)x;
{
    CGRect frame = label.frame;
    frame.origin.x = x;
    label.frame = frame;
}

- (void)setLabel:(UILabel *)label originXOffsetFromLabel:(UILabel *)offsetLabel amount:(CGFloat)amount;
{
    CGRect offsetFrame = offsetLabel.frame;
    CGFloat newX = CGRectGetMaxX(offsetFrame) + amount;
    [self setLabel:label originX:newX];
}

- (void)setLabel:(UILabel *)label width:(CGFloat)width;
{
    CGRect frame = label.frame;
    frame.size.width = width;
    label.frame = frame;
}

#pragma mark - Football
- (void)updatePossessionArrows;
{
    // Update the images for the possession indicator
    NSString *imageName = self.selected ? @"posession_arrow_white" : @"poession_arrow_blue";
    UIImage *possessionImage = [UIImage imageNamed:imageName];
    self.homeTeamPossessionView.image = possessionImage;
    self.awayTeamPossessionView.image = possessionImage;
}

- (void)updateFootballInformationWithGame:(FSPFootballGame *)game;
{
    BOOL isFootballGame = [game isKindOfClass:[FSPFootballGame class]];
    if (isFootballGame)
        self.gameType = FSPGameChipFootballGame;
    
    BOOL showInProgress = self.isInProgress && isFootballGame;
    // Only show the possession indicator if the game is in progress
    self.fieldPositionIndicator.hidden = !showInProgress;
    
    // Update the possession indicator
    if (showInProgress) {
        BOOL homeTeamStatus = [[(FSPFootballGame *)game homeTeamPossession] boolValue];
        if (homeTeamStatus)
            [self setTeamPossession:FSPHomeTeamPossession];
        else
            [self setTeamPossession:FSPAwayTeamPossession];
        self.fieldPositionIndicator.yardagePosition = [[(FSPFootballGame *)game fieldPosition] integerValue];
    } else {
        [self setTeamPossession:FSPNoTeamPossession];
    }
}

- (void)setTeamPossession:(FSPPossessionIndication)teamPossession;
{    
    _teamPossession = teamPossession;
    switch (teamPossession) {
        case FSPNoTeamPossession:
            self.homeTeamPossessionView.hidden = YES;
            self.awayTeamPossessionView.hidden = YES;
            break;
        case FSPHomeTeamPossession:
            self.homeTeamPossessionView.hidden = NO;
            self.awayTeamPossessionView.hidden = YES;
            break;
        case FSPAwayTeamPossession:
            self.homeTeamPossessionView.hidden = YES;
            self.awayTeamPossessionView.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Baseball
- (void)updateBaseballInformationWithGame:(FSPBaseballGame *)game;
{
    BOOL isBaseballGame = [game isKindOfClass:[FSPBaseballGame class]];

    BOOL showBaseballView = self.isInProgress && isBaseballGame && [[(FSPBaseballGame *)game baseRunners] integerValue] != -1 && ([game.segmentNumber integerValue] != 0);
    self.baseballView.hidden = !showBaseballView;
    
    if (isBaseballGame) {
        self.baseballView.baseRunnersMask = [[(FSPBaseballGame *)game baseRunners] integerValue];
        self.baseballView.outs = [[(FSPBaseballGame *)game outs] integerValue];
        self.gameType = FSPGameChipBaseballGame;
    }
}

#pragma mark - Accessibility
- (NSString *)inProgressAccessibilityLabel;
{
    NSString *label;
    switch (self.gameType) {
        case FSPGameChipGame:
            label = [self regularInProgressGameAccessibilityLabel];
            break;
        case FSPGameChipFootballGame:
            label = [self footballAccessibilityLabel];
            break;
        case FSPGameChipBaseballGame:
            label = [self baseballAccessibilityLabel];
            break;
        default:
            break;
    }
    return label;
}

- (NSString *)notInProgressAccessibilityLabel;
{
    NSString *label;
    switch (self.gameType) {
        case FSPGameChipGame:
            label = [self regularNotInProgressGameAccessibilityLabel];
            break;
        case FSPGameChipFootballGame:
            label = [self footballAccessibilityLabel];
            break;
        case FSPGameChipBaseballGame:
            label = [self baseballAccessibilityLabel];
            break;
        default:
            break;
    }
    return label;
}

- (NSString *)footballAccessibilityLabel;
{
    NSString *label;
    if (self.isInProgress) {
        NSString *baseString = [self regularInProgressGameAccessibilityLabel];
        NSString *possession = self.teamPossession == FSPHomeTeamPossession ? self.homeTeamLabel.text : self.awayTeamLabel.text;
        label = [baseString stringByAppendingFormat:@"  %@ possession. Ball on %d", possession, self.fieldPositionIndicator.yardagePosition];
    } else {
        label = [self regularNotInProgressGameAccessibilityLabel];
    }
    return label;
}

- (NSString *)baseballAccessibilityLabel;
{
    NSString *label;
    if (self.isInProgress) {
        NSString *baseString = [self regularInProgressGameAccessibilityLabel];
        label = [baseString stringByAppendingFormat:@"  %d outs. %@", self.baseballView.outs, [self.baseballView runnersString]];
    } else {
        label = [self regularNotInProgressGameAccessibilityLabel];
    }
    return label;
}

- (NSString *)regularInProgressGameAccessibilityLabel;
{
    NSString *teamNameHome = self.homeTeamLabel.text;
    NSString *teamNameAway = self.awayTeamLabel.text;
    NSString *videoAvailabilityText = self.isStreamable ? @"Video is available" : @"Video is not available";
    return [NSString stringWithFormat:@"Now playing, %@ versus %@, %@, %@ %@, %@ %@, on channel %@. %@.", teamNameHome, teamNameAway, @"now playing", teamNameAway, self.awayTeamScoreLabel.text, teamNameHome, self.homeTeamScoreLabel.text, self.header.networkLabel.text, videoAvailabilityText];
}

- (NSString *)regularNotInProgressGameAccessibilityLabel;
{
    NSString *videoAvailabilityText = self.isStreamable ? @"Video is available" : @"Video is not available";
    return [NSString stringWithFormat:@"%@ versus %@, %@, on channel %@. %@.", self.homeTeamLabel.text, self.awayTeamLabel.text, self.header.gameStateLabel.text, self.header.networkLabel.text, videoAvailabilityText];
}

@end
