//
//  FSPTennisStandingsProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPStandingsProcessingOperation.h"

@interface FSPTennisStandingsProcessingOperation : FSPStandingsProcessingOperation

- (id)initWithStandings:(NSArray *)standings branch:(NSString *)aBranch context:(NSManagedObjectContext *)context;

@end
