//
//  FSPUFCMatchupProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPUFCMatchupProcessingOperation : FSPProcessingOperation

- (id)initWithUFCEventId:(NSManagedObjectID *)eventId matchupData:(NSDictionary *)UFCMatchupData
                 context:(NSManagedObjectContext *)context;

@end
