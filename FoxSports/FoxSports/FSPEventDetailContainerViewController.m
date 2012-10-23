//
//  FSPEventDetailContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventDetailContainerViewController.h"
#import "FSPDropDownMenuItem.h"

#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPRacingEvent.h"
#import "FSPUFCEvent.h"

#import "FSPAlertsViewController.h"
#import "FSPEventDetailViewController.h"
#import "FSPGameDetailViewController.h"
#import "FSPMLBDetailViewController.h"
#import "FSPNASCAREventDetailViewController.h"
#import "FSPNBADetailViewController.h"
#import "FSPNFLDetailViewController.h"
#import "FSPPGADetailViewController.h"
#import "FSPSoccerDetailViewController.h"
#import "FSPUFCDetailViewController.h"
#import "FSPNHLGameDetailViewController.h"
#import "FSPTennisEventDetailViewController.h"

#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"

#import "JREngage+FSPExtensions.h"
#import "JREngage.h"


@interface FSPEventDetailContainerViewController () <JREngageDelegate>

@property (nonatomic, strong) FSPTeam *homeTeam;
@property (nonatomic, strong) FSPTeam *awayTeam;
@property (nonatomic, weak) id favoriteStateObserver;

- (Class)detailViewControllerClassForEvent:(FSPEvent *)event;

@end

@implementation FSPEventDetailContainerViewController {
    NSInteger homeTeamFavoritesIndex;
    NSInteger awayTeamFavoritesIndex;
    BOOL lastEventCompleted;
    BOOL didResetDropdown;
}

#pragma mark - Properties
@synthesize event = _event;


#pragma mark - Custom getters and setters
- (void)setEvent:(FSPEvent *)event
{
	if (_event == event) return;
	
    _event = event;
    
    if ([_event isKindOfClass:[FSPGame class]]) {
        self.homeTeam = [(FSPGame *)self.event homeTeam];
        self.awayTeam = [(FSPGame *)self.event awayTeam];
    } else {
        self.homeTeam = nil;
        self.awayTeam = nil;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Recreate the dropdown in order to add or remove the alerts row
        if ((lastEventCompleted && !self.event.eventCompleted.boolValue)
            ||(!lastEventCompleted && self.event.eventCompleted.boolValue)) {
            [super setupDropdown];
            didResetDropdown = YES;
        }
        lastEventCompleted = self.event.eventCompleted.boolValue;
    }
    
    Class classForEvent = [self detailViewControllerClassForEvent:_event];
    if (classForEvent != [self.subViewController class]) {
        FSPEventDetailViewController *controller = [(FSPEventDetailViewController *)[classForEvent alloc] init];
        controller.event = _event;
        self.subViewController = controller;
    }
    
    ((FSPEventDetailViewController *)self.subViewController).event = event;
	if ([event isKindOfClass:[FSPRacingEvent class]]) {
		self.title = [(FSPRacingEvent *)event eventTitle];
	} else if ([event isKindOfClass:[FSPUFCEvent class]]) {
		self.title = [(FSPUFCEvent *)event eventTitle];
	} else {
		self.title = self.subViewController.title;
	}
}

- (Class)detailViewControllerClassForEvent:(FSPEvent *)event;
{
	switch (event.viewType) {
		case FSPBaseballViewType:
			return [FSPMLBDetailViewController class];
		case FSPBasketballViewType:
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
			return [FSPNBADetailViewController class];
		case FSPGolfViewType:
			return [FSPPGADetailViewController class];
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			return [FSPNFLDetailViewController class];
		case FSPRacingViewType:
			return [FSPNASCAREventDetailViewController class];
		case FSPFightingViewType:
			return [FSPUFCDetailViewController class];
		case FSPHockeyViewType:
            return [FSPNHLGameDetailViewController class];
        case FSPSoccerViewType:
            return [FSPSoccerDetailViewController class];
		case FSPTennisViewType:
			return [FSPTennisEventDetailViewController class];
		default:
			return [FSPEventDetailViewController class];
    }
}


#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // If the dropdown was recreated, it will be extended, which can be
        // out of sync with the previous extended state.  So reposition it correctly.
        // Note that simply calling 
        if (didResetDropdown) {
            CGPoint destinationPoint;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:FSPDropDownExtendedKey]) {
                // Want the menu origin to be at (0,0)
                destinationPoint = CGPointZero;
            } else {
                // want the destinationPoint to be at (0,0)
                destinationPoint = CGPointMake(0, -self.dropDownMenu.sectionsHeight);
            }
            
            CGRect menuFrame = self.dropDownMenu.frame;
            menuFrame.origin = destinationPoint;
            self.dropDownMenu.frame = menuFrame;
            
            // Update the tableview
            CGRect contentFrame;
            CGRectDivide(self.view.bounds, &menuFrame, &contentFrame, CGRectGetMaxY(menuFrame), CGRectMinYEdge);
            self.subViewController.view.frame = contentFrame;
            
            didResetDropdown = NO;
        }
    }

    
    if (self.homeTeam) {
        [self.dropDownMenu updateSectionName:self.homeTeam.longNameDisplayString atIndex:homeTeamFavoritesIndex];
    }

    if (self.awayTeam) {
        [self.dropDownMenu updateSectionName:self.awayTeam.longNameDisplayString atIndex:awayTeamFavoritesIndex];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	if (self.homeTeam || self.awayTeam) {
		__weak id weakSelf = self;
        self.favoriteStateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FSPOrganizationDidUpdateFavoritedStateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            FSPOrganization *updatedOrg = (FSPOrganization *)note.object;
            [weakSelf didChangeFavoritedForOrganization:updatedOrg];
        }];
	}
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.favoriteStateObserver];
    [super viewDidUnload];
}


#pragma mark - :: Drop Down Menu ::
- (NSArray *)dropDownSections
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        NSMutableArray *dropDownSections = [NSMutableArray new];
        __weak FSPEventDetailContainerViewController *weakSelf = self;
        
        FSPDropDownMenuItem *shareItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Share" selectionAction:^(id sender){

            JREngage *janrainEngageClient = [JREngage jrEngageClientWithDelegate:self];
            FSPGame *game = (id)self.event;
            NSString *sharedItemText = [NSString stringWithFormat:@"Sharing %@ event (%@ vs %@)", self.event.branch, game.homeTeam.name, game.awayTeam.name];
            JRActivityObject *activityObject = [JRActivityObject activityObjectWithAction:sharedItemText andUrl:nil];
            [janrainEngageClient showSocialPublishingDialogWithActivity:activityObject];

        }];
        
        [dropDownSections addObject:shareItem];
        

        FSPDropDownMenuItem *alertsItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Event Alerts" selectionAction:^(id sender){
            
            FSPAlertsViewController *vc = [[FSPAlertsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [vc populateWithEvent:self.event];
            
            FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
            if (vc) [appDelegate.rootViewController displayModalViewController:vc animated:YES];
            
        }];
            
        [dropDownSections addObject:alertsItem];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if ([self.event.eventState isEqualToString:@"FINAL"]) {
                [dropDownSections removeObject:alertsItem];
                alertsItem = nil;
            }
        }
        
        if ([self.event isKindOfClass:[FSPGame class]]) {
            
            FSPDropDownMenuItem *homeTeamFavoriteItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:self.homeTeam.longNameDisplayString selectionAction:^(id sender){
                
                BOOL isFavorited = [weakSelf.homeTeam.favorited boolValue];
                [weakSelf.homeTeam updateFavoriteState:!isFavorited];
                
            }];
            
            FSPDropDownMenuItem *awayTeamFavoriteItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:self.awayTeam.longNameDisplayString selectionAction:^(id sender){
                
                BOOL isFavorited = [weakSelf.awayTeam.favorited boolValue];
                [weakSelf.awayTeam updateFavoriteState:!isFavorited];
                
            }];
            
            [dropDownSections addObject:homeTeamFavoriteItem];
            [dropDownSections addObject:awayTeamFavoriteItem];
            
            homeTeamFavoritesIndex = [dropDownSections indexOfObject:homeTeamFavoriteItem];
            awayTeamFavoritesIndex = [dropDownSections indexOfObject:awayTeamFavoriteItem];
            
        } else {
            homeTeamFavoritesIndex = -1;
            awayTeamFavoritesIndex = -1;
        }
        
        return dropDownSections;
        
    }
    
    return nil;
}

- (NSArray *)dropDownSegments
{
    return nil;
}

- (UIImage *)dropDownMenu:(FSPDropDownMenu *)menu iconForSectionAtIndex:(NSInteger)index
{
	if ((index == homeTeamFavoritesIndex && [self.homeTeam.favorited boolValue]) ||
        (index == awayTeamFavoritesIndex && [self.awayTeam.favorited boolValue])) {
		return [UIImage imageNamed:@"star_selected"];
	} else if (index == homeTeamFavoritesIndex || index == awayTeamFavoritesIndex) {
		return [UIImage imageNamed:@"star_non_selected"];
	} else {
        return nil;
    }
}

- (void)didChangeFavoritedForOrganization:(FSPOrganization *)updatedOrg;
{
//    TODO: This method causes a crash if adding a team that is on the currently selected chip; retest after FSTOGOIOS-1713 is fixed.
    if (homeTeamFavoritesIndex > -1 && updatedOrg == self.homeTeam) {
        [self.dropDownMenu reloadSectionAtIndex:homeTeamFavoritesIndex];
    }
    
    if (awayTeamFavoritesIndex > -1 && updatedOrg == self.awayTeam) {
        [self.dropDownMenu reloadSectionAtIndex:awayTeamFavoritesIndex];
    }    
}


#pragma mark Sharing
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

@end
