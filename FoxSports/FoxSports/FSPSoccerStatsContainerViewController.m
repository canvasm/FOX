//
//  FSPSoccerStatsContainerViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerStatsContainerViewController.h"
#import "FSPSoccerMatchStatsViewController.h"
#import "FSPSoccerPlayerStatsViewController.h"

#import "FSPSoccerGame.h"

@interface FSPSoccerStatsContainerViewController ()
@property (nonatomic, strong) FSPGameStatsViewController *currentStatsController;
@property (nonatomic, strong) NSArray *segmentTitles;
@end

@implementation FSPSoccerStatsContainerViewController


- (NSArray *)segmentTitlesForEvent:(FSPSoccerGame *)event
{
	if (!_segmentTitles) {
		NSInteger coverageLevel = [event.coverageLevel integerValue];
		if (coverageLevel == 2 || coverageLevel == 3) {
			_segmentTitles = @[@"Match Stats"];
		} else {
			_segmentTitles = @[@"Match Stats", @"Player Stats"];
		}
	}
	return _segmentTitles;
}


- (id)init
{
    self = [super initWithNibName:@"FSPSoccerStatsContainerViewController" bundle:nil];
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
	        
    [self.currentStatsController willMoveToParentViewController:nil];
    [self.currentStatsController.view removeFromSuperview];
    [self.currentStatsController removeFromParentViewController];

    if (index == 0) {
        self.currentStatsController = self.matchStatsViewController;
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

- (FSPSoccerPlayerStatsViewController *)playerStatsViewController
{
    if (!_playerStatsViewController)
        _playerStatsViewController = [[FSPSoccerPlayerStatsViewController alloc] init];
    return _playerStatsViewController;
}

- (FSPSoccerMatchStatsViewController *)matchStatsViewController
{
    if (!_matchStatsViewController) {
        _matchStatsViewController = [[FSPSoccerMatchStatsViewController alloc] init];
    }
    return _matchStatsViewController;
}

@end
