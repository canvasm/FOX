//
//  FSPPlayerInjuryValidator.m
//  FoxSports
//
//  Created by Matthew Fay on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayerInjuryValidator.h"
#import "FSPPlayerInjury.h"

@interface FSPPlayerInjuryValidator ()

- (id)validateStringObject:(id)obj;

@end

@implementation FSPPlayerInjuryValidator {
    NSSet *requiredKeysSet;
}

- (NSSet *)requiredKeys;
{
    if (requiredKeysSet == nil) {
        requiredKeysSet = [NSSet setWithObjects: FSPPlayerInjuryFirstNameKey, FSPPlayerInjuryLastNameKey, FSPPlayerInjuryPositionKey, FSPPlayerInjuryKey, FSPPlayerInjuryStatusKey, nil];
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
