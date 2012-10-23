//
//  FSPSportsNewsContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSportsNewsContainerViewController.h"
#import "FSPDropDownMenuItem.h"
#import "FSPCoreDataManager.h"
#import "FSPSportsNewsViewController.h"
#import "FSPLocalNewsViewController.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"


@interface FSPSportsNewsContainerViewController ()

@end

@implementation FSPSportsNewsContainerViewController


#pragma mark - Memory Management
- (id)init
{
    self = [super init];
    if (self) {
        FSPSportsNewsViewController *controller = [[FSPSportsNewsViewController alloc] initWithOrganization:nil managedObjectContext:[[FSPCoreDataManager sharedManager] GUIObjectContext]];
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        controller.delegate = appDelegate.rootViewController;
        self.subViewController = controller;
    }
    return self;
}


#pragma mark - :: Drop Down Menu ::
- (NSArray *)dropDownSections
{
    return nil;
}

- (NSArray *)dropDownSegments
{
    __weak FSPSportsNewsContainerViewController *weakSelf = self;

    FSPDropDownMenuItem *topNewsItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Top News" selectionAction:^(id sender){
        
        FSPSportsNewsViewController *sportsNewsViewController = [[FSPSportsNewsViewController alloc] initWithOrganization:nil managedObjectContext:[[FSPCoreDataManager sharedManager] GUIObjectContext]];
        
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        sportsNewsViewController.delegate = appDelegate.rootViewController;
        sportsNewsViewController.view.frame = weakSelf.subViewController.view.frame;
        weakSelf.subViewController = sportsNewsViewController;
        
    }];
        
    FSPDropDownMenuItem *localNewsItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Local" selectionAction:^(id sender){
        
        FSPLocalNewsViewController *localNewsViewController = [[FSPLocalNewsViewController alloc] initWithOrganization:nil managedObjectContext:[[FSPCoreDataManager sharedManager] GUIObjectContext]];
        [self addChildViewController:localNewsViewController];
        
        FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        localNewsViewController.delegate = appDelegate.rootViewController;
        localNewsViewController.view.frame = weakSelf.subViewController.view.frame;
        weakSelf.subViewController = localNewsViewController;
        
    }];
    
//	TODO: implement this once we have videos to show
//    FSPDropDownMenuItem *videoItem = [[FSPDropDownMenuItem alloc] initWithMenuTitle:@"Video" selectionAction:^(id sender){
//    }];
    
    NSMutableArray *dropDownSegments = [NSMutableArray arrayWithObjects:topNewsItem, localNewsItem, nil];

    return dropDownSegments;
}

@end
