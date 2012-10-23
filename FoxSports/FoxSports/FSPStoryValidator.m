//
//  FSPStoryValidator.m
//  FoxSports
//
//  Created by Laura Savino on 3/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStoryValidator.h"

@implementation FSPStoryValidator

- (NSSet *)requiredKeys
{
    return [NSSet setWithObjects:@"fullText", @"title", nil];
}

@end
