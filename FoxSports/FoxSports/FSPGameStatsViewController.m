//
//  FSPGameStatsViewController.m
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameStatsViewController.h"

#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPPlayer.h"
#import "FSPGamePeriod.h"
#import "FSPGameTopPlayersViewContainer.h"
#import "FSPBoxScoreViewController.h"
#import "FSPLineScoreBox.h"
#import "FSPGameSegmentView.h"
#import "FSPCoreDataManager.h"

typedef enum {
    FSPGameStatsDataEverythingAvailable = 0,
    FSPGameStatsDataPlayerStatsUnavailable,
    FSPGameStatsDataLineScoreUnavailable,
    FSPGameStatsDataNothingAvailable
} FSPGameStatsData;

@interface FSPGameStatsViewController ()

@property  (nonatomic, strong) id eventRefreshObserver;
@property (nonatomic) FSPGameStatsData gameStatsData;
@property (weak, nonatomic) IBOutlet UILabel *noStatsAvailableLabel;

- (void)updateLineScoreBox;

@end

@implementation FSPGameStatsViewController

@synthesize eventRefreshObserver;
@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize boxScoreViewController = _boxScoreViewController;
@synthesize lineScoreContainer;
@synthesize gameStateView;
@synthesize boxScoreContainer = _boxScoreContainer;
@synthesize gameStatsData = _gameStatsData;
@synthesize noStatsAvailableLabel;
@synthesize topPlayersView;

@synthesize lineScoreBox;

#pragma mark Custom getters & setters

+ (Class)boxScoreViewControllerClass {
    return FSPBoxScoreViewController.class;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    if ((_currentEvent != currentEvent) && ([currentEvent isKindOfClass:[FSPGame class]])) {
        _currentEvent = currentEvent;

        if ([self boxScoreViewController]) {
            [[self boxScoreViewController].view removeFromSuperview];
        }
        Class boxScoreViewControllerClass = self.class.boxScoreViewControllerClass;
        if (boxScoreViewControllerClass) {
            NSParameterAssert([boxScoreViewControllerClass isSubclassOfClass:FSPBoxScoreViewController.class]);
            self.boxScoreViewController = [[boxScoreViewControllerClass alloc] initWithGame:(FSPGame *)currentEvent];
            [self.boxScoreContainer addSubview:self.boxScoreViewController.view];
//            self.boxScoreViewController.currentGame = (FSPGame *)currentEvent;
        }
		if (currentEvent.viewType == FSPBasketballViewType || currentEvent.viewType == FSPNCAABViewType || currentEvent.viewType == FSPNCAAWBViewType) {
			if (!self.topPlayersView) self.topPlayersView = [[FSPGameTopPlayersViewContainer alloc] initWithFrame:self.gameStateView.bounds];
			[self.gameStateView addSubview:self.topPlayersView];
		}
        [self updateGameStateInterface];
        [self.lineScoreBox resetGameSegments];
        [self updateInterface];
        
        [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0)];
    }
}

- (NSSet *)allPlayers;
{
    FSPGame *game = (id)self.currentEvent;
    NSSet *homePlayers =  game.homeTeamPlayers;
    NSSet *awayPlayers = game.awayTeamPlayers;
    return [homePlayers setByAddingObjectsFromSet:awayPlayers];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.accessibilityIdentifier = @"gameStats";
    
    
    __weak FSPGameStatsViewController *weakSelf = self;
    self.eventRefreshObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext queue:nil usingBlock:^(NSNotification *note){
        
        NSDictionary *userInfo = [note userInfo];
        NSMutableSet *updatedObjects = [[NSMutableSet alloc] init];
        [updatedObjects unionSet:[userInfo objectForKey:NSUpdatedObjectsKey]];
        [updatedObjects unionSet:[userInfo objectForKey:NSInsertedObjectsKey]];
        [updatedObjects unionSet:[userInfo objectForKey:NSRefreshedObjectsKey]];
        if ([updatedObjects containsObject:weakSelf.currentEvent]) {
            self.currentEvent = (FSPEvent *)[self.managedObjectContext existingObjectWithID:self.currentEvent.objectID error:nil];
            if (self.currentEvent) {
                [self updateInterface];
            }
        }
    }];

	[self createLineScoresBox];

    [self updateGameStateInterface];
    [self.lineScoreBox resetGameSegments];
    
    [self updateInterface];
}

- (void)viewDidUnload
{
    [self setNoStatsAvailableLabel:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.eventRefreshObserver];
    self.eventRefreshObserver = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)createLineScoresBox
{
	self.lineScoreBox = [[FSPLineScoreBox alloc] initWithFrame:self.lineScoreContainer.bounds];
    [self.lineScoreContainer addSubview:self.lineScoreBox];
}

- (void)updateLineScoreBox
{
    FSPGame *game = (id)self.currentEvent;

    [self.lineScoreBox scrollToLatestGameSegment];
    [self updateTotalScoreInterface];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.lineScoreBox.homeTeamLabel.text = game.homeTeam.abbreviation;
        self.lineScoreBox.awayTeamLabel.text = game.awayTeam.abbreviation;
    } else {
        self.lineScoreBox.homeTeamLabel.text = game.homeTeam.longNameDisplayString;
        self.lineScoreBox.awayTeamLabel.text = game.awayTeam.longNameDisplayString;
    }
    
    [self.lineScoreBox setNeedsDisplay];
}

- (void)updateInterface
{    
    self.gameStatsData = FSPGameStatsDataEverythingAvailable;
    
    [self updateLineScoreBox];
    [self updateGameStateInterface];
    
    FSPGame *game = (id)self.currentEvent;
    if (!game.homeTeamScore && !game.awayTeamScore) {
        self.gameStatsData = FSPGameStatsDataLineScoreUnavailable;
    }
    
    if (!game.homeTeamPlayers && !game.awayTeamPlayers) {
        if (self.gameStatsData == FSPGameStatsDataLineScoreUnavailable) {
            self.gameStatsData = FSPGameStatsDataNothingAvailable;
        } else {
            self.gameStatsData = FSPGameStatsDataPlayerStatsUnavailable;
        }
    }
    
    [self.boxScoreViewController reloadTableViews];

    [self layoutStatsViews];
}

- (void)viewWillLayoutSubviews
{
	[self layoutStatsViews];
}

- (void)layoutStatsViews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.view.frame = self.view.superview.bounds;
        if (self.view.frame.size.height > 400) {
            self.view.frame = CGRectMake(0.0, 0.0, 320.0, 264.0); // this is the height of the view after taking into account the team/player stats tabs
        }
    }
    //Section order, vertically: Line score | Top performers | Box score

    CGFloat topMargin = 15.0f;
    switch (_gameStatsData) {
        case FSPGameStatsDataEverythingAvailable:
            self.lineScoreContainer.hidden = NO;
            self.gameStateView.hidden = NO;
            self.boxScoreContainer.hidden = NO;
            self.noStatsAvailableLabel.hidden = YES;
            self.lineScoreContainer.frame = CGRectMake(0.0f, topMargin, self.view.frame.size.width, self.lineScoreBox.frame.size.height);
            self.gameStateView.frame = CGRectMake(0.0f, self.lineScoreContainer.frame.origin.y + self.lineScoreContainer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.gameStateView.frame.origin.y);
            CGSize boxScoreSize = [self.boxScoreViewController sizeForContents];
            if (self.currentEvent.viewType == FSPNFLViewType || self.currentEvent.viewType == FSPNCAAFViewType) {
                self.boxScoreContainer.frame = CGRectMake(0.0f, 0.0f, boxScoreSize.width, boxScoreSize.height);
            } else {
                self.boxScoreContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.lineScoreContainer.frame) + self.gameStateView.frame.size.height, boxScoreSize.width, boxScoreSize.height);
            }
            break;
        case FSPGameStatsDataLineScoreUnavailable:
            self.lineScoreContainer.hidden = YES;
            self.gameStateView.hidden = NO;
            self.boxScoreContainer.hidden = NO;
            self.noStatsAvailableLabel.hidden = YES;
            self.gameStateView.frame = CGRectMake(0.0f, topMargin, self.view.frame.size.width, self.view.frame.size.height);
            self.boxScoreContainer.frame = CGRectMake(0.0f, self.gameStateView.frame.size.height, self.view.frame.size.width, self.boxScoreContainer.frame.size.height);
            break;
        case FSPGameStatsDataPlayerStatsUnavailable:
            self.lineScoreContainer.hidden = NO;
            self.gameStateView.hidden = YES;
            self.boxScoreContainer.hidden = YES;
            self.noStatsAvailableLabel.hidden = YES;
            self.lineScoreContainer.frame = CGRectMake(0.0f, topMargin, self.view.frame.size.width, self.lineScoreBox.frame.size.height);
            break;
        case FSPGameStatsDataNothingAvailable:
            self.lineScoreContainer.hidden = YES;
            self.gameStateView.hidden = YES;
            self.boxScoreContainer.hidden = YES;
            self.noStatsAvailableLabel.hidden = NO;
        default:
            break;
    }
    
    UIScrollView *scrollView = (id)self.view;
    CGSize contentSize = scrollView.contentSize;
    contentSize.height = CGRectGetMaxY(self.boxScoreContainer.frame);
    scrollView.contentSize = contentSize;
}

- (void)updateGameStateInterface
{
    
}

- (void)updateTotalScoreInterface
{
	
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}


#pragma mark - UITableViewDelegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return nil;
}


@end
