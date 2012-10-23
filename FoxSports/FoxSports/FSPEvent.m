//
//  FSPEvent.m
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEvent.h"
#import "FSPOrganization.h"
#import "FSPOrganizationSchedule.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPStory.h"
#import "NSDictionary+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPMassRelevanceViewController.h"

// Dictionary Required Key Constants
NSString * const FSPEventUniqueIdKey = @"fsId";
NSString * const FSPEventBranchKey = @"branch";
NSString * const FSPEventItemTypeKey = @"itemType";
NSString * const FSPEventStartDateKey = @"startDate";
NSString * const FSPEventEventStateKey = @"eventState";

NSString * const FSPEventIsStreamableKey = @"streamable";

const int FSPLiveEngineDefault = -1;

@interface FSPEvent ()
@property (nonatomic, copy) NSString *timeStatus;

@end

@implementation FSPEvent
@synthesize timeStatus = _timeStatus;

@dynamic displayInColB;
@dynamic segmentDescription;
@dynamic segmentNumber;
@dynamic eventState;
@dynamic itemType;
@dynamic branch;
@dynamic channelDisplayName;
@dynamic uniqueIdentifier;
@dynamic startDate;
@dynamic streamable;
@dynamic expiresDate;
@dynamic channels;
@dynamic normalizedStartDate;
@dynamic belongedToSchedules;
@dynamic startDateGroup;
@dynamic eventCompleted;
@dynamic eventStarted;
@dynamic previewStory;
@dynamic recapStory;
@dynamic liveDataURL;
@dynamic seasonState;
@dynamic season;
@dynamic eventYear;
@dynamic eventTimeTBA;
@dynamic minPollingInterval;
@dynamic playerBaseURL;
@dynamic firstGameTime;
@dynamic weekNumber;
@dynamic gameDictionaryCreated;
@dynamic liveEngineUpdatedVersion;
@dynamic liveEngineIdentifier;
@dynamic organizations;
@dynamic venue;
@dynamic compType;
@dynamic videos;

+ (NSString *)entityNameForBranchType:(NSString *)branchType;
{
    static NSString * const defaultEventType = @"FSPEvent";
    if (!branchType)
        return defaultEventType;
    
    branchType = [FSPOrganization baseBranchForBranch:branchType];
    
    static NSDictionary *lookupDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lookupDictionary = @{FSPMLBEventBranchType: @"FSPBaseballGame",
                            FSPNBAEventBranchType: @"FSPBasketballGame",
                            FSPWNBAEventBranchType: @"FSPBasketballGame",
                            FSPNFLEventBranchType: @"FSPFootballGame",
                            FSPNHLEventBranchType: @"FSPHockeyGame",
                            FSPNCAABasketballEventBranchType: @"FSPBasketballGame",
                            FSPNCAAWBasketballEventBranchType: @"FSPBasketballGame",
                            FSPNCAAFootballEventBranchType: @"FSPFootballGame",
                            FSPSoccerEventBranchType: @"FSPSoccerGame",
                            FSPPGAEventBranchType: @"FSPPGAEvent",
                            FSPUFCEventBranchType: @"FSPUFCEvent",
                            FSPTennisEventBranchType: @"FSPTennisEvent",
                            FSPNASCAREventBranchType: @"FSPRacingEvent",
                            FSPAutoRacingEventBranchType: @"FSPRacingEvent",
                            FSPGolfBranchType: @"FSPPGAEvent"};
    });
    
    NSString *entityName = [lookupDictionary fsp_objectForKey:branchType defaultValue:defaultEventType];
    
    return entityName;
}

+ (NSString *)displayNameForStartDateGroup:(NSNumber *)aStartDateGroup;
{
    static NSDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{@(FSPStartDateGroupPast): @"LAST RESULTS",
                      @(FSPStartDateGroupToday): @"TODAY",
                      @(FSPStartDateGroupTomorrow): @"TOMORROW",
                      @(FSPStartDateGroupComingUp): @"COMING UP"};
    });
    NSString *displayName = [dictionary objectForKey:aStartDateGroup];
    return displayName;
}

- (NSString *)baseBranch
{
	return [FSPOrganization baseBranchForBranch:self.branch];
}

- (FSPOrganization *)getTopLevelOrganization
{
    FSPOrganization *highestOrg;
    for (FSPOrganization *org in self.organizations)
    {
        if (![org isKindOfClass:[FSPTeam class]]) {
            if (!highestOrg) highestOrg = org;
            for (FSPOrganizationHierarchyInfo *info in org.currentHierarchyInfo)
            {
                if (!info.isTeam) {
                    if (info.ordinal < highestOrg.ordinal)
                        highestOrg = org;
                }
            }
        }
    }
    return highestOrg;
}

- (FSPOrganization *)getPrimaryOrganization;
{
    if ([self isKindOfClass:[FSPGame class]]) {
        FSPGame *game = (FSPGame *)self;
        return ([game.homeTeam.alertMask unsignedIntegerValue] != 0) ? game.homeTeam : game.awayTeam;
    }
    
    for (FSPOrganization *org in self.organizations) {
        if ([org.branch isEqualToString:self.branch])
            return org;
        
        for (FSPOrganization *childOrg in [org allChildren]) {
            if ([childOrg.branch isEqualToString:self.branch])
                return childOrg;
        }
    }
    NSLog(@"no primary organization found for event with branch: %@", self.branch);
    return nil;
}

- (NSString *)timeStatus;
{
    if ([self.eventCompleted boolValue]) {
        _timeStatus = @"FINAL";
    } else if ([self.eventStarted boolValue]) {
        if ([self.eventState isEqualToString:@"IN-PROGRESS"]) {
            if (self.segmentNumber && self.segmentDescription) {
            NSString *segNumber = [self naturalLanguageStringForSegmentNumber:self.segmentNumber];
                if ([self.branch isEqualToString:FSPMLBEventBranchType])
                    _timeStatus = [NSString stringWithFormat:@"%@ %@", [self.segmentDescription isEqualToString:@"T"] ? @"Top" : @"Bot", segNumber];
                else if ([self.branch isEqualToString:@"UFC"])
                    _timeStatus = [NSString stringWithFormat:@"%@ %@", self.segmentDescription, self.segmentNumber];
                else
                    _timeStatus = [NSString stringWithFormat:@"%@ %@", segNumber, self.segmentDescription];
            }
            else {
                _timeStatus = @"IN PROGRESS";
            }
        } else {
            _timeStatus = self.eventState;
        }
    } else {
        _timeStatus = @"";
    }
    if (!_timeStatus) {
        return @"--";
    }
    return _timeStatus;
}

- (void)setEventState:(NSString *)newEventState;
{
    newEventState = [newEventState uppercaseString];
    
#ifdef FSP_ALL_EVENTS_PREGAME
    //This is to test pregame state when no future games are available
    newEventState = @"PRE-GAME";
#endif
    
#ifdef FSP_ALL_EVENTS_IN_PROGRESS
    newEventState = @"IN-PROGRESS";
#endif
    
#ifdef FSP_ALL_EVENTS_DELAYED
    newEventState = @"DELAYED";
#endif
    
    [self willChangeValueForKey:@"eventState"];
    [self setPrimitiveValue:newEventState forKey:@"eventState"];
    [self didChangeValueForKey:@"eventState"];
    
    if ([newEventState isEqualToString:@"FINAL"])
        self.eventCompleted = @(YES);
    else
        self.eventCompleted = @(NO);
  
    static NSSet *startedKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        startedKeys = [NSSet setWithObjects:@"IN-PROGRESS", @"FINAL", @"DELAYED", @"QUALIFYING", @"CAUTION", @"SUSPENDED", nil];
    });
    
    if ([startedKeys containsObject:newEventState]) {
        self.eventStarted = @(YES);
    } else {
        self.eventStarted = @(NO);
    }
}

- (void)setSegmentNumber:(NSString *)newSegmentNumber;
{
    [self willChangeValueForKey:@"segmentNumber"];
    [self setPrimitiveValue:newSegmentNumber forKey:@"segmentNumber"];
    [self didChangeValueForKey:@"segmentNumber"];
}

- (void)setSegmentDescription:(NSString *)newSegmentDescription;
{
    [self willChangeValueForKey:@"segmentDescription"];
    [self setPrimitiveValue:newSegmentDescription forKey:@"segmentDescription"];
    [self didChangeValueForKey:@"segmentDescription"];
}

- (void)setStartDate:(NSDate *)newStartDate;
{
    [self willChangeValueForKey:@"startDate"];
    [self setPrimitiveValue:newStartDate forKey:@"startDate"];
    [self didChangeValueForKey:@"startDate"];
    
    self.normalizedStartDate = [newStartDate fsp_normalizedDate];
    if([newStartDate fsp_isToday])
        self.startDateGroup = @(FSPStartDateGroupToday);
    else if([newStartDate fsp_isTomorrow]) // 1
        self.startDateGroup = @(FSPStartDateGroupTomorrow); // 2
    else if([newStartDate compare:[NSDate date]] == NSOrderedDescending)
        self.startDateGroup = @(FSPStartDateGroupComingUp); // 3
    else if([newStartDate compare:[NSDate date]] == NSOrderedAscending)
        self.startDateGroup = @(FSPStartDateGroupPast); // 0
}

- (FSPViewType)viewType
{;
	FSPOrganization *org = [self.organizations anyObject];
	return [org viewType];
}

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
    self.uniqueIdentifier = [eventData objectForKey:FSPEventUniqueIdKey];
    self.liveEngineIdentifier = [eventData objectForKey:@"eventNativeID"];
    self.branch = [eventData objectForKey:FSPEventBranchKey];
    self.itemType = [eventData objectForKey:FSPEventItemTypeKey];
    self.startDate = [eventData objectForKey:FSPEventStartDateKey];
    self.eventState = [eventData objectForKey:FSPEventEventStateKey];
    
    if (self.eventCompleted.boolValue || !self.segmentNumber) {
        self.segmentNumber = [eventData fsp_objectForKey:@"segmentNumber" defaultValue:@"1"];
        self.segmentDescription = [eventData fsp_objectForKey:@"segmentDescription" defaultValue:@""];
    }
    
    self.venue = [eventData fsp_objectForKey:@"venueName" defaultValue:@""];
    self.compType = [eventData fsp_objectForKey:@"compType" defaultValue:@""];

    //TODO: only allow a certain amount of channels to be displayed
    NSArray *channelArray = [eventData fsp_objectForKey:@"channel" expectedClass:NSArray.class];
    self.channelDisplayName = @"";
    if (channelArray) {
        for (NSUInteger i = 0; i < [channelArray count]; ++i) {
            self.channelDisplayName = [NSString stringWithFormat:@"%@%@%@", self.channelDisplayName, i == 0 ? @"" : @", ", [[channelArray objectAtIndex:i] fsp_objectForKey:@"callSign" defaultValue:@""]];
        }
    }
}

- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData;
{

}

- (void)populateWithLeagueGameBundleDictionary:(NSDictionary *)eventData;
{
    [self populateSegmentInformationWithDictionary:eventData];
}

- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData;
{
    NSDictionary *timeDict = [segmentData fsp_objectForKey:@"TIME" expectedClass:NSDictionary.class];
    if (timeDict) {
        NSNumber *segemntNum = [timeDict fsp_objectForKey:@"P" defaultValue:@0];
        self.segmentNumber = segemntNum.stringValue;
        
		NSNumber *minutes = [timeDict fsp_objectForKey:@"M" expectedClass:[NSNumber class]];
		if ([minutes integerValue] >= 0) {
			NSNumber *seconds = [timeDict fsp_objectForKey:@"S" defaultValue:@0];
			NSString *secondString = seconds.intValue < 10 ? [NSString stringWithFormat:@"0%@", seconds] : seconds.stringValue;
			self.segmentDescription = [NSString stringWithFormat:@"%@:%@", minutes, secondString];
		} else {
			self.segmentDescription = @"--";
		}
    }
}

#pragma mark - Utilities
- (NSString *)naturalLanguageStringForSegmentNumber:(NSString *)segmentNumber;
{
    NSInteger integerValue = [segmentNumber integerValue];
	if (integerValue == 0) return nil;
	else return [@(integerValue) fsp_ordinalStringValue];
}

- (BOOL)isOvertime
{
    return NO;
}

- (NSUInteger)numberOfOvertimes
{
    return 0;
}

- (Class)getMassRelevanceClass
{
    return [FSPMassRelevanceViewController class];
}

@end
