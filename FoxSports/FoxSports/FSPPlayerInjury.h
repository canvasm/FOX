//
//  FSPPlayerInjury.h
//  FoxSports
//
//  Created by Matthew Fay on 3/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const FSPPlayerInjuryEventIdKey;
extern NSString * const FSPPlayerInjuryTeamIdKey;
extern NSString * const FSPPlayerInjuryFirstNameKey;
extern NSString * const FSPPlayerInjuryLastNameKey;
extern NSString * const FSPPlayerInjuryPositionKey;
extern NSString * const FSPPlayerInjuryKey;
extern NSString * const FSPPlayerInjuryStatusKey;
extern NSString * const FSPPlayerInjuryImageURLKey;

@interface FSPPlayerInjury : NSManagedObject

@property (nonatomic, retain) NSString * teamIdentifier;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * injury;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * imageURL;

@end
