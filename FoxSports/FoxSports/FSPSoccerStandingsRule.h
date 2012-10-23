//
//  FSPSoccerStandingsRule.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPOrganization;

@interface FSPSoccerStandingsRule : NSManagedObject

@property (nonatomic, retain) NSNumber * endPosition;
@property (nonatomic, retain) NSNumber * isRelegation;
@property (nonatomic, retain) NSNumber * startPosition;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) FSPOrganization *organization;

- (void)populateWithDictionary:(NSDictionary *)standingsRuleData;

@end
