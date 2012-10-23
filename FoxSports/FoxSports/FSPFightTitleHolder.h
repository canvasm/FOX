//
//  FSPFightTitleHolder.h
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FSPFightTitleHolder : NSManagedObject

@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfDefences;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSDate * wonDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * maxWeight;
@property (nonatomic, retain) NSNumber * minWeigth;
@property (nonatomic, retain) NSString *photoURL;

- (void)populateWithDictionary:(NSDictionary *)titleHolder;

@end
