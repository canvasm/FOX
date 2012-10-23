//
//  FSPMLBDetailViewController.m
//  FoxSports
//
//  Created by Laura Savino on 4/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBDetailViewController.h"
#import "FSPGamePreGameViewController.h"
#import "FSPStoryViewController.h"
#import "FSPMLBStatsViewController.h"
#import "FSPEvent.h"
#import "FSPGame.h"

#import "FSPPlayByPlayViewController.h"

#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

#import "FSPMLBGameTraxViewController.h"
#import "FSPMLBDNAView.h"

@interface FSPMLBDetailViewController ()

@property (nonatomic, strong) FSPMLBStatsViewController *statsViewController;
//@property (nonatomic, strong) UIViewController <FSPExtendedEventDetailManaging> *playByPlayViewController;
@property (nonatomic, strong) FSPMLBGameTraxViewController *gameTraxViewController;
@property (nonatomic, strong) FSPMLBDNAView *dnaController;

@end

@implementation FSPMLBDetailViewController
@synthesize statsViewController = _statsViewController;
//@synthesize playByPlayViewController;
@synthesize gameTraxViewController;
@synthesize dnaController;

#pragma mark Custom getters & setters

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
//        if (!self.playByPlayViewController) {
//            self.playByPlayViewController = [[FSPPlayByPlayViewController alloc] init];
//        }
        if (!self.gameTraxViewController) {
            self.gameTraxViewController = [[FSPMLBGameTraxViewController alloc] initWithNibName:@"FSPMLBGameTraxViewController" bundle:nil];
        }
        [extendedViewControllers addObjectsFromArray:@[self.statsViewController, self.gameTraxViewController]];
        [extendedTitles addObjectsFromArray:@[@"Stats", @"GameTrax"]];
    }

    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers,
            FSPExtendedInformationTitlesKey: extendedTitles};
}

- (FSPMLBStatsViewController *)statsViewController
{
    if (!_statsViewController)
        _statsViewController = [[FSPMLBStatsViewController alloc] init];
    return _statsViewController;
}

- (void) toggleFullScreenButtonPressed
{
//    //get the app delegate so we can start the animations
//    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
//	[appDelegate.rootViewController toggleFullScreenMode:YES];

    FSPRootViewController *rootView = [FSPRootViewController rootViewController];
    UIView *rootDNA = [FSPRootViewController rootDNAView];

    if (rootView.isInFullScreenMode)
    {
        [rootView exitFullScreenMode:YES];

        if (rootDNA)
        {
            rootDNA.hidden = YES;

            if (dnaController)
            {
                //remove and dealocate
                [dnaController removeFromSuperview];
                dnaController = nil;
            }
        }
    }
    else
    {
        //create the DNA view
        if (rootDNA)
        {
            rootDNA.hidden = NO;
            [rootView enterFullScreenMode:YES];

            if (!dnaController)
            {
                dnaController = [[FSPMLBDNAView alloc] initWithFrame:rootDNA.frame]; //had to do initwithframe instead of init to get view to recieve input
                [rootDNA addSubview:dnaController];
            }
        }
    }
}


@end
