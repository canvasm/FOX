//
//  FSPOrganizationHierarchyInfo.h
//  FoxSports
//
//  Created by Matthew Fay on 8/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPOrganization;

@interface FSPOrganizationHierarchyInfo : NSManagedObject

@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSNumber * isTeam;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * ordinal;
@property (nonatomic, retain) FSPOrganization *parentOrg;
@property (nonatomic, retain) FSPOrganization *currentOrg;

@end
