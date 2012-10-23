//
//  CoreDataTestingHelper.m
//  FoxSports
//
//  Created by Chase Latta on 1/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "CoreDataTestingHelper.h"

@implementation CoreDataTestingHelper

- (NSManagedObjectContext *)context;
{
    if (context_)
        return context_;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    context_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context_ setPersistentStoreCoordinator:coordinator];
    return context_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_)
        return persistentStoreCoordinator_;
    
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FoxSports" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return persistentStoreCoordinator_;
}

@end
