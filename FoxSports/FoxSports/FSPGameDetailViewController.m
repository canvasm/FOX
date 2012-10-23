//
//  FSPGameDetailViewController.m
//  FoxSports
//
//  Created by Chase Latta on 1/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailViewController.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPBasketballGame.h"
#import "FSPBasketballPlayer.h"
#import "FSPGamePeriod.h"
#import "FSPGameSegmentView.h"
#import "FSPRootViewController.h"
#import "FSPSegmentedNavigationControl.h"

#import "FSPTeamRecord.h"
#import "FSPGameHeaderView.h"
#import "FSPGamePreGameViewController.h"

#import "FSPExtendedeventDetailManaging.h"
#import "JREngage+FSPExtensions.h"
#import "JREngage.h"

#import "FSPDataCoordinator.h"
#import "FSPLiveEngineClient.h"

#import "UIColor+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"
#import "FSPImageFetcher.h"

@interface FSPGameDetailViewController ()<JREngageDelegate>

@property(nonatomic, assign)BOOL didRecieveInitialUpdate;

- (void)toggleFullScreenButtonPressed;
- (void)updateHeaderAccessibilityLabel;
- (void)updateLabelsForCurrentEvent;
- (void)updateEvent;
- (void)updateGameHeader:(BOOL)updateLogos;
- (void)displayShareOptions;

@end

@implementation FSPGameDetailViewController

@synthesize didRecieveInitialUpdate =  _didRecieveInitialUpdate;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.didRecieveInitialUpdate) {
        [self updateLabelsForCurrentEvent];
    }

    [self updateGameHeader:YES];
}


- (void)toggleFullScreenButtonPressed;
{
    NSString *noteToListenFor;
    if (self.fsp_rootViewController.isInFullScreenMode)
        noteToListenFor = FSPRootViewControllerDidTransitionFromFullScreenNotification;
    else
        noteToListenFor = FSPRootViewControllerDidTransitionToFullScreenNotification;

    __weak FSPGameDetailViewController *weakSelf = self;
    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:noteToListenFor object:self.fsp_rootViewController queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([note.name isEqualToString:FSPRootViewControllerDidTransitionToFullScreenNotification]) {
			[weakSelf.gameHeaderView.toggleFullScreenButton setTitle:@"EXIT\nGAME MODE" forState:UIControlStateNormal];
            weakSelf.gameHeaderView.toggleFullScreenButton.titleLabel.textAlignment = UITextAlignmentCenter;
            [weakSelf.gameHeaderView.toggleFullScreenButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 0)];


			[weakSelf.gameHeaderView.toggleFullScreenButton setBackgroundImage:[UIImage imageNamed:@"game_mode_exit_button"] forState:UIControlStateNormal];
        } else {
			[weakSelf.gameHeaderView.toggleFullScreenButton setTitle:@"GAME MODE" forState:UIControlStateNormal];
			[weakSelf.gameHeaderView.toggleFullScreenButton setBackgroundImage:[UIImage imageNamed:@"game_mode_button"] forState:UIControlStateNormal];
            [weakSelf.gameHeaderView.toggleFullScreenButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

        }

        [[NSNotificationCenter defaultCenter] removeObserver:observer]; 
    }];

    [self.fsp_rootViewController toggleFullScreenMode:YES];
}

#pragma mark - Container Support


#pragma mark - Event Management
- (void)eventDidUpdate;
{
    [super eventDidUpdate];
    [self updateEvent];
    [self updateGameHeader:NO];
}

- (void)eventDidChange;
{
    [super eventDidChange];
    [self updateEvent];
    FSPTeam *homeTeam = [(FSPGame *)[self event] homeTeam];
    FSPTeam *awayTeam = [(FSPGame *)[self event] awayTeam];
    self.title = [NSString stringWithFormat:@"%@ vs %@", awayTeam.shortNameDisplayString, homeTeam.shortNameDisplayString];
    [self updateGameHeader:YES];
}

- (void)updateEvent;
{
    if (self.event && [self.event isKindOfClass:[FSPGame class]]) {
        self.didRecieveInitialUpdate = YES;
        if (self.isViewLoaded) {
            [self updateLabelsForCurrentEvent];
        }
    }
}

- (void)updateGameHeader:(BOOL)updateLogos;
{
	[self.gameHeaderView populateWithGame:(FSPGame *)self.event updateLogos:updateLogos];

	[self.gameHeaderView setNeedsDisplay];
}

- (void)updateLabelsForCurrentEvent;
{
	[self.gameHeaderView updateLabelsWithGame:(FSPGame *)self.event];
    [self updateHeaderAccessibilityLabel];
    [self.navigationView setNeedsDisplay];
}

#pragma mark Sharing
- (void)displayShareOptions;
{
    JREngage *janrainEngageClient = [JREngage jrEngageClientWithDelegate:self];
    FSPGame *game = (id)self.event;
    NSString *sharedItemText = [NSString stringWithFormat:@"Sharing %@ event (%@ vs %@)", self.event.branch, game.homeTeam.name, game.awayTeam.name];
    JRActivityObject *activityObject = [JRActivityObject activityObjectWithAction:sharedItemText andUrl:nil];
    [janrainEngageClient showSocialPublishingDialogWithActivity:activityObject];

//    [janrainEngageClient showAuthenticationDialog];
}

- (void)jrAuthenticationDidFailWithError:(NSError*)error forProvider:(NSString*)provider;
{
    NSLog(@"Sharing authentication error for %@:\n%@", provider, error);
}

//- (void)jrSocialDidNotCompletePublishing { }
//
//- (void)jrSocialDidCompletePublishing { }
//
//- (void)jrSocialDidPublishActivity:(JRActivityObject*)activity
//                       forProvider:(NSString*)provider { }
//
- (void)jrSocialPublishingActivity:(JRActivityObject*)activity didFailWithError:(NSError*)error forProvider:(NSString*)provider;
{
    NSLog(@"Sharing publishing error for %@:\n%@", provider, error);
}


- (void)updateHeaderAccessibilityLabel;
{
    FSPGame *game = (FSPGame *)self.event;
    FSPTeam *homeTeam = game.homeTeam;
    FSPTeam *awayTeam = game.awayTeam;
    NSString *homeConferenceRankingString = [NSString stringWithFormat:@"%@ in conference", homeTeam.conferenceRanking];
    NSString *awayConferenceRankingString = [NSString stringWithFormat:@"%@ in conference", awayTeam.conferenceRanking];
    NSString *label = [NSString stringWithFormat:@"%@ versus %@, %@, on channel %@, %@ record %d and %d, %@, %@ record %d and %d, %@", homeTeam.name, awayTeam.name, self.event.timeStatus, self.event.channelDisplayName, homeTeam.name, [homeTeam.overallRecord.wins integerValue], [homeTeam.overallRecord.losses integerValue], homeConferenceRankingString, awayTeam.name, [awayTeam.overallRecord.wins integerValue], [awayTeam.overallRecord.losses integerValue], awayConferenceRankingString];
    self.headerView.accessibilityLabel = label;
}

- (Class)preEventViewControllerClass
{
    return [FSPGamePreGameViewController class];
}

@end

