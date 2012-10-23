//
//  FSPTennisResultsProcessingOperation.h
//  FoxSports
//
//  Created by greay on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPProcessingOperation.h"

@interface FSPTennisResultsProcessingOperation : FSPProcessingOperation

- (id)initWithTournamentData:(NSArray *)tournamentData eventID:(NSManagedObjectID *)eventID context:(NSManagedObjectContext *)context;

@end
