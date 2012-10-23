//
//  FSPNBADetailViewController.m
//  FoxSports
//
//  Created by Chase Latta on 1/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBADetailViewController.h"
#import "FSPNBAStatViewController.h"
#import "FSPGamePreGameViewController.h"
#import "FSPPlayByPlayViewController.h"
#import "FSPStoryViewController.h"
#import "FSPRootViewController.h"
#import "FSPNBAStatViewController.h"
#import "FSPEvent.h"


@interface FSPNBADetailViewController ()

@property (nonatomic, strong) FSPNBAStatViewController *statsViewController;
@property (nonatomic, strong) FSPPlayByPlayViewController *playByPlayViewController;

@end

@implementation FSPNBADetailViewController

@synthesize statsViewController = _statsViewController;
@synthesize playByPlayViewController = _playByPlayViewController;

- (FSPGameStatsViewController *)statsViewController
{
    if (!_statsViewController)
        _statsViewController = [[FSPNBAStatViewController alloc] init];
    return _statsViewController;
}

- (FSPPlayByPlayViewController *)playByPlayViewController
{
    if (!_playByPlayViewController)
        _playByPlayViewController = [[FSPPlayByPlayViewController alloc] init];
    return _playByPlayViewController;
}

- (NSDictionary *)updatedExtendedInformationDictionary
{
    NSDictionary *baseExtendedInformation = [super updatedExtendedInformationDictionary];
    NSArray *baseExtendedTitles = [baseExtendedInformation objectForKey:FSPExtendedInformationTitlesKey];
    NSArray *baseExtendedViewControllers = [baseExtendedInformation objectForKey:FSPExtendedInformationViewControllersKey];

    NSArray *additionalTitles = @[@"Stats"];
    NSArray *additionalViewControllers = @[self.statsViewController];
	if ([self.event viewType] != FSPNCAAWBViewType) {
		additionalTitles = [additionalTitles arrayByAddingObject:@"Plays"];
		additionalViewControllers = [additionalViewControllers arrayByAddingObject:self.playByPlayViewController];
	}
    NSArray *extendedTitles = [baseExtendedTitles arrayByAddingObjectsFromArray:additionalTitles];
    NSArray *extendedViewControllers = [baseExtendedViewControllers arrayByAddingObjectsFromArray:additionalViewControllers];

    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers,
            FSPExtendedInformationTitlesKey: extendedTitles};
}


@end
