//
//  FSPTitleHolderProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTitleHolderProcessingOperation.h"
#import "FSPOrganization.h"
#import "FSPFightTitleHolder.h"
#import "FSPCoreDataManager.h"


@implementation FSPTitleHolderProcessingOperation {
NSArray *titleHolders;
NSManagedObjectID *orgManagedObjectID;
}

- (id)initWithOrgId:(NSManagedObjectID *)orgId titleHoldersData:(NSArray *)titleholdersData
            context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context])
    {
        titleHolders = [titleholdersData copy];
        orgManagedObjectID = orgId;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        FSPOrganization *org = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:orgManagedObjectID error:nil];
        
        if (!org)
            return;
        
        if (titleHolders) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPFightTitleHolder"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@", org.branch];
            
            NSArray *existingTitleHolders = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            NSUInteger index = 0;
            for (NSDictionary *titleHolder in titleHolders) {
                FSPFightTitleHolder *newTitleHolder;
                if (index < [existingTitleHolders count])
                    newTitleHolder = [existingTitleHolders objectAtIndex:index];
                else 
                    newTitleHolder = [NSEntityDescription insertNewObjectForEntityForName:@"FSPFightTitleHolder"
                                                                   inManagedObjectContext:self.managedObjectContext];
                
                newTitleHolder.branch = org.branch;
                [newTitleHolder populateWithDictionary:titleHolder];
                ++index;
            }
            
            for (; index < [existingTitleHolders count]; ++index) {
                [self.managedObjectContext deleteObject:[existingTitleHolders objectAtIndex:index]];
            }
        }
    }];
}

@end
