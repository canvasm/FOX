//
//  FSPLiveEngineChipProcessingOperation.h
//  FoxSports
//
//  Created by Matthew Fay on 5/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPLiveEngineChipProcessingOperation : FSPProcessingOperation
- (id)initWithEvents:(NSArray *)events context:(NSManagedObjectContext *)context;
@end
