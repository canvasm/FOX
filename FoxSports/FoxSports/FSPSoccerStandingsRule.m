//
//  FSPSoccerStandingsRule.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerStandingsRule.h"
#import "FSPOrganization.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPSoccerStandingsRule

@dynamic endPosition;
@dynamic isRelegation;
@dynamic startPosition;
@dynamic text;
@dynamic organization;

- (void)populateWithDictionary:(NSDictionary *)standingsRuleData
{
    self.endPosition = [standingsRuleData fsp_objectForKey:@"endPosition" defaultValue:@-1];
    self.startPosition = [standingsRuleData fsp_objectForKey:@"startPosition" defaultValue:@-1];
    self.isRelegation = [standingsRuleData fsp_objectForKey:@"isRelegation" defaultValue:@0];
    self.text = [standingsRuleData fsp_objectForKey:@"text" defaultValue:@""];
}

@end
