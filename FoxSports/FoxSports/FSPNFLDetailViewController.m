//
//  FSPNFLDetailViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLDetailViewController.h"
#import "FSPGame.h"
#import "FSPNFLStatsContainerViewController.h"
#import "FSPPlayByPlayViewController.h"

@interface FSPNFLDetailViewController ()
@property (nonatomic, strong) FSPNFLStatsContainerViewController *statsContainerViewController;
@property (nonatomic, strong) UIViewController <FSPExtendedEventDetailManaging> *playByPlayViewController;
@end

@implementation FSPNFLDetailViewController

@synthesize statsContainerViewController = _statsContainerViewController;
@synthesize playByPlayViewController;

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
			self.playByPlayViewController = [[FSPPlayByPlayViewController alloc] init];
		}

        [extendedViewControllers addObjectsFromArray:@[self.statsContainerViewController, self.playByPlayViewController]];
		[extendedTitles addObjectsFromArray:@[@"Stats", @"Plays"]];
	}
    
    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers,
            FSPExtendedInformationTitlesKey: extendedTitles};
}

- (FSPNFLStatsContainerViewController *)statsContainerViewController
{
    if (!_statsContainerViewController)
        _statsContainerViewController = [[FSPNFLStatsContainerViewController alloc] initWithNibName:@"FSPNFLStatsContainerViewController" bundle:nil];
    return _statsContainerViewController;
}

@end
