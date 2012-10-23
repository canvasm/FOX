//
//  FSPTennisMatch.m
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisMatch.h"
#import "FSPTennisMatchSegment.h"
#import "FSPTennisPlayer.h"
#import "FSPTennisTournamentRound.h"

#import "NSDictionary+FSPExtensions.h"

@implementation FSPTennisMatch

@dynamic index;
@dynamic round;
@dynamic competitor1;
@dynamic competitor2;
@dynamic segments;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
	self.index = [dictionary fsp_objectForKey:@"index" expectedClass:[NSNumber class]];
	
	NSDictionary *playerRecord = [dictionary fsp_objectForKey:@"competitor1" expectedClass:[NSDictionary class]];
	if (playerRecord) {
		if (self.competitor1) {
			[self.competitor1 updateStatsFromDictionary:playerRecord withContext:self.managedObjectContext];
		} else {
			self.competitor1 = [self playerWithData:playerRecord];
		}
	}
	
	playerRecord = [dictionary fsp_objectForKey:@"competitor2" expectedClass:[NSDictionary class]];
	if (playerRecord) {
		if (self.competitor2) {
			[self.competitor2 updateStatsFromDictionary:playerRecord withContext:self.managedObjectContext];
		} else {
			self.competitor2 = [self playerWithData:playerRecord];
		}
	}
	
	[self.managedObjectContext performBlock:^{
		FSPTennisMatchSegment *segment = nil;
		NSMutableSet * records = [NSMutableSet set];
		
		NSArray *values = [self.segments allObjects];
		NSString *key = @"segmentNumber";
		NSArray *keys = [values valueForKeyPath:key];
		NSDictionary *existingRecords = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSArray *segmentsData = [dictionary fsp_objectForKey:@"segments" expectedClass:[NSArray class]];
		for (NSDictionary *segmentData in segmentsData) {
			NSNumber *i = [segmentData fsp_objectForKey:key expectedClass:[NSNumber class]];
			segment = [existingRecords objectForKey:i];
			if (!segment)
				segment = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTennisMatchSegment" inManagedObjectContext:self.managedObjectContext];
			
			[segment populateWithDictionary:segmentData];
			[records addObject:segment];
		}
		self.segments = [NSSet setWithSet:records];
    }];

}

- (FSPTennisPlayer *)playerWithData:(NSDictionary *)playerRecord
{
	__block FSPTennisPlayer *player = nil;
	
	[self.managedObjectContext performBlockAndWait:^{
		NSNumber *liveEngineID = [playerRecord fsp_objectForKey:@"nativeId" expectedClass:[NSNumber class]];
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTennisPlayer"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"liveEngineID == %@", liveEngineID];
		NSArray *existingPlayers = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		if ([existingPlayers count]) {
			player = [existingPlayers lastObject];
		} else {
			player = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTennisPlayer" inManagedObjectContext:self.managedObjectContext];
			player.uniqueIdentifier = @"INVALID";
		}

		player.firstName = [playerRecord fsp_objectForKey:@"name" expectedClass:[NSString class]];
		player.liveEngineID = liveEngineID;
		player.photoURL = [playerRecord fsp_objectForKey:@"imageUrl" expectedClass:[NSString class]];
	}];
	
	return player;
}

@end
