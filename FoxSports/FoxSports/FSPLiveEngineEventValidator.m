//
//  FSPLiveEngineEventValidator.m
//  FoxSports
//
//  Created by Matthew Fay on 5/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLiveEngineEventValidator.h"

@implementation FSPLiveEngineEventValidator

- (NSSet *)requiredKeys
{
    return [NSSet setWithObjects:@"GID", @"H", @"A", nil];
}

@end
