//
//  FSPMLBPitcherFinalMatchupView.h
//  FoxSports
//
//  Created by Ryan McPherson on 8/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPitcherFinalMatchupView.h"
#import "FSPGameDetailSectionHeader.h"
#import "FSPGameTopPlayerView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGame.h"
#import "FSPBaseballGame.h"
#import "FSPBaseballPlayer.h"

@interface FSPMLBPitcherFinalMatchupView() {
    CGFloat fontSize;
}

@property (nonatomic, weak) IBOutlet FSPGameTopPlayerView *winningPitcherView;
@property (nonatomic, weak) IBOutlet FSPGameTopPlayerView *losingPitcherView;
@property (nonatomic, weak) IBOutlet FSPGameTopPlayerView *savingPitcherView;

@property (nonatomic, weak) IBOutlet UILabel *winningRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *losingRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *savesLabel;

@end

@implementation FSPMLBPitcherFinalMatchupView

- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPMLBPitcherFinalMatchupView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    self.sectionHeader.highlightLineFlag = @(NO);
    self.sectionHeader.darkLineFlag = @(NO);
    return self;
}

- (void)awakeFromNib
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = 12.0f;
    } else {
        fontSize = 14.0f;
    }
    
    for (UILabel *label in self.matchupValueLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:fontSize];
        label.textColor = [UIColor fsp_lightBlueColor];
        label.text = @"";
    }
    
    self.winningPitcherView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    self.losingPitcherView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    self.savingPitcherView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    [self addSubview:self.winningPitcherView];
    [self addSubview:self.losingPitcherView];
    [self addSubview:self.savingPitcherView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.winningPitcherView.frame = CGRectMake(2, 10, self.winningPitcherView.frame.size.width, self.winningPitcherView.frame.size.height);
        self.losingPitcherView.frame = CGRectMake(218, 10, self.savingPitcherView.frame.size.width, self.savingPitcherView.frame.size.height);
        self.savingPitcherView.frame = CGRectMake(434, 10, self.losingPitcherView.frame.size.width, self.losingPitcherView.frame.size.height);
    } else {
        self.winningPitcherView.frame = CGRectMake(0, 0, self.winningPitcherView.frame.size.width, self.winningPitcherView.frame.size.height);
        self.losingPitcherView.frame = CGRectMake(107, 0, self.savingPitcherView.frame.size.width, self.savingPitcherView.frame.size.height);
        self.savingPitcherView.frame = CGRectMake(213, 0, self.losingPitcherView.frame.size.width, self.losingPitcherView.frame.size.height);
    }
    
}

- (void)updateInterfaceWithGame:(FSPGame *)game
{
    if (![game isKindOfClass:[FSPBaseballGame class]]) return;
    
    FSPBaseballGame * baseballGame = (FSPBaseballGame *)game;
    FSPBaseballPlayer *winningPitcher;
    FSPBaseballPlayer *losingPitcher;
    FSPBaseballPlayer *savingPitcher;
    
    if ([baseballGame.homeWinningPitcherID intValue] > 0) {
        winningPitcher = [self findBaseballPlayerWithID:baseballGame.homeWinningPitcherID fromGame:baseballGame];
    } else {
        winningPitcher = [self findBaseballPlayerWithID:baseballGame.awayWinningPitcherID fromGame:baseballGame];
    }
    
    if ([baseballGame.homeLosingPitcherID intValue] > 0) {
        losingPitcher = [self findBaseballPlayerWithID:baseballGame.homeLosingPitcherID fromGame:baseballGame];
    } else {
        losingPitcher = [self findBaseballPlayerWithID:baseballGame.awayLosingPitcherID fromGame:baseballGame];
    }
    
    if ([baseballGame.homeSavingPitcherID intValue] > 0) {
        savingPitcher = [self findBaseballPlayerWithID:baseballGame.homeSavingPitcherID fromGame:baseballGame];
    } else if ([baseballGame.awaySavingPitcherID intValue] > 0) {
        savingPitcher = [self findBaseballPlayerWithID:baseballGame.awaySavingPitcherID fromGame:baseballGame];
    }
    
    [self.winningPitcherView populateWithPlayer:winningPitcher statType:nil statValue:nil title:@"Win"];
    [self.losingPitcherView populateWithPlayer:losingPitcher statType:nil statValue:nil title:@"Loss"];
    [self.savingPitcherView populateWithPlayer:savingPitcher statType:nil statValue:nil title:@"Save"];
    
    if (winningPitcher) {
        self.winningRecordLabel.text = [NSString stringWithFormat:@"(%d-%d)",
                                        winningPitcher.wins.intValue,
                                        winningPitcher.losses.intValue];
    } else {
        self.winningRecordLabel.text = @"";
    }
    if (losingPitcher) {
        self.losingRecordLabel.text = [NSString stringWithFormat:@"(%d-%d)",
                                       losingPitcher.wins.intValue,
                                       losingPitcher.losses.intValue];
    } else {
        self.losingRecordLabel.text = @"";
    }
    if (savingPitcher) {
        self.savesLabel.text = [NSString stringWithFormat:@"(%d)",
                                savingPitcher.saves.intValue];
    } else {
        self.savesLabel.text = @"";
    }
}

- (FSPBaseballPlayer *)findBaseballPlayerWithID:(NSNumber *)playerID fromGame:(FSPGame *)game;
{
	if (!playerID) return nil;
	
    FSPBaseballPlayer *foundPlayer;
    for (FSPBaseballPlayer *player in game.homeTeamPlayers) {
        if ([player.liveEngineID isEqualToNumber:playerID]) {
            foundPlayer = player;
            break;
        }
    }
    if (!foundPlayer) {
        for (FSPBaseballPlayer *player in game.awayTeamPlayers) {
            if ([player.liveEngineID isEqualToNumber:playerID]) {
                foundPlayer = player;
                break;
            }
        }
    }
    return foundPlayer;
}

@end
