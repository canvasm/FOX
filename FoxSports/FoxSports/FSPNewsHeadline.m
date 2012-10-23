//
//  FSPNewsHeadline.m
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsHeadline.h"
#import "NSURL+CommonDirectories.h"
#import "FSPNewsCity.h"

static NSURL * FSPNewsCacheDirectory(void)
{
    static dispatch_queue_t syncQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        syncQueue = dispatch_queue_create("com.foxsports.news_cache_dir.sync", 0);
    });
    
    NSURL *cacheDirectory = [NSURL fsp_cacheDirectory];
    __block NSURL *newsCacheDir = [cacheDirectory URLByAppendingPathComponent:@"newsCache" isDirectory:YES];
    
    dispatch_sync(syncQueue, ^{
        // Check to see if the directory exists
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[newsCacheDir absoluteString]]) {
            if (![fileManager createDirectoryAtURL:newsCacheDir withIntermediateDirectories:YES attributes:nil error:nil])
                newsCacheDir = nil;
        }
    });
    return newsCacheDir;
}

@implementation FSPNewsHeadline

@dynamic newsId;
@dynamic group;
@dynamic publishedDate;
@dynamic imageURL;
@dynamic title;
@dynamic isTopNews;
@dynamic organizations;
@dynamic newsCity;
@dynamic cityName;

- (NSURL *)newsStoryPath;
{
    if (self.newsId) {
        NSURL *newsCacheDir = FSPNewsCacheDirectory();
        NSString *pathComponent = [self.newsId stringByAppendingString:@".plist"];
        return [newsCacheDir URLByAppendingPathComponent:pathComponent isDirectory:NO];
    } else {
        return nil;
    }
}

- (void)prepareForDeletion;
{
    [super prepareForDeletion];
    [[NSFileManager defaultManager] removeItemAtURL:[self newsStoryPath] error:nil];
}

@end
