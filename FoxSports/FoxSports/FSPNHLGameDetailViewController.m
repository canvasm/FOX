//
//  FSPNHLGameDetailViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLGameDetailViewController.h"
#import "FSPGame.h"
#import "FSPNHLStatsContainerViewController.h"
#import "FSPPlayByPlayViewController.h"

@interface FSPNHLGameDetailViewController ()

@property (nonatomic, strong) FSPNHLStatsContainerViewController *statsContainerViewController;
@property (nonatomic, strong) FSPPlayByPlayViewController *playByPlayViewController;

@end

@implementation FSPNHLGameDetailViewController

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
        [extendedViewControllers addObjectsFromArray:@[self.statsContainerViewController]];
		[extendedTitles addObjectsFromArray:@[@"Stats"]];
	}
    if ([self.event.eventStarted boolValue] && (game.homeTeamPlayers && game.awayTeamPlayers)) {
        if (!self.playByPlayViewController) {
            self.playByPlayViewController = [[FSPPlayByPlayViewController alloc] init];
        }
        [extendedViewControllers addObject:self.playByPlayViewController];
        [extendedTitles addObject:@"Plays"];
    }
    
    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers, FSPExtendedInformationTitlesKey: extendedTitles};
}

- (FSPNHLStatsContainerViewController *)statsContainerViewController
{
    if (!_statsContainerViewController)
        _statsContainerViewController = [[FSPNHLStatsContainerViewController alloc] initWithNibName:@"FSPNHLStatsContainerViewController" bundle:nil];
    return _statsContainerViewController;
}

@end
