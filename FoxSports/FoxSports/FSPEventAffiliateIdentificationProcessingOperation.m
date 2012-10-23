//
//  FSPEventAffiliateIdentificationProcessingOperation.m
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventAffiliateIdentificationProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPOrganization.h"
#import "FSPCoreDataManager.h"

@interface FSPEventAffiliateIdentificationProcessingOperation ()
@property (nonatomic, strong) NSDictionary *affiliateInfo;
@property (nonatomic, strong) NSArray *organizationIds;
@end

@implementation FSPEventAffiliateIdentificationProcessingOperation

@synthesize affiliateInfo=_affiliateInfo;
@synthesize organizationIds=_organizationIds;

- (id)initWithAffiliateInfo:(NSDictionary *)affiliateInfo organizationIds:(NSArray *)organizationIds
                    context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context]) {
        self.affiliateInfo = affiliateInfo;
        self.organizationIds = organizationIds;
    }
    
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPEvent"];
        NSMutableSet *orgs = [NSMutableSet set];
        for (NSManagedObjectID *orgId in self.organizationIds) {
            FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:orgId error:nil];
            if (organization) {
                [orgs addObject:organization.uniqueIdentifier];
            } else {
                FSPLogFetching(@"%@: couldn't find organization for id %@", self.class.description, orgId);
            }
        }
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier IN %@", orgs];
        NSArray *existingEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        for (FSPEvent *event in existingEvents) {
            event.channelDisplayName = @"FOXW";
        }
    }];
}

@end
