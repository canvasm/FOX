//
//  FSPAllMyEventsContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPAllMyEventsContainerViewController.h"
#import "FSPAllMyEventsViewController.h"
#import "FSPDropDownMenuItem.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "FSPScheduleViewController.h"
#import "FSPCoreDataManager.h"


@interface FSPAllMyEventsContainerViewController ()

@end

@implementation FSPAllMyEventsContainerViewController


#pragma mark - Memory Management
- (id)init
{
    self = [super init];
    if (self) {
        FSPAllMyEventsViewController *controller = [[FSPAllMyEventsViewController alloc] initWithOrganization:nil 
                                                                                         managedObjectContext:[[FSPCoreDataManager sharedManager] GUIObjectContext]];
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
    return nil;
}

@end
