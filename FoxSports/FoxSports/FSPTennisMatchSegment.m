//
//  FSPTennisMatchSegment.m
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisMatchSegment.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPTennisMatchSegment

@dynamic segmentNumber;
@dynamic score1;
@dynamic tie1;
@dynamic tie2;
@dynamic score2;
@dynamic match;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
	self.segmentNumber = [dictionary fsp_objectForKey:@"segmentNumber" expectedClass:[NSNumber class]];

	NSDictionary *score = [dictionary fsp_objectForKey:@"score" expectedClass:[NSDictionary class]];
	self.score1 = [score fsp_objectForKey:@"c1" expectedClass:[NSNumber class]];
	self.score2 = [score fsp_objectForKey:@"c2" expectedClass:[NSNumber class]];
	
	NSDictionary *tiebreaker = [dictionary fsp_objectForKey:@"tieBreak" expectedClass:[NSDictionary class]];
	self.tie1 = [tiebreaker fsp_objectForKey:@"c1" expectedClass:[NSNumber class]];
	self.tie2 = [tiebreaker fsp_objectForKey:@"c2" expectedClass:[NSNumber class]];
}

@end
