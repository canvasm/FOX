//
//  FSPEventStreamabilityProcessingOperation.h
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPEventStreamabilityProcessingOperation : FSPProcessingOperation

- (id)initWithStreamabilityInfo:(NSDictionary *)streamabilityInfo events:(NSArray *)events
                  context:(NSManagedObjectContext *)context;

@end
