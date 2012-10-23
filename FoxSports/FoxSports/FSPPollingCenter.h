//
//  FSPPollingCenter.h
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * FSPTeamsPollingActionKey = @"teams";
static NSString * FSPOrgsPollingActionKey = @"orgs";
static NSString * FSPLiveEngineChipsPollingActionKey = @"LE";
static NSString * FSPMessageBundlePollingActionKey = @"messageBundle";
static NSString * FSPChipsPollingActionKey = @"chips";

@interface FSPPollingCenter : NSObject 

/**
 Returns the default polling center object
 */
+ (id)defaultCenter;

/**
 Returns the number of actions currently in the center
 */
@property (nonatomic, readonly) NSUInteger numberOfActions;

/**
 Add a block to the polling center to be executed at the given interval.
 An FSPPollingAction object is returned that can be used to remove the object, pause and resume it.
 
 The block is executed once it is added and then at the given intervals.
 */
- (NSTimer *)addPollingActionForKey:(NSString *)key timeInterval:(NSTimeInterval)interval usingBlock:(void (^)(void))block;

/**
 Removes the action from the polling center.
 */
- (void)stopPollingActionForKey:(NSString *)key;

@end
