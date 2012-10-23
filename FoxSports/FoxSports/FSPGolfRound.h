//
//  FSPGolfRound.h
//  FoxSports
//
//  Created by Matthew Fay on 9/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGolfHole.h"

@class FSPGolfer;

@interface FSPGolfRound : NSManagedObject

@property (nonatomic, retain) NSNumber * strokes;
@property (nonatomic, retain) NSNumber * round;
@property (nonatomic, retain) FSPGolfer *golfer;
@property (nonatomic, retain) NSSet * holes;

@end

@interface FSPGolfRound (CoreDataGeneratedAccessors)

- (void)addHolesObject:(FSPGolfHole *)hole;
- (void)removeHolesObject:(FSPGolfHole *)hole;
- (void)addHoles:(NSSet *)holes;
- (void)removeHoles:(NSSet *)holes;

@end
