//
//  FSPNFLTeamStatsViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamStatsViewController.h"
#import "FSPNFLLineScoreBox.h"
#import "FSPFootballGame.h"
#import "FSPGamePeriod.h"
#import "FSPGameSegmentView.h"
#import "FSPNFLTeamStatsFullStatsViewController.h"

@interface FSPNFLTeamStatsViewController ()

@property (nonatomic, strong) FSPNFLTeamStatsFullStatsViewController *fullStatsViewController;

@end

@implementation FSPNFLTeamStatsViewController

@synthesize fullStatsViewController = _fullStatsViewController;

+ (Class)boxScoreViewControllerClass {
    return nil;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent {
    [super setCurrentEvent:currentEvent];
    if (currentEvent) {
        NSParameterAssert([self.currentEvent isKindOfClass:FSPFootballGame.class]);
        self.fullStatsViewController.game = (FSPFootballGame *)self.currentEvent;
        [self.fullStatsViewController.tableView reloadData];
    }
}

- (id)init
{
	self = [super initWithNibName:@"FSPGameStatsViewController" bundle:nil];
	if (self) {

	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.gameStateView.clipsToBounds = YES;
	
    self.fullStatsViewController = [[FSPNFLTeamStatsFullStatsViewController alloc] initWithNibName:NSStringFromClass(FSPNFLTeamStatsFullStatsViewController.class)
                                                                                            bundle:nil];
	// On iPad, there isn't any scrolling.
	[self.gameStateView addSubview:self.fullStatsViewController.view];
	[self updateGameStateInterface];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateGameStateInterface];
}


- (void)createLineScoresBox
{
	self.lineScoreBox = [[FSPNFLLineScoreBox alloc] initWithFrame:self.lineScoreContainer.bounds];
    [self.lineScoreContainer addSubview:self.lineScoreBox];
}


- (void)layoutStatsViews
{
	// our content offset gets forgotten in this layout (which happens when the event updates, so we'll reset it after the layout)
	CGPoint offset = [(UIScrollView *)self.view contentOffset];
	[super layoutStatsViews];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		CGSize size = self.view.bounds.size;
		
		size.height = self.fullStatsViewController.tableView.contentSize.height;
		CGRect gameStateRect = self.gameStateView.frame;
		gameStateRect.size = size;
		self.gameStateView.frame = gameStateRect;
		
		size.height = CGRectGetMaxY(gameStateRect);
		UIScrollView *scrollView = (UIScrollView *)self.view;
		[scrollView setContentSize:size];
		scrollView.contentOffset = offset;
	}
}

- (void)updateLineScoreBox
{
    FSPFootballGame *game = (id)self.currentEvent;
    [game.periods enumerateObjectsUsingBlock:^(FSPGamePeriod *period, NSUInteger idx, BOOL *stop) 
     {
         [self.lineScoreBox updateScoresForGameSegment:(NSUInteger)period.period.intValue homeScore:period.homeTeamScore.stringValue awayScore:period.awayTeamScore.stringValue];
     }];
    
    [super updateLineScoreBox];
}

- (void)updateTotalScoreInterface
{
	FSPGame *game = (id)self.currentEvent;
	FSPNFLLineScoreBox *box = (FSPNFLLineScoreBox *)self.lineScoreBox;
	box.totalScoresView.homeTeamScoreLabel.text = [game.homeTeamScore stringValue];
	box.totalScoresView.awayTeamScoreLabel.text = [game.awayTeamScore stringValue];
	box.totalScoresView.homeTeamScoreLabel.accessibilityValue = box.totalScoresView.homeTeamScoreLabel.text;
	box.totalScoresView.awayTeamScoreLabel.accessibilityValue = box.totalScoresView.awayTeamScoreLabel.text;
}

@end
