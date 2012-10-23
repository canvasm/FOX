//
//  FSPGolfHole.h
//  FoxSports
//
//  Created by Matthew Fay on 9/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPGolfRound;

@interface FSPGolfHole : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * par;
@property (nonatomic, retain) NSNumber * strokes;
@property (nonatomic, retain) FSPGolfRound *round;

- (BOOL)isHole;

@end
