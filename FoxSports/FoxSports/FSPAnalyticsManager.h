//
//  FSPAnalyticsManager.h
//  FoxSports
//
//  Created by Jason Whitford on 1/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPAnalyticsManager : NSObject
+ (FSPAnalyticsManager *)sharedManager;
- (void)trackItem:(NSString *)item forAction:(NSString *)action;
- (void)trackVideoHeartbeat:(NSString *)heartbeat videoURL:(NSString *)url;
- (void)trackVideoDidPlayForURL:(NSString *)videoURL;
- (void)trackVideoDidPauseForURL:(NSString *)videoURL;
@end
