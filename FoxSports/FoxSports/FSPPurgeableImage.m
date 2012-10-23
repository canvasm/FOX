//
//  FSPPurgeableImage.m
//  FoxSports
//
//  Created by Chase Latta on 4/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPurgeableImage.h"
#import "FSPPlayer.h"
#import "NSHTTPURLResponse+FSPExtensions.h"
#import "FSPCoreDataManager.h"

@implementation FSPPurgeableImage

@dynamic backingData;
@dynamic expirationDate;
@dynamic url;
@dynamic isExpired;

- (BOOL)isExpired {
    BOOL expired = YES;
    if (self.expirationDate) {
        NSDate *now = [NSDate date];
        NSComparisonResult result = [now compare:self.expirationDate];
        if (result == NSOrderedAscending) {
            expired = NO;
        }
    }
    return expired;
}

@end
