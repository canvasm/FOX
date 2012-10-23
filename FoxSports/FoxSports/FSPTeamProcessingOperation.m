//
//  FSPTeamProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 3/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPOrganization.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPTeam.h"
#import "FSPTeamValidator.h"
#import "FSPLogging.h"
#import "FSPManagedObjectCache.h"
#import "NSDictionary+FSPExtensions.h"


@interface FSPTeamProcessingOperation ()
@property (nonatomic, copy) NSManagedObjectID *orgMOID;
@property (nonatomic, strong) NSMutableArray *initialTeams;
@property (nonatomic, strong) FSPManagedObjectCache *teamsCache;
@end

@implementation FSPTeamProcessingOperation
@synthesize teams = _teams;
@synthesize orgMOID = _orgMOID;
@synthesize organizationId = _organization;
@synthesize initialTeams;

- (id)initWithContext:(NSManagedObjectContext *)context teamCache:(FSPManagedObjectCache *)teamCache {
    if ((self = [super initWithContext:context])) {
        _teamsCache = teamCache;
    }
    return self;
}

- (void)setOrganizationId:(NSManagedObjectID *)organizationId;
{
    self.orgMOID = organizationId;
}

- (void)main;
{
    if (self.isCancelled)
        return;

    NSParameterAssert(_teamsCache);
    
    // We have the teams for this organization so update them
    [self.managedObjectContext performBlockAndWait:^{
        FSPOrganization *org = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:self.orgMOID error:nil];
        if (!org)
            return;
                        
        FSPManagedObjectCache *orgCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPOrganization.class)
                                                                          inContext:self.managedObjectContext];
        
        FSPLogDataCoordination(@"updating teams for organization: %@", org.name);
        
        FSPTeamValidator *validator = [[FSPTeamValidator alloc] init];

        for (NSDictionary *teamDict in self.teams) {
            NSDictionary *validatedTeamDict = [validator validateDictionary:teamDict error:nil];
            if (validatedTeamDict) {

                FSPTeam *teamToUpdate = (FSPTeam *)[self.teamsCache lookupObjectByIdentifier:[validatedTeamDict objectForKey:FSPOrganizationIdKey]];

                if (!teamToUpdate) {
					teamToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTeam" inManagedObjectContext:self.managedObjectContext];
					teamToUpdate.uniqueIdentifier = [validatedTeamDict objectForKey:FSPOrganizationIdKey];
                    
                    //Hierarchy Info
                    FSPOrganizationHierarchyInfo *currentInfo;
                    if (teamToUpdate.currentHierarchyInfo.count) {
                        for (FSPOrganizationHierarchyInfo *info in teamToUpdate.currentHierarchyInfo) {
                            if (info.parentOrg == org && info.currentOrg == teamToUpdate)
                                currentInfo = info;
                        }
                    }
                    
                    if (!currentInfo) {
                        currentInfo = [NSEntityDescription insertNewObjectForEntityForName:@"FSPOrganizationHierarchyInfo" inManagedObjectContext:self.managedObjectContext];
                        currentInfo.currentOrg = teamToUpdate;
                        currentInfo.parentOrg = org;
                    }
                    currentInfo.branch = [validatedTeamDict fsp_objectForKey:FSPOrganizationBranchKey defaultValue:@""];
                    currentInfo.ordinal = [validatedTeamDict fsp_objectForKey:FSPOrganizationOrdinalKey defaultValue:@1];
                    currentInfo.isTeam = [NSNumber numberWithBool:YES];
                    currentInfo.level = @-1;
                    
                    //Children
                    [org addAllChildrenObject:teamToUpdate];
                    [org addTeamsObject:teamToUpdate];
                    
                    while (TRUE) {
                        NSMutableSet *newOrgs = NSMutableSet.new;
                        
                        // parent from fsid in dict
                        FSPOrganization *parentOrg = (FSPOrganization *)[orgCache lookupObjectByIdentifier:[validatedTeamDict objectForKey:@"parentFsId"]];
                        if (parentOrg) {
                            [newOrgs addObject:parentOrg];
                        }
                        
                        for (FSPOrganization *ancestorOrg in teamToUpdate.allParents) {
                            [newOrgs addObjectsFromArray:ancestorOrg.allParents.allObjects];
                        }
                        [newOrgs minusSet:teamToUpdate.allParents];
                        if (!newOrgs.count) {
                            break;
                        }
                        [teamToUpdate addAllParents:newOrgs];
                    }
                }
                [teamToUpdate populateWithDictionary:validatedTeamDict];
				teamToUpdate.viewTypeString = org.viewTypeString;
                FSPLogDataCoordination(@"updated team %@ in org: %@", teamToUpdate.name, [org name]);
                
            }
        }
        
        org.teamsAreUpdated = @(YES);
        FSPLogDataCoordination(@"Finished updating teams for org %@", org.name);
    }];
}

@end
