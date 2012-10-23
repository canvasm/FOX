//
//  FSPGolfHole.m
//  FoxSports
//
//  Created by Matthew Fay on 9/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGolfHole.h"
#import "FSPGolfRound.h"


@implementation FSPGolfHole

@dynamic label;
@dynamic par;
@dynamic strokes;
@dynamic round;

- (BOOL)isHole
{
    if ([self.label isEqualToString:@"IN"] || [self.label isEqualToString:@"OUT"]) {
        return NO;
    }
    return YES;
}

@end
