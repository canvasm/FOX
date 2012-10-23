//
//  FSPTennisResultsProcessingOperation.m
//  FoxSports
//
//  Created by greay on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisResultsProcessingOperation.h"
#import "FSPTennisEvent.h"

@interface FSPTennisResultsProcessingOperation ()

@property (nonatomic, strong) NSArray *tournamentData;
@property (nonatomic, strong) NSManagedObjectID *eventID;
@end

@implementation FSPTennisResultsProcessingOperation

- (id)initWithTournamentData:(NSArray *)tournamentData eventID:(NSManagedObjectID *)eventID context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        _tournamentData = tournamentData;
		_eventID = eventID;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
	if (self.tournamentData) {
        [self.managedObjectContext performBlockAndWait:^{
			FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:self.eventID error:nil];
			
			if (!event || ![event isKindOfClass:[FSPTennisEvent class]]) return;
			
			FSPTennisEvent * tennisEvent = (FSPTennisEvent *)event;
			[tennisEvent populateWithTournamentData:self.tournamentData];

			if (self.isCancelled)
				return;
        }];
    }
}

@end
