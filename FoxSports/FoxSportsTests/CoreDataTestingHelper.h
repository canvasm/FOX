//
//  CoreDataTestingHelper.h
//  FoxSports
//
//  Created by Chase Latta on 1/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataTestingHelper : NSObject {
    NSManagedObjectContext *context_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

- (NSManagedObjectContext *)context;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
