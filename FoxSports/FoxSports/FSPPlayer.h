//
//  FSPPlayer.h
//  FoxSports
//
//  Created by Chase Latta on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const FSPUpdateStatsException;

@interface FSPPlayer : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString *uniqueIdentifier;
@property (nonatomic, retain) NSNumber *liveEngineID;

@property (nonatomic, retain) NSString *photoURL;

//NOTE: use the context to create dependant managed object (Golf for example)
- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context;
- (NSString *)abbreviatedName;
- (NSString *)fullName;

@end

