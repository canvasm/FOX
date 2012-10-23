//
//  FSPTestValidators.h
//  FoxSports
//
//  Created by Chase Latta on 2/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPObjectValidator.h"

extern NSString * const RequiredNameKey;
extern NSString * const RequiredAgeKey;

extern NSString * const ValidName;
extern const NSInteger ValidAge;

@interface NoRequiredValidator : FSPObjectValidator
@end

@interface RequiredKeysValidator : FSPObjectValidator
@end


@interface NoRequiredKeysKeyValidationValidator : FSPObjectValidator
@end

@interface ValidationAccessorsImplementedValidator : FSPObjectValidator
@end