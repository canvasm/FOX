#import "Kiwi.h"
#import "NSDictionary+FSPExtensions.h"


SPEC_BEGIN(NSDictionaryExtensions)


describe(@"FSPExtesions", ^{
   
    context(@"when getting defaultObject", ^{
        
        __block NSDictionary *theDict;
        NSString *theObject = @"the object";
        NSString *theKey = @"THE_KEY";
        NSString *nullKey = @"NULL_KEY";
        
        beforeEach(^{
            theDict = [NSDictionary dictionaryWithObjectsAndKeys:theObject, theKey, [NSNull null], nullKey, nil];
        });
        
        it(@"should return the object if it exists", ^{
            id returnedObject = [theDict objectForKey:theKey defaultValue:@"some default"];
            [[returnedObject should] equal:theObject];
        });
        
        it(@"should return the default object if key does not exist.", ^{
            NSString *defaultString = @"default";
            id returnedObject = [theDict objectForKey:@"does not exist" defaultValue:defaultString];
            [[returnedObject should] equal:defaultString];
        });
        
        it(@"should return the default value if objectForKey is NSNull", ^{
            NSString *defaultString = @"default";
            id returnedObject = [theDict objectForKey:nullKey defaultValue:defaultString];
            [[returnedObject should] equal:defaultString];
        });

    });
    
    context(@"when mapping values in dictionary", ^{
        
        __block NSDictionary *theDict;
        NSString *lowerCaseString = @"lower";
        NSString *upperCaseString = @"LOWER";
        NSString *stringKey = @"KEY";
        
        beforeEach(^{
            theDict = [NSDictionary dictionaryWithObject:lowerCaseString forKey:stringKey];
        });
       
        it(@"should return nil if the block returns nil", ^{
            id myNilObject = [theDict objectForKey:stringKey mappedByBlock:^id(id obj) {
                return nil;
            }];
            
            [myNilObject shouldBeNil];
        });
        
        it(@"should return the objectForKey value if block is nil", ^{
            id returnedObject = [theDict objectForKey:stringKey mappedByBlock:nil];
            [[returnedObject should] equal:lowerCaseString];
        });
        
        it(@"should return the mapped object", ^{
            NSString *returnedObject = [theDict objectForKey:stringKey mappedByBlock:^(id obj) {
                return [(NSString *)obj uppercaseString];
            }];
            
            [[returnedObject should] equal:upperCaseString];
        });
    });
});

SPEC_END