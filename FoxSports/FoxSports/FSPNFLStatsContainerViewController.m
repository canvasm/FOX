//
//  FSPNFLStatsContainerViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLStatsContainerViewController.h"

#import "FSPNFLTeamStatsViewController.h"
#import "FSPNFLPlayerStatsViewController.h"

#import "FSPEvent.h"

@interface FSPNFLStatsContainerViewController ()
@property (nonatomic, strong) FSPGameStatsViewController *currentStatsController;
@end

@implementation FSPNFLStatsContainerViewController

@synthesize teamStatsViewController = _teamStatsViewController;
@synthesize playerStatsViewController = _playerStatsViewController;
@synthesize currentStatsController = _currentStatsController;
@synthesize lowerContainerView = _lowerContainerView;

- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event
{
	return @[@"Team Stats", @"Player Stats"];
}


- (id)init
{
    self = [super initWithNibName:@"FSPNFLStatsContainerViewController" bundle:nil];
    if (self){
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)selectGameDetailViewAtIndex:(NSUInteger)index;
{
    [super selectGameDetailViewAtIndex:index];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.lowerContainerView.frame = CGRectMake(0, 0, 320.0, 300.0);
    }
	        
    [self.currentStatsController willMoveToParentViewController:nil];
    [self.currentStatsController.view removeFromSuperview];
    [self.currentStatsController removeFromParentViewController];

    if (index == 0) {
        self.currentStatsController = self.teamStatsViewController;
    }
    else {
        self.currentStatsController = self.playerStatsViewController;
    }
        
    self.currentStatsController.managedObjectContext = self.currentEvent.managedObjectContext;
    if (self.lowerContainerView) {
        self.currentStatsController.view.frame = self.lowerContainerView.bounds;
    }
    
    [self addChildViewController:self.currentStatsController];
    [self.currentStatsController didMoveToParentViewController:self];
    [self.lowerContainerView addSubview:self.currentStatsController.view];
    self.currentStatsController.currentEvent = self.currentEvent;
    [self.currentStatsController.view setNeedsLayout];
    
    // Update the event and moc for the view controllers
    if (![self.currentStatsController conformsToProtocol:@protocol(FSPExtendedEventDetailManaging)]) {
        [NSException raise:@"Does not conform to protocol" format:@"%@ must conform to the FSPEventDetailLoading protocol", self.currentStatsController];
    }
}

- (FSPNFLTeamStatsViewController *)teamStatsViewController
{
    if (!_teamStatsViewController)
        _teamStatsViewController = [[FSPNFLTeamStatsViewController alloc] init];
    return _teamStatsViewController;
}

- (FSPNFLPlayerStatsViewController *)playerStatsViewController
{
    if (!_playerStatsViewController)
        _playerStatsViewController = [[FSPNFLPlayerStatsViewController alloc] init];
    return _playerStatsViewController;
}

@end
