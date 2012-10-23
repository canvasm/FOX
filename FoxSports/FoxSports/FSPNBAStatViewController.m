//
//  FSPNBAStatViewController.m
//  FoxSports
//
//  Created by Chase Latta on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBAStatViewController.h"
#import "FSPBasketballGame.h"
#import "FSPTeam.h"
#import "FSPBasketballPlayer.h"
#import "FSPNBATopPlayersViewContainer.h"
#import "FSPGameTopPlayerView.h"
#import "FSPNBALineScoreBox.h"
#import "FSPGamePeriod.h"
#import "FSPGameSegmentView.h"
#import "FSPBoxScoreViewController.h"
#import "UIColor+FSPExtensions.h"
#import "FSPCoreDataManager.h"


@interface FSPNBAStatViewController ()

@property (nonatomic, readonly) FSPBasketballPlayer *topPointsPlayer;
@property (nonatomic, readonly) FSPBasketballPlayer *topReboundsPlayer;
@property (nonatomic, readonly) FSPBasketballPlayer *topAssistsPlayer;

@property (nonatomic, strong) FSPGameTopPlayerView * topPointsPlayerView;
@property (nonatomic, strong) FSPGameTopPlayerView * topReboundsPlayerView;
@property (nonatomic, strong) FSPGameTopPlayerView * topAssistsPlayerView;

- (void)updateTopPerfomersAccessibilityLabelsWithTopPerformers:(NSArray *)topPerformers;

- (NSString *)properPointStringForPlayer:(FSPBasketballPlayer *)player;
- (NSString *)properReboundStringForPlayer:(FSPBasketballPlayer *)player;
- (NSString *)properAssistsStringForPlayer:(FSPBasketballPlayer *)player;

@end

@implementation FSPNBAStatViewController 

@synthesize topPointsPlayer = _topPointsPlayer;
@synthesize topReboundsPlayer = _topReboundsPlayer;
@synthesize topAssistsPlayer = _topAssistsPlayer;
@synthesize topPointsPlayerView, topReboundsPlayerView, topAssistsPlayerView;


#pragma mark Custom getters & setters

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    // Only 2 periods in college hoops
    // Do this here so it gets called before resetGameSegments
    NSUInteger currentMaxSegmentCount = self.lineScoreBox.maxRegularPlayGameSegments;
    if (currentEvent.viewType == FSPNCAABViewType || currentEvent.viewType == FSPNCAAWBViewType) {
        self.lineScoreBox.maxRegularPlayGameSegments = 2;
    }
    else {
        self.lineScoreBox.maxRegularPlayGameSegments = 4;
    }
    
    // If the max segment count has changed, rebuild the lineScoreBox from scratch.
    if (currentMaxSegmentCount != self.lineScoreBox.maxRegularPlayGameSegments) {
        [self.lineScoreBox clearGameSegments];
    }
    
	[super setCurrentEvent:currentEvent];
    self.topPlayersView.informationComplete = (currentEvent.eventStarted.boolValue && self.topPointsPlayer);
}

- (id)init
{
    if (self = [super initWithNibName:@"FSPGameStatsViewController" bundle:nil]) {
        self.topPlayersView = [[FSPGameTopPlayersViewContainer alloc] initWithFrame:CGRectZero];
        self.topPlayersView.backgroundColor = [UIColor greenColor];
        self.topPointsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        self.topReboundsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        self.topAssistsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        self.boxScoreViewController = [[FSPBoxScoreViewController alloc] initWithGame:nil];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.accessibilityIdentifier = @"gameStats";

    self.topPlayersView.informationComplete = (self.currentEvent.eventStarted.boolValue && self.topPointsPlayer);
    [self.topPlayersView addSubview:self.topPointsPlayerView];
    [self.topPlayersView addSubview:self.topReboundsPlayerView];
    [self.topPlayersView addSubview:self.topAssistsPlayerView];
    
    CGFloat topPlayerHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? FSPGameTopPlayerHeightOffsetIPad :FSPGameTopPlayerHeightOffsetIPhone;
    CGFloat topPlayerLeftOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 22 : 0;

    self.topPointsPlayerView.frame = CGRectMake(0, topPlayerHeight, self.topPointsPlayerView.bounds.size.width, self.topPointsPlayerView.bounds.size.height);
    self.topReboundsPlayerView.frame = CGRectMake(self.topReboundsPlayerView.bounds.size.width - topPlayerLeftOffset, topPlayerHeight, self.topReboundsPlayerView.bounds.size.width, self.topReboundsPlayerView.bounds.size.height);
    self.topAssistsPlayerView.frame = CGRectMake((self.topAssistsPlayerView.bounds.size.width - topPlayerLeftOffset) * 2 , topPlayerHeight, self.topAssistsPlayerView.bounds.size.width, self.topAssistsPlayerView.bounds.size.height);
    [self updateGameStateInterface];

    [self.boxScoreContainer addSubview:self.boxScoreViewController.view];
    self.boxScoreViewController.currentGame = (FSPGame *)self.currentEvent;
    [self updateInterface];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Subview support
- (void)createLineScoresBox
{
	self.lineScoreBox = [[FSPNBALineScoreBox alloc] initWithFrame:self.lineScoreContainer.bounds];
    [self.lineScoreContainer addSubview:self.lineScoreBox];
}

- (void)updateLineScoreBox
{
    FSPGame *game = (id)self.currentEvent;
    [game.periods enumerateObjectsUsingBlock:^(FSPGamePeriod *period, NSUInteger idx, BOOL *stop) 
     {
         [self.lineScoreBox updateScoresForGameSegment:(NSUInteger)period.period.intValue homeScore:period.homeTeamScore.stringValue awayScore:period.awayTeamScore.stringValue];
     }];
    
    [super updateLineScoreBox];
}

- (void)updateGameStateInterface;
{
    CGRect gameStateFrame = self.gameStateView.frame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        gameStateFrame.size.height = 145;
	} else {
		gameStateFrame.size.height = 188;
	}
	self.gameStateView.frame = gameStateFrame;
	
	CGRect boxScoreFrame = self.boxScoreContainer.frame;
	boxScoreFrame.origin.y = CGRectGetMaxY(gameStateFrame);
	self.boxScoreContainer.frame = boxScoreFrame;
    
    [self.topPointsPlayerView populateWithPlayer:self.topPointsPlayer statType:@"PTS" statValue:self.topPointsPlayer.points title:@"Top Points"];
    [self.topReboundsPlayerView populateWithPlayer:self.topReboundsPlayer statType:@"REB" statValue:self.topReboundsPlayer.rebounds title:@"Top Rebounds"];
    [self.topAssistsPlayerView populateWithPlayer:self.topAssistsPlayer statType:@"AST" statValue: self.topAssistsPlayer.assists title:@"Top Assists"];
//    [self.gameStateView updateContainer];
}

- (void)updateTotalScoreInterface
{
	FSPGame *game = (id)self.currentEvent;
	FSPNBALineScoreBox *box = (FSPNBALineScoreBox *)self.lineScoreBox;
	box.totalScoresView.homeTeamScoreLabel.text = [game.homeTeamScore stringValue];
	box.totalScoresView.awayTeamScoreLabel.text = [game.awayTeamScore stringValue];
	box.totalScoresView.homeTeamScoreLabel.accessibilityValue = box.totalScoresView.homeTeamScoreLabel.text;
	box.totalScoresView.awayTeamScoreLabel.accessibilityValue = box.totalScoresView.awayTeamScoreLabel.text;
}

- (void)layoutStatsViews
{
    [super layoutStatsViews];
    if (self.topPointsPlayer == nil && self.topReboundsPlayer == nil && self.topAssistsPlayer == nil) {
        self.gameStateView.hidden = YES;
        // if [super layoutStatsView] has hidden the lines score, the box score goes all the way to the top
        if (self.lineScoreContainer.hidden == YES) {
            self.boxScoreContainer.frame = CGRectMake(0.0f, 15.0f, self.view.frame.size.width, self.view.frame.size.height);
        }
        else {
            self.boxScoreContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.lineScoreBox.frame) + 15, self.view.frame.size.width, self.boxScoreContainer.frame.size.height);
        }
    }
}

#pragma mark - UITableViewDataSource

#pragma mark - Top Performers support

- (void)updateTopPerfomersAccessibilityLabelsWithTopPerformers:(NSArray *)topPerformers;
{
    //TODO: Move this to the FSPGameTopPerformerView
//    NSString *string;
//    if ([topPerformers count] < 2) {
//        string = @"no top performers";
//    } else {
//        FSPBasketballPlayer *homeTeamPlayer = [topPerformers objectAtIndex:0];
//        FSPBasketballPlayer *awayTeamPlayer = [topPerformers objectAtIndex:1];
//        string = [NSString stringWithFormat:@"top performers, %@ %@ for the home team, %@, %@, %@, %@ %@ for the away team, %@, %@, %@", homeTeamPlayer.firstName, homeTeamPlayer.lastName, [self properPointStringForPlayer:homeTeamPlayer], [self properReboundStringForPlayer:homeTeamPlayer], [self properAssistsStringForPlayer:homeTeamPlayer], awayTeamPlayer.firstName, awayTeamPlayer.lastName, [self properPointStringForPlayer:awayTeamPlayer], [self properReboundStringForPlayer:awayTeamPlayer], [self properAssistsStringForPlayer:awayTeamPlayer]];
//    }
    
//    self.topPerformersView.accessibilityLabel = string;
}

- (NSString *)properPointStringForPlayer:(FSPBasketballPlayer *)player;
{
    NSString *string = nil;
    if ([player.points integerValue] > 1)
        string = [NSString stringWithFormat:@"%@ points", player.points];
    else
        string = [NSString stringWithFormat:@"%@ point", player.points];
    return string;
}

- (NSString *)properReboundStringForPlayer:(FSPBasketballPlayer *)player;
{
    NSString *string = nil;
    if ([player.rebounds integerValue] > 1)
        string = [NSString stringWithFormat:@"%@ rebounds", player.rebounds];
    else
        string = [NSString stringWithFormat:@"%@ rebound", player.rebounds];
    return string;
}

- (NSString *)properAssistsStringForPlayer:(FSPBasketballPlayer *)player;
{
    NSString *string = nil;
    if ([player.assists integerValue] > 1)
        string = [NSString stringWithFormat:@"%@ assists", player.assists];
    else
        string = [NSString stringWithFormat:@"%@ assist", player.assists];
    return string;
}


- (FSPBasketballPlayer *)topPointsPlayer;
{
    FSPBasketballPlayer *topPerformer = nil;
    NSSet *players = [self allPlayers];
    if([players count] > 0) {
        NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        NSSortDescriptor *pointsSort = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
        NSArray *sortedPlayers = [players sortedArrayUsingDescriptors:@[pointsSort,lastNameSortDescriptor]];
        topPerformer = [sortedPlayers objectAtIndex:0];
        if (topPerformer.points.intValue == 0)
            return nil;
    }
    return topPerformer;
}

- (FSPBasketballPlayer *)topReboundsPlayer;
{
    FSPBasketballPlayer *topPerformer = nil;
    NSSet *players = [self allPlayers];
    if([players count] > 0) {
        NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        NSSortDescriptor *pointsSort = [NSSortDescriptor sortDescriptorWithKey:@"rebounds" ascending:NO];
        NSArray *sortedPlayers = [players sortedArrayUsingDescriptors:@[pointsSort,lastNameSortDescriptor]];
        topPerformer = [sortedPlayers objectAtIndex:0];
        if (topPerformer.rebounds.intValue == 0)
            return nil;
    }
    return topPerformer;
}

- (FSPBasketballPlayer *)topAssistsPlayer;
{
    FSPBasketballPlayer *topPerformer = nil;
    NSSet *players = [self allPlayers];
    if([players count] > 0) {
        NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        NSSortDescriptor *pointsSort = [NSSortDescriptor sortDescriptorWithKey:@"assists" ascending:NO];
        NSArray *sortedPlayers = [players sortedArrayUsingDescriptors:@[pointsSort,lastNameSortDescriptor]];
        topPerformer = [sortedPlayers objectAtIndex:0];
        if(topPerformer.assists.intValue == 0)
            return nil;
    }
    return topPerformer;
}

@end
