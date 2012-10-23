//
//  FSPNewsCityProcessingOperation.h
//  FoxSports
//
//  Created by Stephen Spring on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPNewsCityProcessingOperation : FSPProcessingOperation

- (id)initWithNewsCities:(NSDictionary *)cities context:(NSManagedObjectContext *)context;

@end
