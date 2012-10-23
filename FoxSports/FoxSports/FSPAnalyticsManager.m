//
//  FSPAnalyticsManager.m
//  FoxSports
//
//  Created by Jason Whitford on 1/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPAnalyticsManager.h"

static FSPAnalyticsManager *mSharedInstance;

@implementation FSPAnalyticsManager


+ (FSPAnalyticsManager *)sharedManager;
{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mSharedInstance = [[FSPAnalyticsManager alloc] init];
    });
    
    return mSharedInstance;
}

- (void)trackVideoHeartbeat:(NSString *)heartbeat videoURL:(NSString *)url;
{
    [self trackItem:url forAction:heartbeat];
}

- (void)trackVideoDidPlayForURL:(NSString *)videoURL;
{
    [self trackItem:videoURL forAction:@"video_play"];
}

- (void)trackVideoDidPauseForURL:(NSString *)videoURL;
{
    [self trackItem:videoURL forAction:@"video_pause"];
}

- (void)trackVideoDidFinishForURL:(NSString *)videoURL;
{
    [self trackItem:videoURL forAction:@"video_finish"];
}
- (void)trackItem:(NSString *)item forAction:(NSString *)action;
{
    NSLog(@"FSPAnalyticsManager tracking item {%@} for action {%@}", item, action);
}

@end
