//
//  FSPTeamRecord.h
//  FoxSports
//
//  Created by Chase Latta on 2/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPTeam;

extern NSString * const FSPOverallRecordKey;
extern NSString * const FSPHomeRecordKey;
extern NSString * const FSPAwayRecordKey;
extern NSString * const FSPConferenceRecordKey;
extern NSString * const FSPDivisionRecordKey;
extern NSString * const FSPLastTenRecordKey;

extern NSString * const FSPTeamRecordTypeKey;
extern NSString * const FSPTeamRecordWinsKey;
extern NSString * const FSPTeamRecordLossesKey;
extern NSString * const FSPTeamRecordTiesKey;

@interface FSPTeamRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * wins;
@property (nonatomic, retain) NSNumber * losses;
@property (nonatomic, retain) NSNumber * ties;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) FSPTeam *team;

- (void)populateWithDictionary:(NSDictionary *)dict;

// Utility method: used anywhere we display a W - L record, e.g. "27 - 23"
- (NSString *)winLossRecordString;
@end
