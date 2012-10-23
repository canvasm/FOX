//
//  FSPVideo.h
//  FoxSports
//
//  Created by Matthew Fay on 4/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPOrganization, FSPEvent;

extern NSString * const FSPVideoUniqueIdentifierKey;
extern NSString * const FSPVideoDescriptionKey;
extern NSString * const FSPVideoDurationKey;
extern NSString * const FSPVideoIsDefaultKey;
extern NSString * const FSPVideoURLKey;
extern NSString * const FSPVideoFormatKey;
extern NSString * const FSPVideoWidthKey;
extern NSString * const FSPVideoAuthorKey;
extern NSString * const FSPVideoHeightKey;
extern NSString * const FSPVideoTitleKey;

@interface FSPVideo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSSet * organizations;
@property (nonatomic, retain) NSSet * events;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * contentType;

- (void)populateWithDictionary:(NSDictionary *)videoData;

/*!
 @abstract Returns the video duration formatted for display in UI as minutes:seconds.
 @return A string representation of the video duration
 */
- (NSString *)durationFormattedForDisplay;

/*!
 @abstract Returns the video duration formatted for accessibility.
 @return A string representation of the video duration
 @discussion This is essentially the same as durantionFormattedForDisplay, only specially formatted to make sense when spoken by accessibility.
 */
- (NSString *)durationFormattedForAccessibility;

@end

@interface FSPVideo (CoreDataGeneratedAccessors)

- (void)addOrganizationsObject:(FSPOrganization *)value;
- (void)removeOrganizationsObject:(FSPOrganization *)value;
- (void)addOrganizations:(NSSet *)values;
- (void)removeOrganizations:(NSSet *)values;

- (void)addEventsObject:(FSPEvent *)value;
- (void)removeEventsObject:(FSPEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
