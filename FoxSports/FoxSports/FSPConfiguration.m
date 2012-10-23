//
//  FSPConfiguration.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConfiguration.h"
#import "NSDictionary+FSPExtensions.h"

static NSString *FSPVersionDictionaryKey = @"latestVersionIOS";
static NSString *FSPLiveDataDelaysKey = @"liveDataDelays";
static NSString *FSPLiveDataDelaySportKey = @"liveDataDelaySport";
static NSString *FSPLiveDataDelaySecondsKey = @"liveDataDelaySeconds";

@interface FSPConfiguration ()
@property (nonatomic, strong) NSDictionary *configDictionary;
@property (nonatomic, strong, readwrite) NSDate *lastLogoChangeDate;
@property (nonatomic, strong, readwrite) NSDate *lastOrgChangeDate;
@property (nonatomic, strong, readwrite) NSDate *lastChannelsChangeDate;
@property (nonatomic, strong, readwrite) NSDate *lastCitiesChangeDate;
@property (nonatomic, strong, readwrite) NSString *outageCode;
@property (nonatomic, strong, readwrite) NSString *outageMessage;
@property (nonatomic, strong, readwrite) NSDate *outageStartDate;
@property (nonatomic, strong, readwrite) NSDate *outageEndDate;
@property (nonatomic, strong, readwrite) NSString *version;
@property (nonatomic, strong, readwrite) NSString *versionMessage;
@property (nonatomic, strong, readwrite) NSNumber *versionReminderInterval;
@property (nonatomic, assign, readwrite) BOOL versionRequiredUpgrade;
@property (nonatomic, strong, readwrite) NSArray *liveDataDelays;
@end

@implementation FSPConfiguration

@synthesize configDictionary = _configDictionary;
@synthesize lastLogoChangeDate = _lastLogoChangeDate;
@synthesize lastOrgChangeDate = _lastOrgChangeDate;
@synthesize lastChannelsChangeDate = _lastChannelsChangeDate;
@synthesize lastCitiesChangeDate = _lastCitiesChangeDate;
@synthesize outageCode = _outageCode;
@synthesize outageMessage = _outageMessage;
@synthesize outageStartDate = _outageStartDate;
@synthesize outageEndDate = _outageEndDate;
@synthesize version = _version;
@synthesize versionMessage = _versionMessage;
@synthesize versionReminderInterval = _versionReminderInterval;
@synthesize versionRequiredUpgrade = _versionRequiredUpgrade;
@synthesize liveDataDelays = _liveDataDelays;

#pragma mark - Class Methods
+ (FSPConfiguration *)sharedConfiguration;
{
    static FSPConfiguration *sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [[self alloc] init];
    });
    return sharedConfiguration;
}

- (void)setConfigurationDictionary:(NSMutableDictionary *)configDictionary
{
    _configDictionary = configDictionary;
    
    NSNumber *orgChangeDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPLastOrgChangeDateKey defaultValue:@0.0];
    NSNumber *logoChangeDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPLastLogoChangeDateKey defaultValue:@0.0];
    NSNumber *channelChangeDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPLastChannelChangeDateKey defaultValue:@0.0];
    NSNumber *citiesChangeDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPLastCitiesChangeDateKey defaultValue:@0.0];
    NSNumber *outageStartDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPOutageStartDateKey defaultValue:@0.0];
    NSNumber *outageEndDateInterval = (NSNumber *)[self.configDictionary fsp_objectForKey:FSPOutageEndDateKey defaultValue:@0.0];
    
    self.lastOrgChangeDate = orgChangeDateInterval ? [NSDate dateWithTimeIntervalSince1970:[orgChangeDateInterval doubleValue]] : nil;
    self.lastLogoChangeDate = logoChangeDateInterval ? [NSDate dateWithTimeIntervalSince1970:[logoChangeDateInterval doubleValue]] : nil;
    self.lastChannelsChangeDate = channelChangeDateInterval ? [NSDate dateWithTimeIntervalSince1970:[channelChangeDateInterval doubleValue]] : nil;
    self.lastCitiesChangeDate = citiesChangeDateInterval ? [NSDate dateWithTimeIntervalSince1970:[citiesChangeDateInterval doubleValue]] : nil;
    self.outageStartDate = outageStartDateInterval ? [NSDate dateWithTimeIntervalSince1970:[outageStartDateInterval doubleValue]]: nil;
    self.outageEndDate = outageEndDateInterval ? [NSDate dateWithTimeIntervalSince1970:[outageEndDateInterval doubleValue]] : nil;
    
    self.outageCode = [self.configDictionary objectForKey:FSPOutageCodeKey];
    self.outageMessage = [self.configDictionary objectForKey:FSPOutageMessageKey];
    
    NSDictionary *versionDictionary = [self.configDictionary objectForKey:FSPVersionDictionaryKey];
    self.version = [versionDictionary objectForKey:FSPVersionKey];
    self.versionMessage = [versionDictionary objectForKey:FSPVersionMessageKey];
    self.versionReminderInterval = [versionDictionary objectForKey:FSPVersionReminderIntervalDaysKey];
    self.versionRequiredUpgrade = [((NSNumber *)[versionDictionary objectForKey:FSPVersionRequiredUpgradeKey]) boolValue];
    
    self.liveDataDelays = [self.configDictionary objectForKey:FSPLiveDataDelaysKey];
}

- (NSNumber *)liveDataDelayForSport:(NSString *)sport
{
    for (NSDictionary *delayDict in self.liveDataDelays) {
        if ([[delayDict objectForKey:FSPLiveDataDelaySportKey] isEqualToString:sport]) {
            return [delayDict objectForKey:FSPLiveDataDelaySecondsKey];
        }
    }
    return nil;
}

@end
