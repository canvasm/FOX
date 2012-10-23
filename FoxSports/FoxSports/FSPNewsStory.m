//
//  FSPNewsStory.m
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsStory.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPImageFetcher.h"

#pragma mark - :: Encoding and Decoding Macros ::

#define FSPNewsStoryEncodeObject(obj, coder) do { \
    if (self.obj) [coder encodeObject:self.obj forKey:[NSString stringWithFormat:@"%@.%s", NSStringFromClass([self class]), #obj]]; } while(0)

#define FSPNewsStoryDecodeObject(obj, coder) do { \
    self.obj = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@.%s", NSStringFromClass([self class]), #obj]]; } while (0)

@interface FSPNewsStory ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *fullText;
@property (nonatomic, strong) NSDate *publishedDate;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *imageCaption;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSURL *originalURL;
@property (nonatomic, strong) NSDate *expirationDate;

@end

@implementation FSPNewsStory
@synthesize title;
@synthesize fullText;
@synthesize publishedDate;
@synthesize author;
@synthesize imageCaption;
@synthesize imageURL;
@synthesize originalURL;
@synthesize expirationDate;
@synthesize backingFile = _backingFile;

+ (id)newsStoryFromDictionary:(NSDictionary *)dictionary;
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (id)newsStoryWithContentsOfFile:(NSURL *)file;
{
    return [[self alloc] initNewsStoryWithContentsOfFile:file];
}

- (id)init;
{
    return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
{   
    // Do not create a story object without text.
    NSString *storyText = [dictionary fsp_objectForKey:@"fullText" defaultValue:@""];
    if ([storyText length] == 0)
        return nil;
    
    // continue as normal
    self = [super init];
    if (self) {
        self.title = [dictionary fsp_objectForKey:@"title" defaultValue:@""];
        self.fullText = storyText;

        // Put together our published date
        NSString *publishedString = [dictionary fsp_objectForKey:@"published" defaultValue:@""];
        if (publishedString) {
            NSInteger publishedInterval = [publishedString integerValue];
            if (publishedInterval > 0) {
                self.publishedDate = [NSDate dateWithTimeIntervalSince1970:publishedInterval];
            }
        }
        
        self.author = [dictionary fsp_objectForKey:@"author" defaultValue:@""];
        self.imageCaption = [dictionary fsp_objectForKey:@"imageCaption" defaultValue:@""];
        self.imageURL = [NSURL URLWithString:[dictionary fsp_objectForKey:@"imageUrl" defaultValue:@""]];
        self.originalURL = [NSURL URLWithString:[dictionary fsp_objectForKey:@"originalUrl" defaultValue:@""]];
        self.expirationDate = [dictionary objectForKey:@"expirationDate"];
    }
    return self;
}

- (id)initNewsStoryWithContentsOfFile:(NSURL *)file;
{
    NSData *data = [NSData dataWithContentsOfURL:file];
    if (data) {
        self = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self = nil;
    }
    return self;
}

- (BOOL)isExpired;
{
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

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder;
{
    FSPNewsStoryEncodeObject(title, coder);
    FSPNewsStoryEncodeObject(fullText, coder);
    FSPNewsStoryEncodeObject(publishedDate, coder);
    FSPNewsStoryEncodeObject(author, coder);
    FSPNewsStoryEncodeObject(imageURL, coder);
    FSPNewsStoryEncodeObject(imageCaption, coder);
    FSPNewsStoryEncodeObject(originalURL, coder);
    FSPNewsStoryEncodeObject(expirationDate, coder);
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [super init];
    if (self) {
        FSPNewsStoryDecodeObject(title, coder);
        FSPNewsStoryDecodeObject(fullText, coder);
        FSPNewsStoryDecodeObject(publishedDate, coder);
        FSPNewsStoryDecodeObject(author, coder);
        FSPNewsStoryDecodeObject(imageURL, coder);
        FSPNewsStoryDecodeObject(imageCaption, coder);
        FSPNewsStoryDecodeObject(originalURL, coder);
        FSPNewsStoryDecodeObject(expirationDate, coder);
    }
    return self;
}

#pragma  mark - Copying
- (id)copyWithZone:(NSZone *)zone;
{
    return self;
}

#pragma mark NSObject Overrides
- (NSUInteger)hash;
{
    return [self.fullText hash];
}

- (BOOL)isEqual:(FSPNewsStory *)object;
{
    if (![object isKindOfClass:[FSPNewsStory class]])
        return NO;
    
    // Loose equality based on story text
    // Check our hashes first to see if we should compare the full text because it may be expensive
    if ([self hash] == [object hash]) {
        return [self.fullText isEqualToString:object.fullText];
    }
    return NO;
}

@end
