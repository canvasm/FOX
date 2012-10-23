//
//  FSPUFCFight.h
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPUFCEvent, FSPUFCPlayer;

@interface FSPUFCFight : NSManagedObject

@property (nonatomic, retain) NSNumber * ordinal;
@property (nonatomic, retain) NSString * decision;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * round;
@property (nonatomic, retain) NSString * weightClass;
@property (nonatomic, retain) NSString * fightStatus;
@property (nonatomic, retain) FSPUFCEvent *event;
@property (nonatomic, retain) FSPUFCPlayer *fighter1;
@property (nonatomic, retain) FSPUFCPlayer *fighter2;

- (void)populateWithDictionary:(NSDictionary *)fightDictionary;

@end
