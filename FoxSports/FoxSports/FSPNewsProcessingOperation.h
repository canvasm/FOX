//
//  FSPTopNewsProcessingOperation.h
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPNewsProcessingOperation : FSPProcessingOperation

- (id)initWithTopNewsHeadlines:(NSArray *)headlines context:(NSManagedObjectContext *)context;
- (id)initWithNewsHeadlines:(NSArray *)headlines organizationId:(NSManagedObjectID *)organizationId
                    context:(NSManagedObjectContext *)context;
- (id)initWithLocalNewsHeadlines:(NSArray *)headlines newsCityId:(NSManagedObjectID *)cityId
                         context:(NSManagedObjectContext *)context;

@end
