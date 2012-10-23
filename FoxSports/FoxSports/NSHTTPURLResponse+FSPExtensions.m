//
//  NSHTTPURLResponse+FSPExtensions.m
//  FoxSports
//
//  Created by Chase Latta on 4/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "NSHTTPURLResponse+FSPExtensions.h"

@implementation NSHTTPURLResponse (FSPExtensions)

- (NSTimeInterval)fsp_cacheDuration;
{
    NSTimeInterval interval = 0;
    NSDictionary *headers = [self allHeaderFields];
    NSString *cacheHeader = [headers objectForKey:@"Cache-Control"];
    if (cacheHeader) {
        static NSRegularExpression *regex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            regex = [NSRegularExpression regularExpressionWithPattern:@"max-age=(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil];
        });
        NSTextCheckingResult *result = [regex firstMatchInString:cacheHeader options:0 range:NSMakeRange(0, [cacheHeader length])];
        if (result.numberOfRanges >= 1) {
            NSRange captureGroupRange = [result rangeAtIndex:1];
            NSString *durationString = [cacheHeader substringWithRange:captureGroupRange];
            interval = [durationString doubleValue];
        }
    }
    return interval;
}

@end
