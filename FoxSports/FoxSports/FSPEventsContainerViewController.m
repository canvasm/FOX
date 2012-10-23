//
//  FSPEventsContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/3/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventsContainerViewController.h"
#import "FSPOrganization.h"
#import "FSPTeam.h"
#import "FSPDropDownMenuItem.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "FSPOrganizationNewsViewController.h"
#import "FSPStandingsViewController.h"
#import "FSPTeamScheduleViewController.h"

#import "FSPConferencesModalViewController.h"

@interface FSPEventsContainerViewController ()

@property (nonatomic, strong) UIPopoverController *popover;

- (void)didChangeFavorited;

@end

@implementation FSPEventsContainerViewController{
    NSInteger favoritesIndex;
}

#pragma mark - Properties
@synthesize organization = _organization;


#pragma mark - Custom getters and setters
- (NSString *)addRemoveFavoritesString
{
    NSString *returnString;
    if (self.organization.favorited.boolValue)
        returnString = @"Remove From Favorites";
    else 
        returnString = @"Add To Favorites";
    return returnString;
}

- (NSString *)standingsString;
{
    NSString *returnString;
    if ([self.organization.branch isEqualToString:@"UFC"])
        returnString = @"Titleholders";
    else 
        returnString = @"Standings";
    return returnString;
}


#pragma mark - Memory Management
- (id)initWithOrganization:(FSPOrganization *)organization
{
    self = [super init];
    if (self) {
        self.organization = organization;

        FSPEventsViewController *controller = [[FSPEventsViewController alloc] 
                                               initWithOrganization:organization 
                                               managedObjectContext:organization.managedObjectContext];
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        controller.delegate = appDelegate.rootViewController;
        self.subViewController = controller;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.subViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	if (self.organization) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFavorited) name:FSPOrganizationDidUpdateFavoritedStateNotification object:nil];
	}
	
	[self.subViewController viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


#pragma mark - :: Drop Down Menu ::
- (NSArray *)dropDownSections
{
    __weak FSPEventsContainerViewController *weakSelf = self;

    FSPDropDownMenuItem *standingsItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:[self standingsString] selectionAction:^(id sender){
        
        FSPStandingsViewController *vc = [[FSPStandingsViewController alloc] initWithOrganization:weakSelf.organization 
                                                                             managedObjectContext:weakSelf.organization.managedObjectContext];
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        if (vc) [appDelegate.rootViewController displayModalViewController:vc animated:YES];
        
    }];
    
    FSPDropDownMenuItem *scheduleItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Schedule" selectionAction:^(id sender){
        
        UIViewController *vc = nil;
        if ([weakSelf.organization isKindOfClass:[FSPTeam class]]) {
            vc = [FSPTeamScheduleViewController scheduleViewControllerWithOrganization:weakSelf.organization 
                                                                  managedObjectContext:weakSelf.organization.managedObjectContext];
        } else {
            vc = [FSPScheduleViewController scheduleViewControllerWithOrganization:weakSelf.organization 
                                                              managedObjectContext:weakSelf.organization.managedObjectContext];
        }
        
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        if (vc) [appDelegate.rootViewController displayModalViewController:vc animated:YES];
        
    }];
    
    FSPDropDownMenuItem *alertItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Alerts" selectionAction:^(id sender){
        
        // TODO
        
    }];
    
    FSPDropDownMenuItem *favoriteItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:[self addRemoveFavoritesString] selectionAction:^(id sender){
        
        BOOL isFavorited = [weakSelf.organization.favorited boolValue];
        [weakSelf.organization updateFavoriteState:!isFavorited];
        
    }];
    
	FSPDropDownMenuItem * browseItem = nil;
	if ([weakSelf.organization isKindOfClass:[FSPTeam class]]) {

	} else if ([weakSelf.organization.allChildren count]) {
        
        NSString *menuTitle = [NSString stringWithFormat:@"View a %@", [weakSelf.organization organizationSingleTypeString]];
        for (FSPOrganization *child in weakSelf.organization.children) {
            if ([child.type isEqualToString:FSPOrganizationConferenceType]) {
                menuTitle = [NSString stringWithFormat:@"%@ or Conference", menuTitle];
                break;
            }
        }
        
		browseItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:menuTitle selectionAction:^(id sender){
			void (^completion)(FSPOrganization *) = ^(FSPOrganization *organization) {
				FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
				[appDelegate.rootViewController organizationsViewController:nil didSelectNewOrganization:organization];
				
				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
					[self.popover dismissPopoverAnimated:YES];
				} else {
					[self dismissModalViewControllerAnimated:YES];
				}
			};
			
			NSSet *orgs = [self.organization.children setByAddingObjectsFromSet:[self.organization nonEventTeams]];
			FSPConferencesModalViewController *confrencesViewController = [[FSPConferencesModalViewController alloc] initWithOrganizations:orgs
																														 includeTournamets:YES
																																	 style:UITableViewStyleGrouped
																												selectionCompletionHandler:completion];
			confrencesViewController.title = [self.organization name];
			confrencesViewController.includeTeams = YES;
			confrencesViewController.selectedConference = nil;
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:confrencesViewController];
			navController.navigationBar.barStyle = UIBarStyleBlack;
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				self.popover = [[UIPopoverController alloc] initWithContentViewController:navController];
				[self.popover presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
			} else {
				UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelModal:)];
				confrencesViewController.navigationItem.rightBarButtonItem = closeItem;
				
				[self presentModalViewController:navController animated:YES];
			}
		}];
	}
    
    NSMutableArray * dropDownSections = [NSMutableArray array];
	if (![self.organization.type isEqualToString:FSPOrganizationTournamentType] && (![self.organization isVirtualConference] || [self.organization isTop25])) {
		[dropDownSections addObject:standingsItem];
	}
    
    if ((![self.organization isVirtualConference])) {
		[dropDownSections addObject:scheduleItem];
	}
    
    [dropDownSections addObjectsFromArray:@[alertItem]];
    
    if ([self.organization.selectable boolValue]) {
        [dropDownSections addObject:favoriteItem];
    }
    
    if ([dropDownSections indexOfObject:favoriteItem] != NSNotFound) {
         favoritesIndex = [dropDownSections indexOfObject:favoriteItem];
    }
    
	if (browseItem) {
		[dropDownSections addObject:browseItem];
	}
	
    return dropDownSections;
}

- (void)cancelModal:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSArray *)dropDownSegments
{
    
    NSString *scoreTitle = @"Scores";
    if ([self.organization.name isEqualToString:@"UFC"]) {
        scoreTitle = @"Fights";
    }
    
    __weak FSPEventsContainerViewController *weakSelf = self;
    
    FSPDropDownMenuItem *scoresItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:scoreTitle selectionAction:^(id sender){
        
        FSPEventsViewController *eventsViewController = [[FSPEventsViewController alloc] initWithOrganization:weakSelf.organization
                                                                                         managedObjectContext:weakSelf.organization.managedObjectContext];
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        eventsViewController.delegate = appDelegate.rootViewController;
        eventsViewController.view.frame = weakSelf.subViewController.view.frame;
        [weakSelf setSubViewController:eventsViewController];
        
    }];

    NSMutableArray *dropDownSegments = [NSMutableArray arrayWithObjects:scoresItem, nil];
    
    if (self.organization.hasNews.boolValue) {

        FSPDropDownMenuItem *newsItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"News" selectionAction:^(id sender){
            
            FSPOrganizationNewsViewController *eventNewsViewController = [[FSPOrganizationNewsViewController alloc] initWithOrganization:weakSelf.organization 
                                                                                                      managedObjectContext:weakSelf.organization.managedObjectContext];
            FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
            eventNewsViewController.delegate = appDelegate.rootViewController;
            eventNewsViewController.view.frame = weakSelf.subViewController.view.frame;
            [weakSelf setSubViewController:eventNewsViewController];
            
        }];
        
        [dropDownSegments addObject:newsItem];
    }
    
    return dropDownSegments;
}

- (UIImage *)dropDownMenu:(FSPDropDownMenu *)menu iconForSectionAtIndex:(NSInteger)index
{
	BOOL isFavorited = [self.organization.favorited boolValue];
	if (index == favoritesIndex && isFavorited) {
		return [UIImage imageNamed:@"drop_down_menu_star"];
	} else {
		return nil;
	}
}

- (void)didChangeFavorited;
{
    if (favoritesIndex > -1) {
        [self.dropDownMenu updateSectionName:[self addRemoveFavoritesString] atIndex:favoritesIndex];
    }
}

@end
