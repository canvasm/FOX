//
//  FSPOrganizationProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPOrganizationProcessingOperation : FSPProcessingOperation
@property (nonatomic, copy, readonly) NSSet *insertedObjectIDs;
@property (nonatomic, copy, readonly) NSSet *deletedObjectIDs;
@property (nonatomic, copy, readonly) NSSet *updatedObjectIDs;

- (id)initWithOrganizations:(NSArray *)organizations context:(NSManagedObjectContext *)context;

@end
