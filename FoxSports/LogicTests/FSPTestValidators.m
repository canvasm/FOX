//
//  FSPTestValidators.m
//  FoxSports
//
//  Created by Chase Latta on 2/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTestValidators.h"

NSString * const RequiredNameKey = @"name";
NSString * const RequiredAgeKey = @"age";

NSString * const ValidName = @"NAME";
const NSInteger ValidAge = 10;

#pragma mark - NoRequiredValidator
@implementation NoRequiredValidator

- (NSSet *)requiredKeys;
{
    return nil;
}

- (NSSet *)keysRequiringValidation;
{
    return nil;
}

@end


#pragma mark - RequiredKeysValidator
@implementation RequiredKeysValidator

- (NSSet *)requiredKeys;
{
    return [NSSet setWithObjects:RequiredNameKey, RequiredAgeKey, nil];
}
@end

#pragma mark - NoRequiredKeysKeyValidationValidator
@implementation NoRequiredKeysKeyValidationValidator

- (NSSet *)keysRequiringValidation;
{
    return [NSSet setWithObjects:RequiredNameKey, RequiredAgeKey, nil];
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    if ([key isEqual:RequiredNameKey]) {
        if ([obj isEqual:ValidName]) {
            return obj;
        } else {
            return nil;
        }
    } else if ([key isEqual:RequiredAgeKey]) {
        if ([obj isEqual:[NSNumber numberWithInteger:ValidAge]]) {
            return obj;
        } else {
            return nil;
        }
    } else {
        return [super validateObject:obj forKey:key];
    }
}
@end

#pragma mark - ValidationAccessorsImplementedValidator
@implementation ValidationAccessorsImplementedValidator

- (NSSet *)keysRequiringValidation;
{
    return [NSSet setWithObjects:RequiredNameKey, RequiredAgeKey, nil];
}

- (BOOL)shouldValidateKeys;
{
    return YES;
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    if ([key isEqual:RequiredNameKey]) {
        return obj;
    } else {
        return [super validateObject:obj forKey:key];
    }
}

- (id)validateAgeObject:(id)obj;
{
    return obj;
}
@end
