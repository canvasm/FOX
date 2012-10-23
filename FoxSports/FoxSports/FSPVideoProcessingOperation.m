//
//  FSPVideoProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 4/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideoProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPVideo.h"
#import "FSPOrganization.h"

@interface FSPVideoProcessingOperation()
@property (nonatomic, copy) NSDictionary *videos;
@property (nonatomic) NSArray * organizationIDs;
@property (nonatomic) NSManagedObjectID * eventID;
@end

@implementation FSPVideoProcessingOperation

@synthesize videos = _videos;
@synthesize organizationIDs;
@synthesize eventID;


- (id)initWithVideos:(NSDictionary *)videos forOrgIDs:(NSArray *)orgIds
       context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.videos = videos;
        self.organizationIDs = orgIds;
    }
    return self;
}

- (id)initWithVideos:(NSDictionary *)videos forEventID:(NSManagedObjectID *)eventId
       context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.videos = videos;
        self.eventID = eventId;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    if (self.videos ) {
        [self.managedObjectContext performBlockAndWait:^{
            FSPEvent *currentEvent;
            NSMutableSet * currentOrgs = [NSMutableSet set];
            if (self.eventID) {
                currentEvent = (FSPEvent *)[self.managedObjectContext existingObjectWithID:self.eventID error:nil];
            } else if (self.organizationIDs) {
                for (NSManagedObjectID * org in self.organizationIDs) {
                    FSPOrganization *currentOrg = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:org error:nil];
                    if (currentOrg) {
                        [currentOrgs addObject:currentOrg];
                    }
                }
            }
            
            NSArray *entries = [self.videos objectForKey:@"entries"];
            
            //Fetch all videos we already have that are in this dictionary
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPVideo"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier IN %@", [entries valueForKeyPath:FSPVideoUniqueIdentifierKey]];
            
            //Create a dictionary with the key as the uniqueIdentifier and the FSPVideo as the content
            NSArray *existingVideosArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            NSArray *keys = [existingVideosArray valueForKeyPath:@"uniqueIdentifier"];
            NSDictionary *existingVideosDictionary = [NSDictionary dictionaryWithObjects:existingVideosArray forKeys:keys];
            
            //for every video passed in search the existing dictionary if it already exists
            for (NSDictionary *video in entries) {
                FSPVideo *videoToUpdate = [existingVideosDictionary objectForKey:[video objectForKey:FSPVideoUniqueIdentifierKey]];
                
                if (!videoToUpdate) {
                    videoToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"FSPVideo"
                                                                  inManagedObjectContext:self.managedObjectContext];
                }
                
                [videoToUpdate populateWithDictionary:video];
                if (currentOrgs.count) {
                    [videoToUpdate addOrganizations:currentOrgs];
                } else if (currentEvent) {
                    [videoToUpdate addEventsObject:currentEvent];
                }
                
            }
        }];
    }
}

@end
