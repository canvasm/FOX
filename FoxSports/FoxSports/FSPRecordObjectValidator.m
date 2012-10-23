//
//  FSPRecordObjectValidator.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRecordObjectValidator.h"
#import "FSPTeamRecord.h"

@implementation FSPRecordObjectValidator

- (NSSet *)requiredKeys;
{
    return [NSSet setWithObjects:FSPTeamRecordTypeKey, FSPTeamRecordWinsKey, FSPTeamRecordLossesKey, nil];
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    id validatedObj = obj;
    if ([key isEqualToString:FSPTeamRecordTypeKey]) {
        if (![obj isKindOfClass:[NSString class]])
            validatedObj = nil;
    } else if (([key isEqualToString:FSPTeamRecordWinsKey]) || ([key isEqualToString:FSPTeamRecordLossesKey])) {
        // it needs to be a positive number or zero
        if (![obj isKindOfClass:[NSNumber class]] || ([(NSNumber *)obj compare:@-1] != NSOrderedDescending))
            validatedObj = nil;
    } else {
        validatedObj = [super validateObject:obj forKey:key];
    }
    return validatedObj;
}

@end
