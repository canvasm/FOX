#import "Kiwi.h"
#import "FSPObjectValidator.h"
#import "FSPTestValidators.h"
#import "FSPOrganizationValidator.h"
#import "FSPOrganization.h"


SPEC_BEGIN(FSPValidatorSpec)

describe(@"FSPValidator", ^{
    FSPObjectValidator *baseValidator = [[FSPObjectValidator alloc] init];
    
    it(@"should return nil for required keys", ^{
        [[baseValidator requiredKeys] shouldBeNil];
    });
});

describe(@"FSPValidator with test validators", ^{
    
    context(@"testing validator with no requirements", ^{
        
        __block FSPObjectValidator *validator;
        
        beforeEach(^{
            validator = [[FSPObjectValidator alloc] init];
        });
        
        afterEach(^{
            validator = nil;
        });
        
        it(@"should validate when there are no required keys", ^{
            id result = [validator validateDictionary:[NSDictionary dictionary] error:nil];
            [result shouldNotBeNil];
        });
    });
    
    context(@"testing with required keys", ^{
        __block RequiredKeysValidator *validator;
        
        beforeEach(^{
            validator = [[RequiredKeysValidator alloc] init];
        });
        
        afterEach(^{
            validator = nil;
        });
        
        it(@"should return nil when required keys are not present", ^{
            id result = [validator validateDictionary:[NSDictionary dictionary] error:nil];
            [result shouldBeNil];
        });
        
        it(@"should contain all the keys that are required and not present in the error", ^{
            NSError *error;
            [validator validateDictionary:[NSDictionary dictionary] error:&error];
            NSDictionary *userInfo = [error userInfo];
            NSSet *missingKeys = [userInfo objectForKey:FSPMissingRequiredKeysKey];
            [[theValue([missingKeys isEqualToSet:[validator requiredKeys]]) should] beYes];
        });
        
        it(@"should return a valid dictionary when all required keys are present", ^{
            id result = [validator validateDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"blah", RequiredNameKey, [NSNumber numberWithInt:10], RequiredAgeKey, nil] error:nil];
            [result shouldNotBeNil];
        });
        
        it(@"should return the correct error code when validation fails", ^{
            NSError *error;
            [validator validateDictionary:[NSDictionary dictionary] error:&error];
            
            [[theValue([error code]) should] equal:theValue(FSPRequiredKeysNotPresentErrorCode)];
            [[[error domain] should] equal:FSPObjectValidatorErrorDomain];
        });
        
        it(@"should return nil when required keys are present but do not pass validation", ^{
            [validator stub:@selector(validateObject:forKey:) andReturn:nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ValidName, RequiredNameKey, [NSNumber numberWithInteger:ValidAge], RequiredAgeKey, nil];
            id result = [validator validateDictionary:dictionary error:nil];
            [result shouldBeNil];
        });
    });
    
    context(@"testing with no required keys but validating", ^{
        __block NoRequiredKeysKeyValidationValidator *validator;
        
        beforeEach(^{
            validator = [[NoRequiredKeysKeyValidationValidator alloc] init];
        });
        
        afterEach(^{
            validator = nil;
        });
        
        it(@"should check if the user wants to validate before validation", ^{
            [[[validator should] receive] shouldValidateKeys];
            [validator validateDictionary:[NSDictionary dictionary] error:nil];
        });
        
        it(@"should remove objects that return nil from validateObject:forKey:", ^{
            [validator stub:@selector(validateObject:forKey:) andReturn:nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ValidName, RequiredNameKey, [NSNumber numberWithInteger:ValidAge], RequiredAgeKey, nil];
            NSDictionary *result = [validator validateDictionary:dictionary error:nil];
            NSInteger resultCount = [[result allKeys] count];
            [[theValue(resultCount) should] beZero];
        });
        
        it(@"should remove both age and name when they are not valid", ^{
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"", RequiredNameKey, [NSNumber numberWithInteger:ValidAge + 1], RequiredAgeKey, nil];
            NSDictionary *result = [validator validateDictionary:dictionary error:nil];
            [[result objectForKey:RequiredNameKey] shouldBeNil];
            [[result objectForKey:RequiredAgeKey] shouldBeNil];
        });
        
        it(@"should not remove any keys when both age and name are valid", ^{
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ValidName, RequiredNameKey, [NSNumber numberWithInteger:ValidAge], RequiredAgeKey, nil];
            NSDictionary *result = [validator validateDictionary:dictionary error:nil];
            [[theValue([[result allKeys] count]) should] equal:theValue([[dictionary allKeys] count])];
        });
        
        it(@"should not call validateObject:forKey: if the user does not want to", ^{
            [validator stub:@selector(shouldValidateKeys) andReturn:theValue(NO)];
            [[validator should] receive:@selector(validateObject:forKey:) withCount:0];
            [validator validateDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"", RequiredNameKey, [NSNumber numberWithInteger:ValidAge + 1], RequiredAgeKey, nil] error:nil];
        });
    });

    /*
     This feature has been temporarily removed because of propblems with ARC.  Leave the tests because they will be valid when this is returned.
    context(@"testing the validate<Key>Object: methods", ^{
        __block NSDictionary *dictionary;
        __block ValidationAccessorsImplementedValidator *validator;
        
        beforeEach(^{
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:ValidName, RequiredNameKey, [NSNumber numberWithInteger:ValidAge], RequiredAgeKey, nil];
            validator = [[ValidationAccessorsImplementedValidator alloc] init];
        });
        
        afterEach(^{
            validator = nil;
        });
        
        it(@"should call validateObject:forKey: once", ^{
            [[validator should] receive:@selector(validateObject:forKey:) withCount:1 arguments:ValidName, RequiredNameKey];
            [[validator should] receive:@selector(validateObject:forKey:) withCount:0 arguments:[NSNumber numberWithInteger:ValidAge], RequiredAgeKey];
            [validator validateDictionary:dictionary error:nil];
        });
        
        it(@"should call validateAgeObject:", ^{
            [[validator should] receive:@selector(validateAgeObject:)];
            [validator validateDictionary:dictionary error:nil];
        });

        it(@"should respect the result returned from validateAgeObject: when it returns nil", ^{
            [validator stub:@selector(validateAgeObject:) andReturn:nil];
            NSDictionary *result = [validator validateDictionary:dictionary error:nil];
            [[result objectForKey:RequiredAgeKey] shouldBeNil];
        });
        
    });
    */
    
    context(@"handling NSNull", ^{
        __block FSPObjectValidator *validator;
        __block NSDictionary *nullDict;
        __block NSString *nullKey;
        
        beforeEach(^{
            nullKey = @"NULL_KEY";
            validator = [[FSPObjectValidator alloc] init];
            nullDict = [NSDictionary dictionaryWithObject:[NSNull null] forKey:nullKey];
        });
        
        it(@"should ask the user if they want to treat Null objects as nil before calling validating objects", ^{
            [validator stub:@selector(shouldValidateKeys) andReturn:theValue(YES)];
            [[validator should] receive:@selector(shouldTreatNSNullAsNil)];
            [validator validateDictionary:nullDict error:nil];
        });
        
        it(@"should not ask the user how they want to treat Null objects if no validation is occurring", ^{
            [validator stub:@selector(shouldValidateKeys) andReturn:theValue(NO)];
            [[validator should] receive:@selector(shouldTreatNSNullAsNil) withCount:0];
        });
        
        it(@"should convert Null to nil before validateObject:forKey: if the user wants to", ^{
            [validator stub:@selector(shouldValidateKeys) andReturn:theValue(YES)];
            [[nullDict objectForKey:nullKey] shouldNotBeNil];
            NSDictionary *result = [validator validateDictionary:nullDict error:nil];
            [[result objectForKey:nullKey] shouldBeNil];
        });
        
        it(@"should convert not Null to nil before validateObject:forKey: if the user does not wants to", ^{
            [validator stub:@selector(shouldValidateKeys) andReturn:theValue(NO)];
            [[nullDict objectForKey:nullKey] shouldNotBeNil];
            NSDictionary *result = [validator validateDictionary:nullDict error:nil];
            [[result objectForKey:nullKey] shouldNotBeNil];
        });
    });
});

describe(@"Validating Organization Responses", ^{
    __block FSPOrganizationValidator *validator;
    
    beforeEach(^{
        validator = [[FSPOrganizationValidator alloc] init];
    });
    
    afterEach(^{
        validator = nil;
    });
    
    it(@"should fail if organizationId is missing", ^{
        NSDictionary *dictionary = [NSDictionary dictionary];
        id result = [validator validateDictionary:dictionary error:nil];
        [result shouldBeNil];
    });
    
    it(@"should fail if name is missing", ^{
        NSDictionary *dictionary = [NSDictionary dictionary];
        id result = [validator validateDictionary:dictionary error:nil];
        [result shouldBeNil];
    });
    
    it(@"should succeed if organizationId and name are present and valid", ^{
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], FSPOrganizationIdKey, @"some name", FSPOrganizationNameKey, nil];
        id result = [validator validateDictionary:dictionary error:nil];
        [result shouldNotBeNil];
    });
    
    it(@"should fail if organization id is not a number", ^{
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"1", FSPOrganizationIdKey, @"some name", FSPOrganizationNameKey, nil];
        id result = [validator validateDictionary:dictionary error:nil];
        [result shouldBeNil];
    });
    
    it(@"should fail if name is not a string", ^{
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], FSPOrganizationIdKey, [NSNumber numberWithInt:0], FSPOrganizationNameKey, nil];
        id result = [validator validateDictionary:dictionary error:nil];
        [result shouldBeNil];
    });
});

SPEC_END