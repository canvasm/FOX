//
//  FSPNBAStandingsProcessingOperation.h
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPStandingsProcessingOperation : FSPProcessingOperation

@property (nonatomic, copy) NSArray *standings;

- (id)initWithStandings:(NSArray *)standings context:(NSManagedObjectContext *)context;

@end
