//
//  FSPNHLStatsContainerViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLStatsContainerViewController.h"
#import "FSPNHLPlayerStatsViewController.h"
#import "FSPNHLTeamStatsViewController.h"
#import "FSPEvent.h"

@interface FSPNHLStatsContainerViewController ()

@property (nonatomic, strong) FSPGameStatsViewController *currentStatsController;

@end

@implementation FSPNHLStatsContainerViewController

@synthesize playerStatsViewController = _playerStatsViewController;
@synthesize teamStatsViewController = _teamStatsViewController;
@synthesize currentStatsController = _currentStatsController;
@synthesize lowerContainerView = _lowerContainerView;

- (id)init
{
    self = [super initWithNibName:@"FSPNHLStatsContainerViewController" bundle:nil];
    if (self){
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event
{
	return @[@"Team Stats", @"Player Stats"];
}

- (void)selectGameDetailViewAtIndex:(NSUInteger)index;
{
    [super selectGameDetailViewAtIndex:index];
    
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

- (FSPNHLPlayerStatsViewController *)playerStatsViewController
{
    if (!_playerStatsViewController)
        _playerStatsViewController = [[FSPNHLPlayerStatsViewController alloc] init];
    return _playerStatsViewController;
}

- (FSPNHLTeamStatsViewController *)teamStatsViewController
{
    if (!_teamStatsViewController)
        _teamStatsViewController = [[FSPNHLTeamStatsViewController alloc] init];
    return _teamStatsViewController;
}

@end
