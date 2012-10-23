//
//  FSPOrganization.h
//  FoxSports
//
//  Created by Chase Latta on 1/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    FSPAlertsNone = 0,
    FSPAlertsStart = 1 << 0,
    FSPAlertsFinish = 1 << 1,
	FSPAlertsPhase = 1 << 2,
	FSPAlertsScore = 1 << 3,
	FSPAlertsUpdate = 1 << 4,
	FSPAlertsExciting = 1 << 5
};
typedef NSInteger FSPAlertsMask;


@class FSPOrganizationSchedule, FSPTeam, FSPEvent, FSPOrganizationHierarchyInfo, FSPVideo, FSPSoccerStandingsRule;

extern NSString * const FSPOrganizationDidUpdateFavoritedStateNotification;

// Append the organization's branch to this key to get the selected event for this organization
extern NSString * const FSPSelectedEventUserDefaultsPrefixKey;

// Dictionary Keys
extern NSString * const FSPOrganizationIdKey;
extern NSString * const FSPOrganizationBranchKey;
extern NSString * const FSPOrganizationNameKey;
extern NSString * const FSPOrganizationLogo1URLKey;
extern NSString * const FSPOrganizationLogo2URLKey;
extern NSString * const FSPOrganizationSelectableKey;
extern NSString * const FSPOrganizationChildrenKey;
extern NSString * const FSPOrganizationHasNewsKey;
extern NSString * const FSPOrganizationHasTeamsKey;
extern NSString * const FSPOrganizationDataPathKey;
extern NSString * const FSPOrganizationCustomizableKey;
extern NSString * const FSPOrganizationOrdinalKey;
extern NSString * const FSPOrganizationAlertableKey;
extern NSString * const FSPOrganizationTypeKey;


// Chip Types
extern NSString * const FSPNBAEventBranchType;
extern NSString * const FSPWNBAEventBranchType;
extern NSString * const FSPPGAEventBranchType;
extern NSString * const FSPGolfBranchType;
extern NSString * const FSPMLBEventBranchType;
extern NSString * const FSPNFLEventBranchType;
extern NSString * const FSPNHLEventBranchType;
extern NSString * const FSPNCAABasketballEventBranchType;
extern NSString * const FSPNCAAWBasketballEventBranchType;
extern NSString * const FSPNCAAFootballEventBranchType;
extern NSString * const FSPNCAAFootballEventAltBranchType;
extern NSString * const FSPSoccerEventBranchType;
extern NSString * const FSPUFCEventBranchType;
extern NSString * const FSPTennisEventBranchType;
extern NSString * const FSPNASCAREventBranchType;
extern NSString * const FSPAutoRacingEventBranchType;


// View Types
typedef enum {
	FSPUnknownViewType = 0,
	FSPBasketballViewType,
	FSPNCAABViewType,
	FSPNCAAWBViewType,
	FSPNFLViewType,
	FSPNCAAFViewType,
	FSPSoccerViewType,
	FSPGolfViewType,
	FSPRacingViewType,
	FSPFightingViewType,
	FSPHockeyViewType,
	FSPBaseballViewType,
    FSPTennisViewType
} FSPViewType;

// Org Types
extern NSString * const FSPOrganizationGroupingType;
extern NSString * const FSPOrganizationLeagueType;
extern NSString * const FSPOrganizationTournamentType;
extern NSString * const FSPOrganizationTeamType;
extern NSString * const FSPOrganizationDivisionType;
extern NSString * const FSPOrganizationTop25Type;
extern NSString * const FSPOrganizationConferenceType;
extern NSString * const FSPOrganizationEventType;


@interface FSPOrganization : NSManagedObject

+ (NSString *)baseBranchForBranch:(NSString *)branch;

/// Non Optional Properties
/**
 The globalliy unique identifier for the organization.
 */
@property (nonatomic, retain) NSString * uniqueIdentifier;

/**
 The feed branch for the organization.  This property is used 
 to give a hint to the server for increased performance.
 */
@property (nonatomic, retain) NSString *branch;

- (NSString *)baseBranch;

/**
 The display name for the organization
 */
@property (nonatomic, retain) NSString * name;

/**
 * For the major pro sports, use team "nickname" (NHL, NBA, WNBA, MLB, NFL)
 * All other sports should use the "name" field
 */
@property (nonatomic, strong, readonly) NSString *shortNameDisplayString;
@property (nonatomic, strong, readonly) NSString *longNameDisplayString;


/// Optional Properties

/**
 BOOL indicating if the organization has updated its teams.
 */
@property (nonatomic, retain) NSNumber * teamsAreUpdated;

/**
 True if the organization can be selected as a favorite during user customization
 */
@property (nonatomic, retain) NSNumber * selectable;

/**
 The parent organization.
 */
@property (nonatomic, retain) NSSet * parents;

/**
 The immediate children of this organization.
 */
@property (nonatomic, retain) NSSet * children;

/**
 All ancestors and descendants of this organization.
 */
@property (nonatomic, retain) NSSet * allParents;
@property (nonatomic, retain) NSSet * allChildren;

/**
 A boolean indicating whether or not the organization will ever have news or video.
 */
@property (nonatomic, strong) NSNumber * hasNews;

/**
 A boolean indicating whether or not the organization has teams.  
 This property can be used to determine if the organization
 needs to make extra network calls to fetch teams.
 */
@property (nonatomic, strong) NSNumber * hasTeams;

@property (nonatomic, readonly) BOOL isTeamSport;

/**
 The type of view that this organization represents (Basketball, Football, etc.)
 */
@property (readonly) FSPViewType viewType;

/**
 A Boolean indicating whether this organization can be customized.
 */
@property (nonatomic, retain) NSNumber * customizable;

/**
 The order in which items at this level should be displayed
 */
@property (nonatomic, retain) NSNumber * ordinal;

/**
 A bitmask indicating what notifications the organization can receive.
 */
@property (nonatomic, retain) NSNumber * alertMask;

/**
 The type of organization.
 */
@property (nonatomic, retain) NSString * type;

@property (nonatomic, retain) NSNumber *favorited;
@property (nonatomic, retain) NSNumber *userDefinedOrder;

/**
 The organizations schedule object.
 */
@property (nonatomic, retain) FSPOrganizationSchedule *schedule;

/**
 The organizations teams.
 */
@property (nonatomic, retain) NSSet *teams;
- (NSSet *)nonEventTeams;

/**
 The organizations events.
 */
@property (nonatomic, retain) NSSet *events;

/**
 The videos associated with the Organization.
 */
@property (nonatomic, retain) NSSet * videos;

/**
 The child organization to use as a default conference.
 */
- (FSPOrganization *)defaultChildOrganization;


// Logos
@property (nonatomic, retain) NSString * logo1URL;
@property (nonatomic, retain) NSString * logo2URL;

//Hierarchy info
@property (nonatomic, retain) NSSet *currentHierarchyInfo;
@property (nonatomic, retain) NSSet *parentHierarchyInfo;

// Soccer standings rules
@property (nonatomic, retain) NSSet *soccerStandingsRules;

// Top 25
- (BOOL)isTop25;
- (BOOL)isVirtualConference;

@property (nonatomic, retain) NSString *viewTypeString;

- (FSPOrganizationHierarchyInfo *)highestLevel;
- (FSPOrganization *)highestLevelOrganization;

- (void)populateWithDictionary:(NSDictionary *)organizationData;

/**
 * Update the .favorited property on this org and queue a save operation on the GUI context. If isFavorite is NO,
 * the userDefinedOrder property is reset.
 */
- (void)updateFavoriteState:(BOOL)isFavorite;

- (NSString *)predicateClassString;
- (NSPredicate *)matchingEventsPredicate;
- (void)updateRankings;
- (void)beginUpdating;
+ (void)endUpdatingOrganziations;

- (NSString *)organizationSingleTypeString;

@end


@interface FSPOrganization (CoreDataGeneratedAccessors)

- (void)addCurrentHierarchyInfoObject:(FSPOrganizationHierarchyInfo *)value;
- (void)removeCurrentHierarchyInfoObject:(FSPOrganizationHierarchyInfo *)value;
- (void)addCurrentHierarchyInfo:(NSSet *)values;
- (void)removeCurrentHierarchyInfo:(NSSet *)values;

- (void)addParentHierarchyInfoObject:(FSPOrganizationHierarchyInfo *)value;
- (void)removeParentHierarchyInfoObject:(FSPOrganizationHierarchyInfo *)value;
- (void)addParentHierarchyInfo:(NSSet *)values;
- (void)removeParentHierarchyInfo:(NSSet *)values;

- (void)addParentsObject:(FSPOrganization *)value;
- (void)removeParentsObject:(FSPOrganization *)value;
- (void)addParents:(NSSet *)values;
- (void)removeParents:(NSSet *)values;

- (void)addChildrenObject:(FSPOrganization *)child;
- (void)removeChildrenObject:(FSPOrganization *)child;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addTeamsObject:(FSPTeam *)team;
- (void)removeTeamsObject:(FSPTeam *)team;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

- (void)addEventsObject:(FSPEvent *)value;
- (void)removeEventsObject:(FSPEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addAllChildrenObject:(FSPOrganization *)value;
- (void)removeAllChildrenObject:(FSPOrganization *)value;
- (void)addAllChildren:(NSSet *)values;
- (void)removeAllChildren:(NSSet *)values;

- (void)addAllParentsObject:(FSPOrganization *)value;
- (void)removeAllParentsObject:(FSPOrganization *)value;
- (void)addAllParents:(NSSet *)values;
- (void)removeAllParents:(NSSet *)values;

- (void)addVideosObject:(FSPVideo *)value;
- (void)removeVideosObject:(FSPVideo *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

- (void)addSoccerStandingsRulesObject:(FSPSoccerStandingsRule *)value;
- (void)removeSoccerStandingsRulesObject:(FSPSoccerStandingsRule *)value;
- (void)addSoccerStandingsRules:(NSSet *)values;
- (void)removeSoccerStandingsRules:(NSSet *)values;


@end
