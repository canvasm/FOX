

//
//  FSPObjectValidator.m
//  FoxSports
//
//  Created by Chase Latta on 2/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPObjectValidator.h"
#import <objc/message.h>

NSString * const FSPObjectValidatorErrorDomain = @"FSPObjectValidatorErrorDomain";
const NSInteger FSPRequiredKeysNotPresentErrorCode = 2001;

NSString * const FSPMissingRequiredKeysKey = @"FSPMissingRequiredKeysKey";

@interface FSPObjectValidator ()

- (NSSet *)missingRequiredKeysInDictionary:(NSDictionary *)dictionary;

- (id)usingAppropriateSelectorValidatedObject:(id)obj forKey:(id)key;

- (SEL)validationSelectorForKey:(id)key;

- (BOOL)objectIsNull:(id)obj;

@end

@implementation FSPObjectValidator

#pragma mark - Object Validation
- (NSDictionary *)validateDictionary:(NSDictionary *)dictionary error:(NSError **)outError;
{    
    if (![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSDictionary *newDictionary;
    if ([self shouldValidateKeys]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
        BOOL convertToNil = [self shouldTreatNSNullAsNil];
        
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (convertToNil && [self objectIsNull:obj])
                obj = nil;
            
            id newObj = [self usingAppropriateSelectorValidatedObject:obj forKey:key];
            if (newObj) {
                [mutableDictionary setObject:newObj forKey:key];
            }
        }];
        
        newDictionary = mutableDictionary;
    } else {
        newDictionary = dictionary;
    }
    
    NSSet *missingKeys = [self missingRequiredKeysInDictionary:newDictionary];
    if ([missingKeys count] > 0) {
        FSPLogValidation(@"Dictionary '%@' failed validation because it was missing the following keys '%@'", dictionary, missingKeys);
        if (outError != NULL) {
            *outError = [NSError errorWithDomain:FSPObjectValidatorErrorDomain code:FSPRequiredKeysNotPresentErrorCode userInfo:@{FSPMissingRequiredKeysKey: missingKeys}];
        }
        newDictionary = nil;
    }
    
    if (newDictionary)
        return [NSDictionary dictionaryWithDictionary:newDictionary];
    return nil;
}

#pragma mark - Required Keys
- (NSSet *)requiredKeys;
{
    return nil;
}

- (NSSet *)missingRequiredKeysInDictionary:(NSDictionary *)dictionary;
{
    NSMutableSet *missingKeys = [NSMutableSet set];
    for (id key in [self requiredKeys]) {
        id obj = [dictionary objectForKey:key];
        if (obj == nil) {
            [missingKeys addObject:key];
        }
    }
    return [missingKeys copy];
}

#pragma mark - Key validation
- (BOOL)shouldValidateKeys;
{
    return YES;
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    return obj;
}

- (id)usingAppropriateSelectorValidatedObject:(id)obj forKey:(id)key;
{
    id newObj = [self validateObject:obj forKey:key];
    /*  This is currently not working with ARC.  Need to explore it to see if it is possible
    // Validate our objects
    SEL validationSelector = [self validationSelectorForKey:key];
    if ([self respondsToSelector:validationSelector]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:validationSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self;
        invocation.selector = validationSelector;
        [invocation setArgument:&obj atIndex:2];
        [invocation invoke];
        
        [invocation getReturnValue:&newObj];

    } else {
        newObj = [self validateObject:obj forKey:key];
    }
    */
    return newObj;
}

- (SEL)validationSelectorForKey:(id)key;
{
    if (![key isKindOfClass:[NSString class]])
        return nil;
    
    NSString *upperCase = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
    NSString *selectorString = [NSString stringWithFormat:@"validate%@Object:", upperCase];
    return NSSelectorFromString(selectorString);
}

#pragma mark - NSNull handling
- (BOOL)shouldTreatNSNullAsNil;
{
    return YES;
}

- (BOOL)objectIsNull:(id)obj;
{
    return obj == [NSNull null];
}

@end
