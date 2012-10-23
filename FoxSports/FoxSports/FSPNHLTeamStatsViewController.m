//
//  FSPNHLTeamStatsViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLTeamStatsViewController.h"
#import "FSPNHLLineScoreBox.h"
#import "FSPHockeyGame.h"
#import "FSPGamePeriod.h"
#import "FSPGameSegmentView.h"
#import "FSPNHLTeamStatsFullStatsViewController.h"

@interface FSPNHLTeamStatsViewController ()

@property (nonatomic, strong) FSPNHLTeamStatsFullStatsViewController *fullStatsViewController;

@end

@implementation FSPNHLTeamStatsViewController

@synthesize fullStatsViewController = _fullStatsViewController;

+ (Class)boxScoreViewControllerClass {
    return nil;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent {
    [super setCurrentEvent:currentEvent];
    if (currentEvent) {
        NSParameterAssert([self.currentEvent isKindOfClass:FSPHockeyGame.class]);
        self.fullStatsViewController.game = (FSPHockeyGame *)self.currentEvent;
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

    self.fullStatsViewController = [[FSPNHLTeamStatsFullStatsViewController alloc] initWithNibName:NSStringFromClass(FSPNHLTeamStatsFullStatsViewController.class)
                                                                                            bundle:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // On iPhone, put the team stats table inside a scrollview so the header view scrolls with the rest of the table.
        UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.fullStatsViewController.tableView reloadData];
        self.fullStatsViewController.view.frame = CGRectMake(self.fullStatsViewController.view.frame.origin.x,
                                                             self.lineScoreBox.frame.size.height + 15,
                                                             self.fullStatsViewController.view.frame.size.width,
                                                             self.fullStatsViewController.view.frame.size.height);
        CGFloat heights = CGRectGetHeight(self.fullStatsViewController.view.frame) + CGRectGetHeight(self.lineScoreContainer.frame);
        detailView.contentSize = CGSizeMake(0, heights);
        detailView.backgroundColor = UIColor.clearColor;
        [self.view addSubview:detailView];
        [detailView addSubview:self.lineScoreContainer];
        [detailView addSubview:self.fullStatsViewController.view];
        
    } else {
        // On iPad, there isn't any scrolling.
        [self.gameStateView addSubview:self.fullStatsViewController.view];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}


- (void)createLineScoresBox
{
	self.lineScoreBox = [[FSPNHLLineScoreBox alloc] initWithFrame:self.lineScoreContainer.bounds];
    self.lineScoreBox.maxRegularPlayGameSegments = 3;
    [self.lineScoreContainer addSubview:self.lineScoreBox];
}

- (void)updateLineScoreBox
{
    FSPHockeyGame *game = (id)self.currentEvent;
    if ([game.segmentNumber isEqualToString:@"3"]) {
        [game.periods enumerateObjectsUsingBlock:^(FSPGamePeriod *period, NSUInteger idx, BOOL *stop)
         {
             [self.lineScoreBox updateScoresForGameSegment:(NSUInteger)period.period.intValue
                                                 homeScore:period.homeTeamScore.stringValue
                                                 awayScore:period.awayTeamScore.stringValue];
             [self.lineScoreBox updateScoresForGameSegment:4
                                                 homeScore:@"–"
                                                 awayScore:@"–"];
         }];
    } else if ([game.segmentNumber isEqualToString:@"4"]) {
        [game.periods enumerateObjectsUsingBlock:^(FSPGamePeriod *period, NSUInteger idx, BOOL *stop)
         {
             [self.lineScoreBox updateScoresForGameSegment:(NSUInteger)period.period.intValue
                                                 homeScore:period.homeTeamScore.stringValue
                                                 awayScore:period.awayTeamScore.stringValue];
         }];
    }
    
    
    [super updateLineScoreBox];
}

- (void)updateTotalScoreInterface
{
	FSPGame *game = (id)self.currentEvent;
	FSPNHLLineScoreBox *box = (FSPNHLLineScoreBox *)self.lineScoreBox;
	box.totalScoresView.homeTeamScoreLabel.text = [game.homeTeamScore stringValue];
	box.totalScoresView.awayTeamScoreLabel.text = [game.awayTeamScore stringValue];
	box.totalScoresView.homeTeamScoreLabel.accessibilityValue = box.totalScoresView.homeTeamScoreLabel.text;
	box.totalScoresView.awayTeamScoreLabel.accessibilityValue = box.totalScoresView.awayTeamScoreLabel.text;
}

@end
