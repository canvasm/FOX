//
//  FSPTennisMatchSegment.h
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FSPTennisMatchSegment : NSManagedObject

@property (nonatomic, retain) NSNumber * segmentNumber;
@property (nonatomic, retain) NSNumber * score1;
@property (nonatomic, retain) NSNumber * tie1;
@property (nonatomic, retain) NSNumber * tie2;
@property (nonatomic, retain) NSNumber * score2;
@property (nonatomic, retain) NSManagedObject *match;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
