//
//  FSPNASCAREventDetailViewController.m
//  FoxSports
//
//  Created by greay on 7/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCAREventDetailViewController.h"
#import "FSPNASCAREventPreEventViewController.h"
#import "FSPGameHeaderView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPEvent.h"
#import "FSPLeaderboardContainerViewController.h"

@interface FSPNASCAREventDetailViewController()

@property (strong, nonatomic) FSPLeaderboardContainerViewController *leaderboardContainerViewController;

@end

@implementation FSPNASCAREventDetailViewController

@synthesize leaderboardContainerViewController = _leaderboardViewController;

- (Class)preEventViewControllerClass
{
	return [FSPNASCAREventPreEventViewController class];
}

- (void)updateHeaderView;
{
    self.gameHeaderView.eventLocation.text = [self.event valueForKey:@"location"];
    self.gameHeaderView.eventOrganizationName.text = [[self.event.organizations anyObject] name];
    self.gameHeaderView.eventTitle.text = [self.event valueForKey:@"eventTitle"];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    FSPGameHeaderView *gameHeaderView = self.gameHeaderView;
    
    gameHeaderView.homeColor = [UIColor fsp_colorWithIntegralRed:0 green:73 blue:158 alpha:1];
    gameHeaderView.awayColor = [UIColor fsp_colorWithIntegralRed:0 green:73 blue:158 alpha:1];
    gameHeaderView.middleColor = [UIColor fsp_colorWithIntegralRed:50 green:132 blue:225 alpha:1];
    
    gameHeaderView.finalLabel.hidden = YES;
    gameHeaderView.awayScoreLabel.hidden = YES;
    gameHeaderView.homeScoreLabel.hidden = YES;
    gameHeaderView.periodLabel.hidden = YES;
    gameHeaderView.timeLabel.hidden = YES;
    
    gameHeaderView.eventLocation.hidden = NO;
    gameHeaderView.eventLocation.textColor = [UIColor fsp_colorWithIntegralRed:197 green:224 blue:255 alpha:1];
    gameHeaderView.eventLocation.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    gameHeaderView.eventLocation.shadowOffset = CGSizeMake(0, -1);

    gameHeaderView.eventOrganizationName.hidden = NO;
    gameHeaderView.eventOrganizationName.textColor = [UIColor fsp_colorWithIntegralRed:197 green:224 blue:255 alpha:1];
    gameHeaderView.eventOrganizationName.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    gameHeaderView.eventOrganizationName.shadowOffset = CGSizeMake(0, -1);

    gameHeaderView.eventTitle.hidden = NO;
    gameHeaderView.eventTitle.textColor = [UIColor whiteColor];
    gameHeaderView.eventTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    gameHeaderView.eventTitle.shadowOffset = CGSizeMake(0, -1);
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        gameHeaderView.eventLocation.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        gameHeaderView.eventOrganizationName.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        gameHeaderView.eventTitle.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:22];
    } else {
        gameHeaderView.eventLocation.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12];
        gameHeaderView.eventOrganizationName.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12];
        gameHeaderView.eventTitle.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:20];
    }

    [self updateHeaderView];
}

- (void)eventDidChange;
{
    [super eventDidChange];
    [self updateHeaderView];
    [self.leaderboardContainerViewController reloadTableviewsWithEvent:self.event];
}

- (void)eventDidUpdate;
{
    [super eventDidUpdate];
}
    
- (NSDictionary *)updatedExtendedInformationDictionary
{
    NSDictionary *baseExtendedInformation = [super updatedExtendedInformationDictionary];
    NSArray *baseExtendedTitles = [baseExtendedInformation objectForKey:FSPExtendedInformationTitlesKey];
    NSArray *baseExtendedViewControllers = [baseExtendedInformation objectForKey:FSPExtendedInformationViewControllersKey];
    
    if (!self.leaderboardContainerViewController) {
        self.leaderboardContainerViewController = [[FSPLeaderboardContainerViewController alloc] initWithEvent:self.event];
        self.leaderboardContainerViewController.view.frame = self.view.frame;
    }
    
    NSArray *additionalTitles = [self.event.eventCompleted boolValue] ? @[@"Results"] : @[@"Leaderboard"];
    NSArray *additionalViewControllers = @[self.leaderboardContainerViewController];
    NSArray *extendedTitles = [baseExtendedTitles arrayByAddingObjectsFromArray:additionalTitles];
    NSArray *extendedViewControllers = [baseExtendedViewControllers arrayByAddingObjectsFromArray:additionalViewControllers];
    
    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers,
            FSPExtendedInformationTitlesKey: extendedTitles};
}

@end
