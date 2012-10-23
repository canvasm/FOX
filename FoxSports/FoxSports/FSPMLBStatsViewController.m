//
//  FSPMLBGameStatsViewController.m
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBStatsViewController.h"
#import "FSPGameTopPlayerView.h"
#import "FSPGameTopPlayersViewContainer.h"
#import "FSPMLBLineScoreBox.h"
#import "FSPBaseballGame.h"
#import "FSPGameSegmentView.h"
#import "FSPMLBHitterVsPitcherMatchupView.h"
#import "FSPMLBPitcherFinalMatchupView.h"
#import "FSPGamePeriod.h"
#import "FSPTeam.h"

@interface FSPMLBStatsViewController ()

@property (nonatomic, strong) FSPGameMatchupView *matchupView;
@property (nonatomic, strong) FSPMLBPitcherFinalMatchupView *finalMatchupView;

@end

@implementation FSPMLBStatsViewController

@synthesize matchupView;
@synthesize finalMatchupView;

- (id)init
{
	self = [super initWithNibName:@"FSPGameStatsViewController" bundle:nil];
	if (self) {
        self.matchupView = [[FSPMLBHitterVsPitcherMatchupView alloc] init];
        self.finalMatchupView = [[FSPMLBPitcherFinalMatchupView alloc] init];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.gameStateView addSubview:self.matchupView];
    [self.gameStateView addSubview:self.finalMatchupView];
	[self updateGameStateInterface];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateGameStateInterface];
}

- (void)createLineScoresBox
{
	self.lineScoreBox = [[FSPMLBLineScoreBox alloc] initWithFrame:self.lineScoreContainer.bounds];
    self.lineScoreBox.maxSegmentsToDisplay = 9;
    [self.lineScoreContainer addSubview:self.lineScoreBox];
}

- (void)updateGameStateInterface;
{
	CGRect gameStateFrame = self.gameStateView.frame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		gameStateFrame.size.height = 140;
	} else {
		gameStateFrame.size.height = 180;
	}
	self.gameStateView.frame = gameStateFrame;
	
	CGRect boxScoreFrame = self.boxScoreContainer.frame;
	boxScoreFrame.origin.y = CGRectGetMaxY(gameStateFrame);
	self.boxScoreContainer.frame = boxScoreFrame;
	
	FSPBaseballGame *game = (id)self.currentEvent;
    
    if ([game.eventCompleted boolValue]) {
        if ([game.homeLosingPitcherID intValue] == 0 && [game.awayLosingPitcherID intValue] == 0) {
            self.gameStateView.hidden = YES;
            self.matchupView.hidden = YES;
            self.finalMatchupView.hidden = NO;
        } else {
            self.gameStateView.hidden = YES;
            self.matchupView.hidden = YES;
            self.finalMatchupView.hidden = NO;
            [self.finalMatchupView updateInterfaceWithGame:game];
        }
    } else if ([game.eventStarted boolValue]) {
		self.gameStateView.hidden = NO;
        self.finalMatchupView.hidden = YES;
        self.matchupView.hidden = NO;
        [self.matchupView updateInterfaceWithGame:game];
	} else {
		self.gameStateView.hidden = YES;
	}
    [self.gameStateView setNeedsDisplay];
}

- (void)updateLineScoreBox
{
    FSPBaseballGame *game = (id)self.currentEvent;
    [game.periods enumerateObjectsUsingBlock:^(FSPGamePeriod *period, NSUInteger idx, BOOL *stop) 
     {
         NSString *homeScore = period.homeTeamScore.stringValue;
         if (idx == [game.periods count] - 1) {
             if (game.eventCompleted.boolValue && idx == 8 && [homeScore isEqualToString:@"0"] && game.homeTeamScore.intValue > game.awayTeamScore.intValue) {
                 homeScore = @"X";
             } else if ([game.segmentDescription isEqualToString:@"T"]) {
                 homeScore = @"";
             }
         }
         NSString *awayScore = period.awayTeamScore.stringValue;
         [self.lineScoreBox updateScoresForGameSegment:(NSUInteger)period.period.intValue homeScore:homeScore awayScore:awayScore];
     }];

    [super updateLineScoreBox];
}

- (void)updateTotalScoreInterface
{
	// TODO : plug in real data when we get it
	FSPBaseballGame *game = (id)self.currentEvent;
	FSPMLBLineScoreBox *box = (FSPMLBLineScoreBox *)self.lineScoreBox;
	
	box.totalRunsView.homeTeamScoreLabel.text = game.homeTeamScore.stringValue;
	box.totalRunsView.awayTeamScoreLabel.text = game.awayTeamScore.stringValue; 
	box.totalRunsView.homeTeamScoreLabel.accessibilityValue = box.totalRunsView.homeTeamScoreLabel.text;
	box.totalRunsView.awayTeamScoreLabel.accessibilityValue = box.totalRunsView.awayTeamScoreLabel.text;

	box.totalHitsView.homeTeamScoreLabel.text = game.homeHits ? game.homeHits.stringValue : @"";
	box.totalHitsView.awayTeamScoreLabel.text = game.awayHits ? game.awayHits.stringValue : @"";
	box.totalHitsView.homeTeamScoreLabel.accessibilityValue = box.totalHitsView.homeTeamScoreLabel.text;
	box.totalHitsView.awayTeamScoreLabel.accessibilityValue = box.totalHitsView.awayTeamScoreLabel.text;

	box.totalErrorsView.homeTeamScoreLabel.text = game.homeErrors ? game.homeErrors.stringValue : @"";
	box.totalErrorsView.awayTeamScoreLabel.text = game.awayErrors ? game.awayErrors.stringValue : @"";
	box.totalErrorsView.homeTeamScoreLabel.accessibilityValue = box.totalErrorsView.homeTeamScoreLabel.text;
	box.totalErrorsView.awayTeamScoreLabel.accessibilityValue = box.totalErrorsView.awayTeamScoreLabel.text;
}


@end
