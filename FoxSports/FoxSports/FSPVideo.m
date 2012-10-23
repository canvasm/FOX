//
//  FSPVideo.m
//  FoxSports
//
//  Created by Matthew Fay on 4/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideo.h"
#import "NSDictionary+FSPExtensions.h"

NSString * const FSPVideoUniqueIdentifierKey = @"guid";
NSString * const FSPVideoDescriptionKey = @"description";
NSString * const FSPVideoDurationKey = @"duration";
NSString * const FSPVideoIsDefaultKey = @"isDefault";
NSString * const FSPVideoURLKey = @"url";
NSString * const FSPVideoFormatKey = @"format";
NSString * const FSPVideoWidthKey = @"width";
NSString * const FSPVideoAuthorKey = @"author";
NSString * const FSPVideoHeightKey = @"height";
NSString * const FSPVideoTitleKey = @"title";

@implementation FSPVideo

@dynamic title;
@dynamic height;
@dynamic author;
@dynamic width;
@dynamic format;
@dynamic videoURL;
@dynamic isDefault;
@dynamic duration;
@dynamic desc;
@dynamic uniqueIdentifier;
@dynamic organizations;
@dynamic events;
@dynamic imageURL;
@dynamic contentType;

- (void)populateWithDictionary:(NSDictionary *)videoData;
{
    self.uniqueIdentifier = [videoData objectForKey:FSPVideoUniqueIdentifierKey];
    self.title = [videoData fsp_objectForKey:FSPVideoTitleKey defaultValue:@""];
    self.author = [videoData fsp_objectForKey:FSPVideoAuthorKey defaultValue:@""];
    self.desc = [videoData fsp_objectForKey:FSPVideoDescriptionKey defaultValue:@""];
    self.imageURL = [[videoData fsp_objectForKey:@"defaultThumbnailUrl" defaultValue:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.contentType = [videoData fsp_objectForKey:@"fsmobile$contentType" defaultValue:@""];
	
    //TODO: Right now I am only taking the first video in the list till I find a better way to do this
    NSArray *content = [videoData objectForKey:@"content"];
    if (content) {
        NSDictionary *firstVideo = [content objectAtIndex:0];
        self.format = [firstVideo fsp_objectForKey:FSPVideoFormatKey defaultValue:@""];
        self.height = [firstVideo fsp_objectForKey:FSPVideoHeightKey defaultValue:@0];
        self.width = [firstVideo fsp_objectForKey:FSPVideoWidthKey defaultValue:@0];
        self.duration = [firstVideo fsp_objectForKey:FSPVideoDurationKey defaultValue:@0];
        self.isDefault = [firstVideo fsp_objectForKey:FSPVideoIsDefaultKey defaultValue:@(false)];
        self.videoURL = [NSString stringWithFormat:@"%@%@",[firstVideo objectForKey:FSPVideoURLKey],@"&format=redirect&manifest=m3u"];
    }
}

- (NSString *)durationFormattedForDisplay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.duration longValue]];
    NSString *formattedDuration = [dateFormatter stringFromDate:date];
    return formattedDuration;
}

- (NSString *)durationFormattedForAccessibility;
{
    int seconds = [self.duration intValue] % 60;
    int minutes = ([self.duration intValue] - seconds) / 60;
    NSString *minutesString = minutes == 1 ? @"Minute" : @"Minutes";
    NSString *secondsString = seconds == 1 ? @"Second" : @"Seconds";
    NSString *formattedDuration = [NSString stringWithFormat:@"%d %@ %.2d %@", minutes, minutesString, seconds, secondsString];
    return formattedDuration;
}

@end
