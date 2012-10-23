//
//  FSPConfiguration.h
//  FoxSports
//
//  Created by Joshua Dubey on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *FSPLastOrgChangeDateKey = @"lastOrgChangeDate";
static NSString *FSPLastLogoChangeDateKey = @"lastLogoChangeDate";
static NSString *FSPLastChannelChangeDateKey = @"lastChannelsChangeDate";
static NSString *FSPLastCitiesChangeDateKey = @"lastCitiesChangeDate";
static NSString *FSPOutageCodeKey = @"outageCode";
static NSString *FSPOutageMessageKey = @"outageMessage";
static NSString *FSPOutageStartDateKey = @"outageStartDate";
static NSString *FSPOutageEndDateKey = @"outageEndDate";
static NSString *FSPVersionKey = @"version";
static NSString *FSPVersionMessageKey = @"message";
static NSString *FSPVersionReminderIntervalDaysKey = @"reminderIntervalDays";
static NSString *FSPVersionRequiredUpgradeKey = @"requiredUpgrade";

@interface FSPConfiguration : NSObject

@property (nonatomic, strong, readonly) NSDate *lastOrgChangeDate;
@property (nonatomic, strong, readonly) NSDate *lastLogoChangeDate;
@property (nonatomic, strong, readonly) NSDate *lastChannelsChangeDate;
@property (nonatomic, strong, readonly) NSDate *lastCitiesChangeDate;
@property (nonatomic, strong, readonly) NSString *outageCode;
@property (nonatomic, strong, readonly) NSString *outageMessage;
@property (nonatomic, strong, readonly) NSDate *outageStartDate;
@property (nonatomic, strong, readonly) NSDate *outageEndDate;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *versionMessage;
@property (nonatomic, strong, readonly) NSNumber *versionReminderInterval;
@property (nonatomic, assign, readonly) BOOL versionRequiredUpgrade;

+ (FSPConfiguration *)sharedConfiguration;
- (NSNumber *)liveDataDelayForSport:(NSString *)sport;

@end
