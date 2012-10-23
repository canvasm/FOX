//
//  FSPOrganization.m
//  FoxSports
//
//  Created by Chase Latta on 1/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganization.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPLogging.h"
#import "FSPImageFetcher.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPCoreDataManager.h"
#import "FSPDataCoordinator.h"
#import "FSPTeam.h"
#import "FSPGame.h"

NSString * const FSPOrganizationDidUpdateFavoritedStateNotification = @"FSPOrganizationDidUpdateFavoritedStateNotification";

NSString * const FSPSelectedEventUserDefaultsPrefixKey = @"selectedEvent";

NSString * const FSPOrganizationIdKey = @"fsId";
NSString * const FSPOrganizationBranchKey = @"branch";
NSString * const FSPOrganizationNameKey = @"name";

NSString * const FSPOrganizationLogo1URLKey = @"logo1Url";
NSString * const FSPOrganizationLogo2URLKey = @"logo2Url";
NSString * const FSPOrganizationSelectableKey = @"selectable";
NSString * const FSPOrganizationChildrenKey = @"children";
NSString * const FSPOrganizationHasNewsKey = @"hasNews";
NSString * const FSPOrganizationHasTeamsKey = @"hasTeams";
NSString * const FSPOrganizationCustomizableKey = @"customizable";
NSString * const FSPOrganizationOrdinalKey = @"ordinal";
NSString * const FSPOrganizationAlertableKey = @"alerts";
NSString * const FSPOrganizationTypeKey = @"itemType";

NSString * const FSPNBAEventBranchType = @"NBA";
NSString * const FSPWNBAEventBranchType = @"WNBA";
NSString * const FSPPGAEventBranchType = @"GOLF_PGA";
NSString * const FSPGolfBranchType = @"GOLF";
NSString * const FSPMLBEventBranchType = @"MLB";
NSString * const FSPNFLEventBranchType = @"NFL";
NSString * const FSPNHLEventBranchType = @"NHL";
NSString * const FSPNCAABasketballEventBranchType = @"CBK";
NSString * const FSPNCAAWBasketballEventBranchType = @"WCBK";
NSString * const FSPNCAAFootballEventBranchType = @"NCAAF";
NSString * const FSPNCAAFootballEventAltBranchType = @"CFB";
NSString * const FSPSoccerEventBranchType = @"SOCCER_MLS";
NSString * const FSPUFCEventBranchType = @"UFC";
NSString * const FSPTennisEventBranchType = @"WTA";
NSString * const FSPNASCAREventBranchType = @"NASCAR";
NSString * const FSPAutoRacingEventBranchType = @"AUTORACING";


// Org Types
NSString * const FSPOrganizationGroupingType = @"GROUPING";
NSString * const FSPOrganizationLeagueType = @"LEAGUE";
NSString * const FSPOrganizationTournamentType = @"TOURNAMENT";
NSString * const FSPOrganizationTeamType = @"TEAM";
NSString * const FSPOrganizationDivisionType = @"DIVISION";
NSString * const FSPOrganizationTop25Type = @"TOP25";
NSString * const FSPOrganizationConferenceType = @"CONFERENCE";
NSString * const FSPOrganizationEventType = @"EVENT";


@implementation FSPOrganization

@dynamic teamsAreUpdated;
@dynamic uniqueIdentifier;
@dynamic name;
@dynamic selectable;
@dynamic parents;
@dynamic children;
@dynamic allParents;
@dynamic allChildren;
@dynamic hasNews;
@dynamic hasTeams;
@dynamic customizable;
@dynamic ordinal;
@dynamic alertMask;
@dynamic logo1URL;
@dynamic logo2URL;
@dynamic schedule;
@dynamic type;
@dynamic branch;
@dynamic teams;
@dynamic events;
@dynamic favorited;
@dynamic userDefinedOrder;
@dynamic currentHierarchyInfo;
@dynamic parentHierarchyInfo;
@dynamic videos;
@dynamic soccerStandingsRules;
@dynamic viewTypeString;

@synthesize viewType = _viewType;

+ (NSString *)baseBranchForBranch:(NSString *)branch
{
	NSString * branchType = [branch uppercaseString];
    if ([branchType rangeOfString:@"SOCCER"].location != NSNotFound) {
        branchType = FSPSoccerEventBranchType;
	} else if ([branchType rangeOfString:@"NASCAR"].location != NSNotFound) {
		branchType = FSPNASCAREventBranchType;
	}
	else if ([branchType rangeOfString:@"GOLF"].location != NSNotFound) {
		branchType = FSPGolfBranchType;
	}
    else if ([branchType rangeOfString:@"NHL"].location != NSNotFound) {
		branchType = FSPNHLEventBranchType;
	}
    else if ([branchType rangeOfString:@"TENNIS"].location != NSNotFound) {
		branchType = FSPTennisEventBranchType;
	}
	else if ([branchType isEqualToString:FSPNCAAFootballEventBranchType] ||
             [branchType isEqualToString:FSPNCAAFootballEventAltBranchType]) {
		branchType = FSPNCAAFootballEventBranchType;
	}
    return branchType;

}


- (void)awakeFromInsert;
{
    [super awakeFromInsert];
    
    [self setPrimitiveValue:@(NO) forKey:@"teamsAreUpdated"];
}

//- (void)awakeFromFetch {
//    [self addObserver:self forKeyPath:@"favorited" options:NSKeyValueObservingOptionNew context:NULL];
//}
//
//- (void)didTurnIntoFault {
////    [self removeObserver:self forKeyPath:@"favorited"];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"favorited"]) {
//        NSLog(@"favorited changed. change dictionary was %@", change);
//    }
//}

- (void)populateWithDictionary:(NSDictionary *)organizationData;
{
    if(!organizationData) return;
    
    NSNumber *defaultNO = @(NO);
    NSNumber *defaultYES = @(YES);
    
    self.uniqueIdentifier = [organizationData objectForKey:FSPOrganizationIdKey];
    self.branch = [organizationData objectForKey:FSPOrganizationBranchKey];
    self.type = [organizationData objectForKey:FSPOrganizationTypeKey];
    self.name = [organizationData objectForKey:FSPOrganizationNameKey];
	self.viewTypeString = [organizationData objectForKey:@"viewType"];

    self.logo1URL = [organizationData fsp_objectForKey:FSPOrganizationLogo1URLKey defaultValue:@""];
    self.logo2URL = [organizationData fsp_objectForKey:FSPOrganizationLogo2URLKey defaultValue:@""];
    self.selectable = [organizationData fsp_objectForKey:FSPOrganizationSelectableKey defaultValue:defaultYES];
    self.hasNews = [organizationData fsp_objectForKey:FSPOrganizationHasNewsKey defaultValue:defaultNO];
    self.hasTeams = [organizationData fsp_objectForKey:FSPOrganizationHasTeamsKey defaultValue:defaultNO];
    self.customizable = [organizationData fsp_objectForKey:FSPOrganizationCustomizableKey defaultValue:defaultYES];
    self.ordinal = [organizationData fsp_objectForKey:FSPOrganizationOrdinalKey defaultValue:@1];
    self.alertMask = [organizationData fsp_objectForKey:FSPOrganizationAlertableKey defaultValue:defaultNO];
}

- (void)updateFavoriteState:(BOOL)isFavorite {
    BOOL didChangeState = ([self.favorited boolValue] != isFavorite);
    self.favorited = @(isFavorite);
    if (!isFavorite) {
        self.userDefinedOrder = @(NSNotFound);
    }
    if (didChangeState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FSPOrganizationDidUpdateFavoritedStateNotification object:self];
    }
    [FSPCoreDataManager.sharedManager synchronizeSaving];
}

- (NSString *)organizationSingleTypeString;
{
    if (self.viewType == FSPRacingViewType) {
         return @"Series";
    } else if (self.viewType == FSPTennisViewType) {
        return  @"Tour";
    }
    return @"Team";
}

- (NSString *)predicateClassString;
{
    if ([self.viewTypeString isEqualToString:@"NCAAF_TOP25"]) {
        return @"FSPGame";
    }
    
    return @"FSPEvent";
}

- (NSPredicate *)matchingEventsPredicate;
{
    if (self.viewType == FSPRacingViewType && self.children.count) {
        NSSet *children = self.children;
        NSMutableArray *childPredicates = [NSMutableArray arrayWithCapacity:children.count];
        for (FSPOrganization *childOrg in children) {
            [childPredicates addObject:[childOrg matchingEventsPredicate]];
        }
        return [NSCompoundPredicate orPredicateWithSubpredicates:childPredicates];
    }
    
    if ([self.viewTypeString isEqualToString:@"NCAAF_TOP25"]) {
        // NCAA TOP 25
        return [NSPredicate predicateWithFormat:@"((homeTeam.primaryRank > 0 AND homeTeam.primaryRank < 26) OR (awayTeam.primaryRank > 0 AND awayTeam.primaryRank < 26)) AND (organizations contains %@)", [[self allParents] anyObject]];
    }
    
    if ([self.viewTypeString isEqualToString:@"NCAAF_ALL_FBS"]) {
        // ALL FBS is really the same as all NCAA
        return [NSPredicate predicateWithFormat:@"organizations contains %@", [[self allParents] anyObject]];

    }
    
    if (self.branch == FSPNCAAFootballEventAltBranchType || self.branch == FSPNCAAFootballEventBranchType || self.viewType == FSPNCAAFViewType) {
        return [NSPredicate predicateWithFormat:@"organizations contains %@", self];
    }
    
    return [NSPredicate predicateWithFormat:@"branch == %@", self.branch];
}

- (void)updateRankings;
{
    FSPDataCoordinator *dataCoordinator = [FSPDataCoordinator defaultCoordinator];
        
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPOrganization"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(branch == %@) AND (name == %@)", self.branch, @"Top 25"];
    
    NSError *err;
    NSArray *results = [[[FSPCoreDataManager sharedManager] GUIObjectContext] executeFetchRequest:fetchRequest error:&err];
    if (err)  {
        NSLog(@"error rankings for %@:%@", self, err);
    } else if (results.count) {
        FSPOrganization *top25 = [results lastObject];
        
#ifdef DEBUG
        NSParameterAssert([top25 isKindOfClass:[FSPOrganization class]]);
        NSParameterAssert(results.count == 1);
#endif
        
        if ([top25.viewTypeString rangeOfString:@"TOP25"].location != NSNotFound) {
            [dataCoordinator updateRankingsForOrganizationId:self.objectID callback:^(BOOL success){
                // maybe update UI?
            }];
        } else {
#ifdef DEBUG
            NSLog(@"org (%@) found for branch (%@) but it wasn't the top 25", top25.name, self.branch);
#endif
        }
    }
}

- (void)beginUpdating;
{
    FSPDataCoordinator *dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    
    // for orgs where the children aren't returned by FSTS, load the children as well
    if (self.viewType == FSPRacingViewType && self.children.count) {
        for (FSPOrganization *childOrg in self.children) {
            [dataCoordinator beginUpdatingEventsForOrganizationId:childOrg.objectID];
            [dataCoordinator updateStandingsForOrganizationId:childOrg.objectID callback:nil];
        }
    }
    
    if ([self.viewTypeString isEqualToString:@"NCAAF_TOP25"]) {
        // NCAA TOP 25
        id ncaaID = [[[self allParents] anyObject] objectID];
        [dataCoordinator beginUpdatingEventsForOrganizationId:ncaaID];
        [dataCoordinator updateStandingsForOrganizationId:ncaaID callback:nil];
    }

    if ([self.branch isEqualToString:@"CFB"]) {
        [self updateRankings];
    }
    
    [dataCoordinator beginUpdatingEventsForOrganizationId:self.objectID];
    [dataCoordinator updateStandingsForOrganizationId:self.objectID callback:nil];
}

+ (void)endUpdatingOrganziations;
{
    [[FSPDataCoordinator defaultCoordinator] endUpdatingEventsForCurrentOrganizations];
}

- (FSPViewType)viewType
{
	if (_viewType == FSPUnknownViewType) {
		NSString *viewType = self.viewTypeString;
		if ([viewType isEqualToString:@"NFL"]) {
			_viewType = FSPNFLViewType;
		} else if ([viewType rangeOfString:@"NCAAF"].location != NSNotFound) {
			_viewType = FSPNCAAFViewType;
		} else if ([viewType isEqualToString:@"MLB"]) {
			_viewType = FSPBaseballViewType;
		} else if ([viewType isEqualToString:@"NHL"]) {
			_viewType = FSPHockeyViewType;
		} else if ([viewType rangeOfString:@"NBA"].location != NSNotFound) {
			_viewType = FSPBasketballViewType;
		} else if ([viewType rangeOfString:@"NCAAB"].location != NSNotFound) {
			_viewType = FSPNCAABViewType;
		} else if ([viewType rangeOfString:@"NCAAWB"].location != NSNotFound) {
			_viewType = FSPNCAAWBViewType;
		} else if ([viewType rangeOfString:@"NASCAR"].location != NSNotFound) {
			_viewType = FSPRacingViewType;
        } else if ([viewType isEqualToString:@"UFC"]) {
			_viewType = FSPFightingViewType;
        } else if ([viewType rangeOfString:@"SOCCER"].location != NSNotFound) {
			_viewType = FSPSoccerViewType;
		} else if ([viewType rangeOfString:@"GOLF"].location != NSNotFound) {
			_viewType = FSPGolfViewType;
		} else if ([viewType isEqualToString:@"TENNIS"] || [viewType isEqualToString:@"MENS_ATP"] || [viewType isEqualToString:@"WOMENS_WTA"] || [viewType isEqualToString:@"TENNIS_MENS_ATP"]) {
            _viewType = FSPTennisViewType;
        } else {
			NSLog(@"Unknown viewtype:%@!", viewType);
			_viewType = FSPUnknownViewType;
		}
	}
	return _viewType;
}

- (FSPOrganizationHierarchyInfo *)highestLevel;
{
    FSPOrganizationHierarchyInfo *highest;
    for (FSPOrganizationHierarchyInfo *info in self.currentHierarchyInfo) {
            if (!highest)
                highest = info;
            else if (highest.level.intValue > info.level.intValue)
                highest = info;
    }
    return highest;
}

- (FSPOrganization *)highestLevelOrganization;
{
#ifdef DEBUG
    NSParameterAssert(![[self highestLevel] parentOrg]);
#endif
    return [[self highestLevel] currentOrg];
}

- (BOOL)isTeamSport
{
	return (self.viewType == FSPNFLViewType ||
			self.viewType == FSPNCAAFViewType ||
			self.viewType == FSPSoccerViewType ||
			self.viewType == FSPBaseballViewType ||
			self.viewType == FSPBasketballViewType ||
            self.viewType == FSPNCAABViewType ||
            self.viewType == FSPNCAAWBViewType ||
			self.viewType == FSPHockeyViewType);
}

- (BOOL)isTop25
{
    return ([self.viewTypeString rangeOfString:@"TOP25"].location != NSNotFound);
}

- (BOOL)isVirtualConference {
    return ([self.type isEqualToString:@"VIRTUALCONF"]);
}

- (NSString *)baseBranch {
	return [FSPOrganization baseBranchForBranch:self.branch];
}

- (NSString *)longNameDisplayString;
{
    return self.name;
}

- (NSString *)shortNameDisplayString;
{
    return self.name;
}

- (NSSet *)nonEventTeams;
{
    if (!self.isTeamSport) {
        return self.teams;
    }
    
    NSSet *allTeams = self.teams;
    NSMutableSet *filteredTeams = [NSMutableSet setWithCapacity:allTeams.count];
    for (FSPTeam *team in allTeams) {
#ifdef DEBUG
        NSParameterAssert([team isKindOfClass:[FSPTeam class]]);
#endif
        if (![team.isEventOnly boolValue]) {
            [filteredTeams addObject:team];
        }
    }
    return filteredTeams;
}


- (FSPOrganization *)defaultChildOrganization
{
    __block FSPOrganization *defaultChildOrganization = nil;
    
    if ([self.branch isEqualToString:FSPNCAAFootballEventBranchType]) {
        // Find top 25 conference
        [self.children enumerateObjectsUsingBlock:^(FSPOrganization *organization, BOOL *stop){
            if ([organization.type isEqualToString:FSPOrganizationTop25Type]) {
                defaultChildOrganization = organization;
                *stop = YES;
            }
        }];
    }
    
    else if ([self.branch isEqualToString:FSPSoccerEventBranchType]) {
        [self.children enumerateObjectsUsingBlock:^(FSPOrganization *organization, BOOL *stop){
            if ([organization.name isEqualToString:@"Barclay's Premier League"]) {
                defaultChildOrganization = organization;
                *stop = YES;
            }
        }];
    }
    else if ([self.branch isEqualToString:FSPNASCAREventBranchType]) {
        [self.children enumerateObjectsUsingBlock:^(FSPOrganization *organization, BOOL *stop){
            if ([organization.branch isEqualToString:@"NASCAR_SPRINT"]) {
                defaultChildOrganization = organization;
                *stop = YES;
            }
        }];
    }
    
    else {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *conferences = [[self.children allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
        if ([conferences count] > 0) {
            defaultChildOrganization = [conferences objectAtIndex:0];
        }
    }
    
    return defaultChildOrganization;
}

@end
