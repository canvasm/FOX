//
//  FSPObjectValidator.h
//  FoxSports
//
//  Created by Chase Latta on 2/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

// Errors
extern NSString * const FSPObjectValidatorErrorDomain;
extern const NSInteger FSPRequiredKeysNotPresentErrorCode;
extern NSString * const FSPMissingRequiredKeysKey;

/**
 The object validator is a superclass that is meant to 
 provide a template for object validation. 
 
 The order in which the validator checks is as follows
    - Validate the objects in the dictionary (if shouldValidateKeys == YES)
    - Check required keys
 */
@interface FSPObjectValidator : NSObject

/**
 Return the keys that are required for this object to be valid.
 If no keys are required return nil.
 
 The default implementation of this method returns nil
 */
- (NSSet *)requiredKeys;

/**
 Tells if the validator should validate each key.
 Defaults to YES.
 */
- (BOOL)shouldValidateKeys;

/**
 If YES, all objects that equal [NSNull null] are passed as nil to 
 validateObject:forKey:
 otherwise, [NSNull null] is passed.
 
 Defaults to YES;
 */
- (BOOL)shouldTreatNSNullAsNil;

/**
 Validate the given object for the given key.  If nil is returned the object
 is removed from the dictionary otherwise the returned object is placed
 into the dictionary for the given key.
 */
- (id)validateObject:(id)obj forKey:(id)key;

/**
 Validate the current dictionary and return a new updated dictionary.
 If the dictionary is missing required keys nil is returned and the reason
 is given in error.
 */
- (NSDictionary *)validateDictionary:(NSDictionary *)dictionary error:(NSError **)outError;
@end
