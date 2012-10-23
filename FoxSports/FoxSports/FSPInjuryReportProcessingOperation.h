//
//  FSPInjuryReportProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 4/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@class FSPEvent;

@interface FSPInjuryReportProcessingOperation : FSPProcessingOperation

- (id)initWithEventId:(NSManagedObjectID *)eventId injuries:(NSArray *)injuryArray
        context:(NSManagedObjectContext *)context;

@end
