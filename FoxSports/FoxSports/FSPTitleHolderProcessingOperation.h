//
//  FSPTitleHolderProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPTitleHolderProcessingOperation : FSPProcessingOperation

- (id)initWithOrgId:(NSManagedObjectID *)orgId titleHoldersData:(NSArray *)titleholdersData
      context:(NSManagedObjectContext *)context;

@end
