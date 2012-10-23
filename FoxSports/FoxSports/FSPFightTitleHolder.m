//
//  FSPFightTitleHolder.m
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFightTitleHolder.h"
#import "FSPCoreDataManager.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPFightTitleHolder

@dynamic branch;
@dynamic name;
@dynamic numberOfDefences;
@dynamic sortOrder;
@dynamic wonDate;
@dynamic title;
@dynamic maxWeight;
@dynamic minWeigth;
@dynamic photoURL;

- (void)populateWithDictionary:(NSDictionary *)titleHolder
{
    self.sortOrder = [titleHolder fsp_objectForKey:@"ordinal" defaultValue:@0];
    
    NSDictionary *person = [titleHolder fsp_objectForKey:@"person" expectedClass:NSDictionary.class];
    self.name = [person fsp_objectForKey:@"fullName" defaultValue:@""];
    self.numberOfDefences = [person fsp_objectForKey:@"defenses" defaultValue:@0];
    NSNumber * interval = [person fsp_objectForKey:@"wonDate" defaultValue:@0];
    self.wonDate = [interval intValue] > 0 ? [NSDate dateWithTimeIntervalSince1970:interval.intValue] : nil;
    self.photoURL = [person objectForKey:@"photoUrl"];
    NSDictionary *titleStats = [titleHolder fsp_objectForKey:@"weightClass" expectedClass:NSDictionary.class];
    self.title = [titleStats fsp_objectForKey:@"title" defaultValue:@""];
    self.maxWeight = [titleStats fsp_objectForKey:@"max" defaultValue:@0];
    self.minWeigth = [titleStats fsp_objectForKey:@"min" defaultValue:@0];
}

@end
