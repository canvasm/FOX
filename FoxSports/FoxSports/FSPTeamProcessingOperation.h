//
//  FSPTeamProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 3/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPOrganization;
@class FSPManagedObjectCache;

@interface FSPTeamProcessingOperation : FSPProcessingOperation

// These properties MUST be set before adding the operation to an operation Queue!
@property (nonatomic, strong) NSManagedObjectID *organizationId;
@property (nonatomic, copy) NSArray *teams;

- (id)initWithContext:(NSManagedObjectContext *)context teamCache:(FSPManagedObjectCache *)teamCache;

@end
