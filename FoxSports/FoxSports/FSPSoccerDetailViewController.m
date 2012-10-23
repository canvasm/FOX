//
//  FSPSoccerDetailViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerDetailViewController.h"
#import "FSPSoccerStatsContainerViewController.h"
#import "FSPSoccerPlayByPlayViewController.h"
#import "FSPGame.h"
#import "FSPPlayByPlayViewController.h"

@interface FSPSoccerDetailViewController ()
@property (nonatomic, strong) UIViewController <FSPExtendedEventDetailManaging> *playByPlayViewController;
@property (nonatomic, strong) FSPSoccerStatsContainerViewController *statsContainerViewController;
@end

@implementation FSPSoccerDetailViewController
@synthesize playByPlayViewController = _playByPlayViewController;
@synthesize statsContainerViewController = _statsContainerViewController;

- (NSDictionary *)updatedExtendedInformationDictionary
{
    NSDictionary *baseExtendedInformation = [super updatedExtendedInformationDictionary];
    NSArray *baseExtendedTitles = [baseExtendedInformation objectForKey:FSPExtendedInformationTitlesKey];
    NSArray *baseExtendedViewControllers = [baseExtendedInformation objectForKey:FSPExtendedInformationViewControllersKey];
    
    // Set the tabs by checking for available data.
    FSPGame *game = (FSPGame *)self.event;
    
    NSMutableArray *extendedViewControllers = [NSMutableArray arrayWithArray:baseExtendedViewControllers];
    NSMutableArray *extendedTitles = [NSMutableArray arrayWithArray:baseExtendedTitles];
    
    if ([self.event.eventStarted boolValue] && (game.homeTeamPlayers && game.awayTeamPlayers)) {
		if (!self.playByPlayViewController) {
			self.playByPlayViewController = [[FSPSoccerPlayByPlayViewController alloc] init];
		}
        
        [extendedViewControllers addObjectsFromArray:@[self.statsContainerViewController, self.playByPlayViewController]];
		[extendedTitles addObjectsFromArray:@[@"Stats", @"Plays"]];
	}
    
    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers,
            FSPExtendedInformationTitlesKey: extendedTitles};
}

- (FSPSoccerStatsContainerViewController *)statsContainerViewController
{
    if (!_statsContainerViewController)
        _statsContainerViewController = [[FSPSoccerStatsContainerViewController alloc] init];
    return _statsContainerViewController;
}

@end
