//
//  FSPPlayerInjury.m
//  FoxSports
//
//  Created by Matthew Fay on 3/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayerInjury.h"

NSString * const FSPPlayerInjuryEventIdKey = @"eventId";
NSString * const FSPPlayerInjuryTeamIdKey = @"fsId";
NSString * const FSPPlayerInjuryFirstNameKey = @"firstName";
NSString * const FSPPlayerInjuryLastNameKey = @"lastName";
NSString * const FSPPlayerInjuryPositionKey = @"position";
NSString * const FSPPlayerInjuryKey = @"injury";
NSString * const FSPPlayerInjuryStatusKey = @"status";
NSString * const FSPPlayerInjuryImageURLKey = @"imageURL";

@implementation FSPPlayerInjury

@dynamic teamIdentifier;
@dynamic eventIdentifier;
@dynamic firstName;
@dynamic lastName;
@dynamic position;
@dynamic injury;
@dynamic status;
@dynamic imageURL;

@end
