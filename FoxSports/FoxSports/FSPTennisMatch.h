//
//  FSPTennisMatch.h
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPTennisMatchSegment, FSPTennisPlayer, FSPTennisTournamentRound;

@interface FSPTennisMatch : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) FSPTennisTournamentRound *round;
@property (nonatomic, retain) FSPTennisPlayer *competitor1;
@property (nonatomic, retain) FSPTennisPlayer *competitor2;

@property (nonatomic, retain) NSSet *segments;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end

@interface FSPTennisMatch (CoreDataGeneratedAccessors)

- (void)addSegmentsObject:(FSPTennisMatchSegment *)value;
- (void)removeSegmentsObject:(FSPTennisMatchSegment *)value;
- (void)addSegments:(NSSet *)values;
- (void)removeSegments:(NSSet *)values;

@end
