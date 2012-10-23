//
//  FSPTennisTournamentRound.m
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisTournamentRound.h"

#import "NSDictionary+FSPExtensions.h"

@implementation FSPTennisTournamentRound

@dynamic ordinal;
@dynamic name;
@dynamic matches;
@dynamic event;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
	self.ordinal = [dictionary fsp_objectForKey:@"ordinal" expectedClass:[NSNumber class]];
	self.name = [dictionary fsp_objectForKey:@"name" expectedClass:[NSString class]];
	
	[self.managedObjectContext performBlock:^{
		FSPTennisMatch *match = nil;
		NSMutableSet * records = [NSMutableSet set];
		
		NSArray *values = [self.matches allObjects];
		NSString *key = @"index";
		NSArray *keys = [values valueForKeyPath:key];
		NSDictionary *existingRecords = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSArray *matchesData = [dictionary fsp_objectForKey:@"matches" expectedClass:[NSArray class]];
		for (NSDictionary *matchData in matchesData) {
			NSNumber *i = [matchData fsp_objectForKey:key expectedClass:[NSNumber class]];
			match = [existingRecords objectForKey:i];
			if (!match)
				match = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTennisMatch" inManagedObjectContext:self.managedObjectContext];
			
			[match populateWithDictionary:matchData];
			[records addObject:match];
		}
		self.matches = [NSSet setWithSet:records];
    }];

}

@end
