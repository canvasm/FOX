//
//  FSPStory.h
//  FoxSports
//
//  Created by Laura Savino on 3/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPEvent;

typedef enum {
    FSPStoryTypePreview = 0,
    FSPStoryTypeRecap,
	FSPStoryTypeNews
} FSPStoryType;


@protocol FSPStoryProtocol <NSObject>

- (NSString *)title;
- (NSString *)fullText;
- (NSDate *)publishedDate;
- (NSString *)author;
- (NSString *)imageCaption;
- (NSURL *)imageURL;

@end


@interface FSPStory : NSManagedObject <FSPStoryProtocol>

@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * imageCaption;
@property (nonatomic, retain) NSDate * publishedDate;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) FSPEvent * previewEvent;
@property (nonatomic, retain) FSPEvent * recapEvent;

@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSData * imageData;


- (NSURL *)imageURL;

/**
 * Updates properties with values from given dictionary and the event ID of the associated event.
 */
- (void)populateWithDictionary:(NSDictionary *)dictionary; 

@end
