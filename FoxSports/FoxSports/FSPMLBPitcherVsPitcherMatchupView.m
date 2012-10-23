//
//  FSPMLBMatchupView.m
//  FoxSports
//
//  Created by Matthew Fay on 6/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPitcherVsPitcherMatchupView.h"
#import "FSPGameDetailSectionHeader.h"
#import "FSPGameTopPlayerView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGame.h"
#import "FSPBaseballGame.h"
#import "FSPBaseballPlayer.h"

@interface FSPMLBPitcherVsPitcherMatchupView() {
    CGFloat fontSize;
}
@property(nonatomic, weak) IBOutlet FSPGameDetailSectionHeader *sectionHeader;
@property(nonatomic, weak) FSPGameTopPlayerView *awayTeamPitcher;
@property(nonatomic, weak) FSPGameTopPlayerView *homeTeamPitcher;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *matchupPlayerLabels;
@property (nonatomic, weak) IBOutlet UILabel *titleMatchupHeader;
@property(nonatomic, weak) IBOutlet UILabel *awayWinLoss;
@property(nonatomic, weak) IBOutlet UILabel *awayERA;
@property(nonatomic, weak) IBOutlet UILabel *awayWHIP;
@property(nonatomic, weak) IBOutlet UILabel *homeWinLoss;
@property(nonatomic, weak) IBOutlet UILabel *homeERA;
@property(nonatomic, weak) IBOutlet UILabel *homeWHIP;
@property(nonatomic, weak) IBOutlet UILabel *matchupSectionLabel;

- (void)resetPlayerLabelsFont;
@end

@implementation FSPMLBPitcherVsPitcherMatchupView
@synthesize matchupSectionLabel;
@synthesize sectionHeader;
@synthesize awayTeamPitcher;
@synthesize homeTeamPitcher;
@synthesize awayWinLoss, awayERA, awayWHIP;
@synthesize homeWinLoss, homeERA, homeWHIP;
@synthesize matchupPlayerLabels;
@synthesize titleMatchupHeader;

- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPMLBPitcherVsPitcherMatchupView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    self.sectionHeader.highlightLineFlag = @(NO);
    self.sectionHeader.darkLineFlag = @(NO);
    return self;
}

- (void)awakeFromNib
{
    NSUInteger xPos;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        xPos = 214;
        fontSize = 12.0f;
    } else {
        xPos = 434;
        fontSize = 14.0f;
    }
    
    for (UILabel *label in self.matchupTitleLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        label.textColor = [UIColor whiteColor];
    }
    self.matchupSectionLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0];
    
    self.titleMatchupHeader.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0];
    
    self.awayTeamPitcher = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    self.homeTeamPitcher = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionRight];
    [self addSubview:self.awayTeamPitcher];
    [self addSubview:self.homeTeamPitcher];
    
    //TODO: change frame for iPhone
    self.awayTeamPitcher.frame = CGRectMake(0, 40, self.awayTeamPitcher.frame.size.width, self.awayTeamPitcher.frame.size.height);
    
    self.homeTeamPitcher.frame = CGRectMake(xPos, 40, self.homeTeamPitcher.frame.size.width, self.homeTeamPitcher.frame.size.height);
}

- (void)updateInterfaceWithGame:(FSPGame *)game
{
    if (![game isKindOfClass:[FSPBaseballGame class]]) return;
    
    FSPBaseballGame * baseballGame = (FSPBaseballGame *)game;
    BOOL homePitcher = YES;
    BOOL awayPitcher = YES;
    
    if (!baseballGame.homeTeamStartingPitcher && !baseballGame.awayTeamStartingPitcher) {
        for (UILabel *label in self.matchupPlayerLabels) {
            label.hidden = YES;
        }
    } else {
        for (UILabel *label in self.matchupPlayerLabels) {
            label.hidden = NO;
        }
    }
    
    [self resetPlayerLabelsFont];

    //TODO: populate the home and away pitchers views
    baseballGame.homeTeamStartingPitcher.homeGame = baseballGame;
    baseballGame.awayTeamStartingPitcher.awayGame = baseballGame;
    [self.homeTeamPitcher populateWithPlayer:baseballGame.homeTeamStartingPitcher statType:nil statValue:nil title:nil];
    [self.awayTeamPitcher populateWithPlayer:baseballGame.awayTeamStartingPitcher statType:nil statValue:nil title:nil];
    
    if (!baseballGame.homeTeamStartingPitcher)
        homePitcher = NO;
    if (!baseballGame.awayTeamStartingPitcher)
        awayPitcher = NO;
    
        self.homeWinLoss.text = [NSString stringWithFormat:@"%@-%@", homePitcher ? baseballGame.homeTeamStartingPitcher.wins : @"-", homePitcher ? baseballGame.homeTeamStartingPitcher.losses : @""];
    self.homeERA.text = [NSString stringWithFormat:@"%@", homePitcher ? baseballGame.homeTeamStartingPitcher.seasonERAString : @"--"];
    self.homeWHIP.text = [NSString stringWithFormat:@"%@", homePitcher ?  baseballGame.homeTeamStartingPitcher.seasonWHIPString : @"--"];
    
    self.awayWinLoss.text = [NSString stringWithFormat:@"%@-%@", awayPitcher ? baseballGame.awayTeamStartingPitcher.wins : @"-", awayPitcher ? baseballGame.awayTeamStartingPitcher.losses : @""];
    self.awayERA.text = [NSString stringWithFormat:@"%@", awayPitcher ? baseballGame.awayTeamStartingPitcher.seasonERAString : @"--"];
    self.awayWHIP.text = [NSString stringWithFormat:@"%@", awayPitcher ? baseballGame.awayTeamStartingPitcher.seasonWHIPString : @"--"];
    
    //check who has a better win loss
    if ( homePitcher && ((homePitcher && !awayPitcher) || (baseballGame.homeTeamStartingPitcher.wins.intValue > baseballGame.awayTeamStartingPitcher.wins.intValue || 
        (baseballGame.homeTeamStartingPitcher.wins.intValue == baseballGame.awayTeamStartingPitcher.wins.intValue && baseballGame.homeTeamStartingPitcher.losses.intValue <= baseballGame.awayTeamStartingPitcher.losses.intValue)))) {
        self.homeWinLoss.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.homeWinLoss.textColor = [UIColor whiteColor];
    } else if (awayPitcher) {
        self.awayWinLoss.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.awayWinLoss.textColor = [UIColor whiteColor];
    }
    
    //check who has a lower ERA
    if (homePitcher && ((homePitcher && !awayPitcher) || baseballGame.homeTeamStartingPitcher.seasonERA.floatValue <= baseballGame.awayTeamStartingPitcher.seasonERA.floatValue)) {
        self.homeERA.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.homeERA.textColor = [UIColor whiteColor];
    } else if (awayPitcher) {
        self.awayERA.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.awayERA.textColor = [UIColor whiteColor];
    }
    
    //check who has a lower WHIP
    if (homePitcher && ((homePitcher && !awayPitcher) || baseballGame.homeTeamStartingPitcher.seasonWHIP.floatValue <= baseballGame.awayTeamStartingPitcher.seasonWHIP.floatValue)) {
        self.homeWHIP.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.homeWHIP.textColor = [UIColor whiteColor];
    } else if (awayPitcher) {
        self.awayWHIP.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        self.awayWHIP.textColor = [UIColor whiteColor];
    }
}

- (void)resetPlayerLabelsFont
{
    for (UILabel *label in self.matchupPlayerLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:fontSize];
        label.textColor = [UIColor fsp_lightBlueColor];
    }
}

@end
