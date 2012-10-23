//
//  FSPGameOddsView.m
//  FoxSports
//
//  Created by Matthew Fay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameOddsView.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPGameOdds.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

@interface FSPGameOddsView()
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *oddsLabels;
@property (nonatomic, weak) IBOutlet UIView *homeTeamOddsContainer;
@property (nonatomic, weak) IBOutlet UIView *awayTeamOddsContainer;

@property (nonatomic, weak) IBOutlet UILabel *homeTeamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeMoneyLineLabel;
@property (nonatomic, weak) IBOutlet UILabel *homePointSpreadLabel;
@property (nonatomic, weak) IBOutlet UILabel *homePSMoneyLineLabel;
@property (nonatomic, weak) IBOutlet UILabel *homePitcher;
@property (nonatomic, weak) IBOutlet UILabel *awayTeamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayMoneyLineLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayPointSpreadLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayPSMoneyLineLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayPitcher;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *oddsTypeLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *oddsValueLabels;

- (void)updateOddsAccessibilityLabels;
@end

@implementation FSPGameOddsView

@synthesize homeTeamOddsContainer, awayTeamOddsContainer;
@synthesize homeMoneyLineLabel, homePointSpreadLabel, homePSMoneyLineLabel, homeTeamNameLabel;
@synthesize awayTeamNameLabel, awayMoneyLineLabel, awayPointSpreadLabel, awayPSMoneyLineLabel;
@synthesize homePitcher, awayPitcher;
@synthesize oddsLabels;
@synthesize oddsTypeLabels = _oddsTypeLabels;
@synthesize oddsValueLabels = _oddsValueLabels;
@synthesize informationComplete = _informationComplete;

- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPGameOddsView" bundle:nil];
    NSArray *views = [matchupNib instantiateWithOwner:nil options:nil];
    self = [views lastObject];
 
    UIFont *oddsTypeFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    for (UILabel *label in self.oddsTypeLabels) {
        label.font = oddsTypeFont;
        label.textColor = [UIColor whiteColor];
    }

    UIFont *oddsValueFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    UIColor *oddsValueColor = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.oddsValueLabels) {
        label.font = oddsValueFont;
        label.textColor = oddsValueColor;
    }

    return self;
}

- (void)updateInterfaceWithGame:(FSPGame *)game;
{
    if(!game)
        return;

    FSPGameOdds *odds = game.odds;
    if (!odds) {
        self.informationComplete = NO;
        return;
    }
    else {
        self.informationComplete = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.awayTeamNameLabel.text = game.awayTeam.shortNameDisplayString;
        self.homeTeamNameLabel.text = game.homeTeam.shortNameDisplayString;

        self.homeMoneyLineLabel.text = odds.homeTeamMoneyLine;
        self.homePointSpreadLabel.text = odds.homeTeamPointSpread;
        self.homePSMoneyLineLabel.text = odds.homeTeamPSMoneyLine;
        self.awayMoneyLineLabel.text = odds.awayTeamMoneyLine;
        self.awayPointSpreadLabel.text = odds.awayTeamPointSpread;
        self.awayPSMoneyLineLabel.text = odds.awayTeamPSMoneyLine;
        
        //MLB is the only variation to this class
        if ([game.branch isEqualToString:FSPMLBEventBranchType]) {
            self.homePitcher.hidden = NO;
            self.awayPitcher.hidden = NO;
            //TODO: put the pitcher in once we get the feed up for MLB game dictionary
//            self.homePitcher.text = //home pitcher from game
//            self.awayPitcher.text = //away pitcher from game
        }
        
        for(UILabel *oddsLabel in self.oddsLabels)
            [oddsLabel fsp_indicateNoData];
        
        [self updateOddsAccessibilityLabels];
    });
}

#pragma mark - Accessibility

- (void)updateOddsAccessibilityLabels;
{
    NSString *homeLabel = [NSString stringWithFormat:@"%@, %@, %@, %@", self.homeTeamNameLabel.text, self.homeMoneyLineLabel.text, self.homePointSpreadLabel.text, self.homePSMoneyLineLabel.text];
    NSString *awayLabel = [NSString stringWithFormat:@"%@, %@, %@, %@", self.awayTeamNameLabel.text, self.awayMoneyLineLabel.text, self.awayPointSpreadLabel.text, self.awayPSMoneyLineLabel.text];
    
    self.homeTeamOddsContainer.accessibilityLabel = homeLabel;
    self.awayTeamOddsContainer.accessibilityLabel = awayLabel;
}

@end
