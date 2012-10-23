//
//  FSPAppDelegate.h
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPRootViewController;

@interface FSPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FSPRootViewController *rootViewController;

- (void)setupRootViewController;

@end

// FSPAppDelegate resets the root view controller when this notification is posted.
// (Sent by FSPCoreDataManager when the settings bundle URL changes)
extern NSString* FSPAppDidResetEnvironmentConfigurationNotification;
