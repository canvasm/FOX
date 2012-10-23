//
//  FSPRankingsProcessingOperation.h
//  FoxSports
//
//  Created by Joshua Dubey on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPProcessingOperation.h"

@interface FSPRankingsProcessingOperation : FSPProcessingOperation

@property (nonatomic, copy) NSDictionary *rankings;
@property (nonatomic, retain) NSManagedObjectID *orgId;

- (id)initWithRankings:(NSDictionary *)rankings orgId:(NSManagedObjectID *)orgId context:(NSManagedObjectContext *)context;

@end
