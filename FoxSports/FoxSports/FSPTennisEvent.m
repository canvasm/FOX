//
//  FSPTennisEvent.m
//  FoxSports
//
//  Created by Laura Savino on 1/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisEvent.h"
#import "FSPTennisTournamentRound.h"
#import "FSPTennisMatch.h"
#import "FSPTennisPlayer.h"

#import "NSDictionary+FSPExtensions.h"


@implementation FSPTennisEvent

@dynamic eventSubtitle;
@dynamic eventTitle;
@dynamic locationName;
@dynamic rounds;

-(void)populateWithDictionary:(NSDictionary *)eventData
{
    [super populateWithDictionary:eventData];
    
    self.eventTitle = [eventData fsp_objectForKey:@"eventTitle" defaultValue:@""];
    self.eventSubtitle = [eventData fsp_objectForKey:@"eventSubtitle" defaultValue:@""];
    self.locationName = [eventData fsp_objectForKey:@"locationName" defaultValue:@""];
}

- (void)populateWithTournamentData:(NSArray *)tournamentData;
{
	[self.managedObjectContext performBlock:^{
		FSPTennisTournamentRound *round = nil;
		NSMutableSet * records = [NSMutableSet set];
		
		NSArray *values = [self.rounds allObjects];
		NSString *key = @"ordinal";
		NSArray *keys = [values valueForKeyPath:key];
		NSDictionary *existingRecords = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		for (NSDictionary *roundData in tournamentData) {
			NSNumber *i = [roundData fsp_objectForKey:key expectedClass:[NSNumber class]];
			round = [existingRecords objectForKey:i];
			if (!round)
				round = (FSPTennisTournamentRound *)[NSEntityDescription insertNewObjectForEntityForName:@"FSPTennisTournamentRound" inManagedObjectContext:self.managedObjectContext];
			
			[round populateWithDictionary:roundData];
			[records addObject:round];
		}
		self.rounds = [NSSet setWithSet:records];
    }];

}


#pragma mark FSPTournamentEvent protocol methods

- (NSString *)tournamentTitle
{
    return self.eventTitle;
}

- (NSString *)tournamentSubtitle
{
    return self.eventSubtitle;
}

- (NSString *)location
{
    return self.locationName;
}

@end
