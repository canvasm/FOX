//
//  FSPNHLPlayerStatsViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLPlayerStatsViewController.h"
#import "FSPBoxScoreViewController.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPGameTopPlayersViewContainer.h"
#import "FSPNHLGameTopPlayerView.h"
#import "FSPTeam.h"
#import "FSPHockeyPlayer.h"
#import "FSPGameDetailSectionHeader.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPHockeyGame.h"
#import "FSPGamePeriod.h"
#import "FSPNHLLineScoreBox.h"
#import "FSPGameSegmentView.h"

#define kTopPlayersHeaderHeight 30.0

@interface FSPNHLPlayerStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *noStatsAvailableLabel;
@property (weak, nonatomic) IBOutlet UIView *boxScoreContainer;
@property (weak, nonatomic) IBOutlet UILabel *topPerformersHeaderTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *topPerformersHeaderView;

@end

@implementation FSPNHLPlayerStatsViewController

@synthesize noStatsAvailableLabel = _noStatsAvailableLabel;
@synthesize boxScoreContainer = _boxScoreContainer;
@synthesize topPerformersHeaderTitleLabel = _topPerformersHeaderTitleLabel;
@synthesize topPerformersHeaderView = _topPerformersHeaderView;
@synthesize currentEvent = _currentEvent;

- (id)init
{
	self = [super initWithNibName:@"FSPNHLPlayerStatsViewController" bundle:nil];
	if (self) {
        
	}
	return self;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    if ((_currentEvent != currentEvent) && ([currentEvent isKindOfClass:[FSPGame class]])) {
        _currentEvent = currentEvent;
        
        [self updateInterface];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addStatsView];
    
    self.topPerformersHeaderTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.topPerformersHeaderTitleLabel.textColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [self setTopPerformersHeaderTitleLabel:nil];
    [self setTopPerformersHeaderView:nil];
    [super viewDidUnload];
    [self setNoStatsAvailableLabel:nil];
    [self setBoxScoreContainer:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)addStatsView
{
    self.boxScoreViewController = [[FSPBoxScoreViewController alloc] initWithGame:nil];
    [self.boxScoreContainer addSubview:self.boxScoreViewController.view];
    self.boxScoreViewController.view.frame = self.boxScoreContainer.bounds;
    
    self.topPlayersView = [[FSPGameTopPlayersViewContainer alloc] initWithFrame:self.gameStateView.bounds];
    [self.gameStateView addSubview:self.topPlayersView];
}

- (void)updateInterface
{
    self.boxScoreViewController.currentGame = (FSPGame *)self.currentEvent;
    [super updateInterface];
    
    [self addTopPerformers];
}

- (void)addTopPerformers
{
    for (FSPGameTopPlayerView *topPlayerView in [self.gameStateView subviews]) {
        if ([topPlayerView isKindOfClass:[FSPGameTopPlayerView class]]) {
            [topPlayerView removeFromSuperview];
        }
    }
    
    FSPGame *currentGame = (FSPGame *)self.currentEvent;
    
    NSMutableArray *bothTeamPlayers = [NSMutableArray arrayWithArray:[currentGame.homeTeamPlayers allObjects]];
    [bothTeamPlayers addObjectsFromArray:[currentGame.awayTeamPlayers allObjects]];
    
    FSPHockeyPlayer *player;
    FSPHockeyPlayer *starPlayer1 = player;
    FSPHockeyPlayer *starPlayer2 = player;
    FSPHockeyPlayer *starPlayer3 = player;
    
    for (FSPHockeyPlayer *player in bothTeamPlayers) {
        if ([player.star integerValue] == 1) {
            starPlayer1 = player;
        }
        if ([player.star integerValue] == 2) {
            starPlayer2 = player;
        }
        if ([player.star integerValue] == 3) {
            starPlayer3 = player;
        }
    }
    
    CGFloat topMargin = kTopPlayersHeaderHeight + 10.0;
    FSPNHLGameTopPlayerView *topPlayerViewLeft = [[FSPNHLGameTopPlayerView alloc] init];
    [topPlayerViewLeft populateWithPlayer:starPlayer1];
    topPlayerViewLeft.frame = CGRectMake(0.0, topMargin, topPlayerViewLeft.frame.size.width, topPlayerViewLeft.frame.size.height);
    [self.gameStateView addSubview:topPlayerViewLeft];
    
    FSPNHLGameTopPlayerView *topPlayerViewMiddle = [[FSPNHLGameTopPlayerView alloc] init];
    [topPlayerViewMiddle populateWithPlayer:starPlayer2];
    topPlayerViewMiddle.frame = CGRectMake(CGRectGetMaxX(topPlayerViewLeft.frame), topMargin, topPlayerViewMiddle.frame.size.width, topPlayerViewMiddle.frame.size.height);
    [self.gameStateView addSubview:topPlayerViewMiddle];
    
    FSPNHLGameTopPlayerView *topPlayerViewRight = [[FSPNHLGameTopPlayerView alloc] init];
    [topPlayerViewRight populateWithPlayer:starPlayer3];
    topPlayerViewRight.frame = CGRectMake(CGRectGetMaxX(topPlayerViewMiddle.frame), topMargin, topPlayerViewRight.frame.size.width, topPlayerViewRight.frame.size.height);
    [self.gameStateView addSubview:topPlayerViewRight];
}

@end
