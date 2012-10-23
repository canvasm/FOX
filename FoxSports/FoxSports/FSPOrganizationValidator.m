//
//  FSPOrganizationValidator.m
//  FoxSports
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationValidator.h"
#import "FSPOrganization.h"

@interface FSPOrganizationValidator ()

- (id)validateStringObject:(id)obj;

@end

@implementation FSPOrganizationValidator {
    NSSet *requiredKeysSet;
}

- (NSSet *)requiredKeys;
{
    if (requiredKeysSet == nil) {
        requiredKeysSet = [NSSet setWithObjects:FSPOrganizationIdKey, FSPOrganizationBranchKey, FSPOrganizationTypeKey, FSPOrganizationNameKey, nil];
    }
    return requiredKeysSet;
}

- (id)validateStringObject:(id)obj;
{
    if (![obj isKindOfClass:[NSString class]])
        return nil;
    return obj;
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    id validatedObject;
    // All of the required keys for this class are strings.
    if ([[self requiredKeys] containsObject:key]) {
        validatedObject = [self validateStringObject:obj];
    } else {
        validatedObject = [super validateObject:obj forKey:key];
    }
    return validatedObject;
}
@end
