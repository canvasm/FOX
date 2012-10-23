//
//  FSPNewsHeadline.h
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPOrganization;
@class FSPNewsCity;

@interface FSPNewsHeadline : NSManagedObject

@property (nonatomic, retain) NSString * newsId;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSDate * publishedDate;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * isTopNews;
@property (nonatomic, retain) FSPNewsCity * newsCity;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSSet *organizations;

/**
 Returns the path on disk that the news story should live.
 */
- (NSURL *)newsStoryPath;

@end

@interface FSPNewsHeadline (CoreDataGeneratedAccessors)

- (void)addOrganizationsObject:(FSPOrganization *)value;
- (void)removeOrganizationsObject:(FSPOrganization *)value;
- (void)addOrganizations:(NSSet *)values;
- (void)removeOrganizations:(NSSet *)values;

@end
