//
//  FSPUFCDetailViewController.m
//  FoxSports
//
//  Created by greay on 6/5/12.
//  Copyright (c) 2012 Ãbermind. All rights reserved.
//

#import "FSPUFCDetailViewController.h"

#import "FSPEvent.h"

#import "FSPExtendedEventDetailManaging.h"
#import "FSPUFCPreEventViewController.h"
#import "FSPGameHeaderView.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

#import "FSPUFCFightTraxViewController.h"

#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

#import "FSPUFCDNAView.h"

@interface FSPUFCDetailViewController ()

@property (nonatomic, strong) UIViewController <FSPExtendedEventDetailManaging> *playByPlayViewController;
@property (nonatomic, strong)FSPUFCDNAView *dnaController;

//ADDED BY PAT
@property (nonatomic, strong) FSPUFCFightTraxViewController *fightTraxViewController;

@end

@implementation FSPUFCDetailViewController

@synthesize playByPlayViewController;
@synthesize fightTraxViewController = _fightTraxViewController;
@synthesize dnaController;

//create new one if nil
- (FSPUFCFightTraxViewController *)fightTraxViewController
{
    if (!_fightTraxViewController)
        _fightTraxViewController = [[FSPUFCFightTraxViewController alloc] init];
    return _fightTraxViewController;
}

- (void)displayShareOptions;
{
}

- (Class)preEventViewControllerClass
{
    return [FSPUFCPreEventViewController class];
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

    [gameHeaderView.toggleFullScreenButton addTarget:self action:@selector(toggleFullScreenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    gameHeaderView.toggleFullScreenButton.hidden = NO;
    
    [self updateHeaderView];
}

- (void) toggleFullScreenButtonPressed
{
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
                
                [self.gameHeaderView.toggleFullScreenButton setTitle:@"GAME MODE" forState:UIControlStateNormal];
                [self.gameHeaderView.toggleFullScreenButton setBackgroundImage:[UIImage imageNamed:@"game_mode_button"] forState:UIControlStateNormal];
                [self.gameHeaderView.toggleFullScreenButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
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
                dnaController = [[FSPUFCDNAView alloc] initWithFrame:rootDNA.frame]; //had to do initwithframe instead of init to get view to recieve input
                [rootDNA addSubview:dnaController];
                
                [self.gameHeaderView.toggleFullScreenButton setTitle:@"Exit\nGAME MODE" forState:UIControlStateNormal];
                [self.gameHeaderView.toggleFullScreenButton setBackgroundImage:[UIImage imageNamed:@"game_mode_exit_button"] forState:UIControlStateNormal];
                [self.gameHeaderView.toggleFullScreenButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 0)];
            }
        }
    }
}

- (NSDictionary *)updatedExtendedInformationDictionary
{
    NSDictionary *baseExtendedInformation = [super updatedExtendedInformationDictionary];
    NSArray *baseExtendedTitles = [baseExtendedInformation objectForKey:FSPExtendedInformationTitlesKey];
    NSArray *baseExtendedViewControllers = [baseExtendedInformation objectForKey:FSPExtendedInformationViewControllersKey];
    
    NSArray *additionalTitles = @[@"Fights"];
    
    NSArray *additionalViewControllers = @[self.storyViewController];
    
	if ([self.event viewType] != FSPNCAAWBViewType) {
		additionalTitles = [additionalTitles arrayByAddingObject:@"FightTrax"];
        additionalViewControllers = [additionalViewControllers arrayByAddingObject:self.fightTraxViewController];
	}
    
    NSArray *extendedTitles = [baseExtendedTitles arrayByAddingObjectsFromArray:additionalTitles];
    
    NSArray *extendedViewControllers = [baseExtendedViewControllers arrayByAddingObjectsFromArray:additionalViewControllers];
    
    return @{FSPExtendedInformationViewControllersKey: extendedViewControllers, FSPExtendedInformationTitlesKey: extendedTitles};
}

- (void)eventDidChange;
{
    [super eventDidChange];
    [self updateHeaderView];
}


- (void)eventDidUpdate;
{
    [super eventDidUpdate];
    
    if ([(id)[self pregameViewController] respondsToSelector:@selector(eventDidUpdate)])
        [(id)[self pregameViewController] eventDidUpdate];
    
}

- (BOOL)recapIsPreview;
{
    return YES;
}

@end
