//
//  FSPOrganizationProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationProcessingOperation.h"
#import "FSPOrganizationValidator.h"
#import "FSPOrganization.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPCoreDataManager.h"
#import "FSPSoccerStandingsRule.h"
#import "FSPManagedObjectCache.h"
#import "NSDictionary+FSPExtensions.h"

static NSSet *whitelistBranchSet;

@interface FSPOrganizationProcessingOperation ()
@property (nonatomic, copy) NSArray *organizations;
@property (nonatomic, strong) NSMutableArray *initialOrgs;
@property (nonatomic, copy) NSSet *insertedObjectIDs;
@property (nonatomic, copy) NSSet *deletedObjectIDs;
@property (nonatomic, copy) NSSet *updatedObjectIDs;
@property (nonatomic, strong) FSPOrganizationValidator *validator;
@property (nonatomic, strong) FSPManagedObjectCache *organizationsCache;

- (void)updateCurrentLevelOrganizations:(NSArray *)currentOrgs parent:(FSPOrganization *)parent context:(NSManagedObjectContext *)context level:(NSUInteger)level;

@end

@implementation FSPOrganizationProcessingOperation
@synthesize organizations = _organizations;
@synthesize validator;
@synthesize insertedObjectIDs;
@synthesize updatedObjectIDs;
@synthesize deletedObjectIDs;
@synthesize initialOrgs;

- (id)initWithOrganizations:(NSArray *)organizations context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.organizations = organizations;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    // Quick check to speed up the process
    if (self.organizations.count == 0)
        return;

    [self.managedObjectContext performBlockAndWait:^{
		self.organizationsCache = [FSPManagedObjectCache cacheForEntityName:@"FSPOrganization"
                                                                 primaryKey:@"uniqueIdentifier"
                                                           cacheSubentities:NO
                                                                  inContext:self.managedObjectContext];
        self.initialOrgs = [NSMutableArray arrayWithArray:[self.organizationsCache allObjects]];
        
        self.validator = [[FSPOrganizationValidator alloc] init];
        
        [self updateCurrentLevelOrganizations:self.organizations parent:nil context:self.managedObjectContext level:1];
        
        // Now delete orgs that don't exist anymore
        for (FSPOrganization *org in self.initialOrgs) {
            [self.managedObjectContext deleteObject:org];
        }
        
        NSMutableSet *tmpSet = [NSMutableSet set];
        for (FSPOrganization *org in [self.managedObjectContext updatedObjects]) {
            [tmpSet addObject:[org objectID]];
        }
        self.updatedObjectIDs = tmpSet;
        
        tmpSet = [NSMutableSet set];
        for (FSPOrganization *org in [self.managedObjectContext insertedObjects]) {
            [tmpSet addObject:[org objectID]];
        }
        self.insertedObjectIDs = tmpSet;
        
        tmpSet = [NSMutableSet set];
        for (FSPOrganization *org in [self.managedObjectContext deletedObjects]) {
            [tmpSet addObject:[org objectID]];
        }
        self.deletedObjectIDs = tmpSet;
    }];    
}

+ (NSSet *)whitelistSet;
{
    if (whitelistBranchSet) {
        return whitelistBranchSet;
    }
    
    whitelistBranchSet = [NSSet setWithObjects:
                          @"NFL",
                          @"CFB",
                          @"MLB",
                          @"NHL",
                          @"NBA",
                          @"CBK",
                          @"WCBK",
                          @"NASCAR",
                          @"NASCAR_SPRINT",
                          @"NASCAR_NATIONWIDE",
                          @"NASCAR_CWTS",
                          @"UFC",
                          @"GOLF_PGA",
                          @"TENNIS",
                          @"TENNIS_ATP",
                          @"TENNIS_WTA",
                          nil];
    
    // AUTORACING
    // AUTORACING_FORM1
    // AUTORACING_GRANDAM
    // AUTORACING_IRL
    // AUTORACING_LEMANS
    // AUTORACING_NHRA
    // MOTORACING
    // MOTORACING_MOTOGP
    // MOTORACING_AMAPRO
    // MOTORACING_SMCROSS
    // MOTORACING_WSUPERBIKE
    // GOLF_PGA
    // GOLF
    // GOLF_NWID
    // GOLF_CHMP
    // GOLF_EURO
    // GOLF_LPGA
    // BOXING
    // WNBA
    // ACTION_SPORTS
    // OLYMPICS
    // FUEL TV
    // SPEED
    // FOX SOCCER
    
    return  whitelistBranchSet;
}

+ (BOOL)branchIsWhitlisted:(NSString *)branchName;
{
#if 0
	return YES;
#endif

    if ([branchName hasPrefix:@"SOCCER"]) {
        return YES;
    }
    
    for (NSString *whitelistedBranch in [self whitelistSet]) {
        if ([branchName isEqualToString:whitelistedBranch]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateCurrentLevelOrganizations:(NSArray *)currentOrgs parent:(FSPOrganization *)parent context:(NSManagedObjectContext *)context level:(NSUInteger)level;
{
    for (NSDictionary *org in currentOrgs) {
        NSDictionary *validatedOrg = [self.validator validateDictionary:org error:nil];
        if (validatedOrg && ([[self class] branchIsWhitlisted:[org valueForKey:@"branch"]])) {
            // Check to see if object exists
            FSPOrganization *orgToUpdate = (FSPOrganization *)[self.organizationsCache lookupObjectByIdentifier:[validatedOrg objectForKey:FSPOrganizationIdKey]];
            
            if (orgToUpdate) {
                [self.initialOrgs removeObject:orgToUpdate];
            } else {
                orgToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"FSPOrganization" inManagedObjectContext:context];

                // Trigger notifications
                [self.managedObjectContext processPendingChanges];
            }
            
            [orgToUpdate populateWithDictionary:validatedOrg];
            
            //Hierarchy Info
            FSPOrganizationHierarchyInfo *currentInfo;
            if (orgToUpdate.currentHierarchyInfo.count) {
                for (FSPOrganizationHierarchyInfo *info in orgToUpdate.currentHierarchyInfo) {
                    if (info.parentOrg == parent && info.currentOrg == orgToUpdate)
                        currentInfo = info;
                }
            }
            
            if (!currentInfo) {
                currentInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FSPOrganizationHierarchyInfo" inManagedObjectContext:context];
                currentInfo.currentOrg = orgToUpdate;
                currentInfo.parentOrg = parent;
            }
            currentInfo.branch = [validatedOrg fsp_objectForKey:FSPOrganizationBranchKey defaultValue:@""];
            currentInfo.ordinal = [validatedOrg fsp_objectForKey:FSPOrganizationOrdinalKey defaultValue:@1];
            currentInfo.isTeam = [NSNumber numberWithBool:NO];
            currentInfo.level = [NSNumber numberWithInt:level];

            //Children
            NSArray *children = [validatedOrg objectForKey:FSPOrganizationChildrenKey];
            if ([children count] > 0) {
                [self updateCurrentLevelOrganizations:children parent:orgToUpdate context:context level:level + 1];
            }
            if (!parent && orgToUpdate.parents.count != 0) {
                // If removing the parent, remove from the allParents set too
                [orgToUpdate removeParents:orgToUpdate.parents];
                [orgToUpdate removeAllParents:orgToUpdate.parents];
            }
            
            if (parent) {
                [orgToUpdate addParentsObject:parent];
                [orgToUpdate addAllParentsObject:parent];
            }
            
            // Soccer Standings Rules
            if ([currentInfo.branch hasPrefix:@"SOCCER"]) {
                NSArray *soccerStandingsRules = [validatedOrg objectForKey:@"standingRules"];
                FSPSoccerStandingsRule *standingsRule;
                if (orgToUpdate.soccerStandingsRules.count) {
                    NSSet *rules = [orgToUpdate.soccerStandingsRules copy];
                    [orgToUpdate removeSoccerStandingsRules:rules];
                }
                else if ([soccerStandingsRules count]) {
                    for (NSDictionary *rule in soccerStandingsRules) {
                        standingsRule = [NSEntityDescription insertNewObjectForEntityForName:@"FSPSoccerStandingsRule" inManagedObjectContext:context];
                        [standingsRule populateWithDictionary:rule];
                        [orgToUpdate addSoccerStandingsRulesObject:standingsRule];
                        standingsRule.organization = orgToUpdate;
                    }
                }
            }
        }
    }
    
}


@end
