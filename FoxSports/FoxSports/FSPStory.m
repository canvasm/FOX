//
//  FSPStory.m
//  FoxSports
//
//  Created by Laura Savino on 3/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStory.h"
#import "FSPEvent.h"
#import "NSDictionary+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"

@implementation FSPStory

@dynamic title;
@dynamic imageURLString;
@dynamic author;
@dynamic text;
@dynamic imageCaption;
@dynamic publishedDate;
@dynamic eventId;
@dynamic previewEvent;
@dynamic recapEvent;
@dynamic imageData;

- (void)populateWithDictionary:(NSDictionary *)dictionary; 
{
    self.title = [dictionary fsp_objectForKey:@"title" expectedClass:NSString.class];
    self.author = [dictionary fsp_objectForKey:@"author" expectedClass:NSString.class];
    self.text = [dictionary fsp_objectForKey:@"fullText" expectedClass:NSString.class];

    NSString *imageURLString = [dictionary fsp_objectForKey:@"imageUrl" expectedClass:NSString.class];
    if(![self.imageURLString isEqualToString:imageURLString])
    {
        self.imageURLString = imageURLString;
    }

    self.imageCaption = [dictionary fsp_objectForKey:@"imageCaption" expectedClass:NSString.class];
    NSString *dateString = [dictionary fsp_objectForKey:@"published" expectedClass:NSString.class];
    self.publishedDate = [NSDate fsp_dateFromISO8601String:dateString];
}

- (NSString *)fullText
{
	return self.text;
}

- (NSURL *)imageURL
{
    return [NSURL URLWithString:self.imageURLString];
}

@end
