//
//  FSPEventProcessingOperation.h
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPOrganization;

@interface FSPEventsProcessingOperation : FSPProcessingOperation
- (id)initWithEvents:(NSArray *)events batch:(BOOL)batch organizationIds:(NSArray *)organizationIds context:(NSManagedObjectContext *)context;
@end
