//
//  FSPRacingTrackRecords.h
//  FoxSports
//
//  Created by Matthew Fay on 7/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPRacingEvent;

@interface FSPRacingTrackRecords : NSManagedObject

@property (nonatomic, retain) NSString * recordAchievedDate;
@property (nonatomic, retain) NSString * recordName;
@property (nonatomic, retain) NSString * recordHolder;
@property (nonatomic, retain) NSString * recordValue;
@property (nonatomic, retain) FSPRacingEvent *track;

- (void)populateWithDictionary:(NSDictionary *)record;

@end
