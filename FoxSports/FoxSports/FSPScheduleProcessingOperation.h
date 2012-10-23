//
//  FSPScheduleProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPOrganization;

@interface FSPScheduleProcessingOperation : FSPProcessingOperation

- (id)initWithSchedule:(NSArray *)schedule forOrganizationId:(NSManagedObjectID *)organizationIdentifier
         context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSArray * sortedScheduleArray;

@end
