//
//  FSPNewsStory.h
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPStory.h"

@interface FSPNewsStory : NSObject <NSCoding, NSCopying, FSPStoryProtocol>
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *fullText;
@property (nonatomic, strong, readonly) NSDate *publishedDate;
@property (nonatomic, copy, readonly) NSString *author;
@property (nonatomic, copy, readonly) NSString *imageCaption;
@property (nonatomic, copy, readonly) NSURL *originalURL;

@property (nonatomic, readonly) BOOL isExpired;

/**
 If the backing file is set the story will update the 
 backing file when the object is updated.
 */
@property (nonatomic, copy) NSURL *backingFile;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (id)newsStoryFromDictionary:(NSDictionary *)dictionary;

- (id)initNewsStoryWithContentsOfFile:(NSURL *)file;
+ (id)newsStoryWithContentsOfFile:(NSURL *)file;

@end
