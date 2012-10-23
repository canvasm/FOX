//
//  FSPStandingsValidator.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsValidator.h"
#import "FSPTeam.h"

@interface FSPStandingsValidator ()
@property (nonatomic, strong, readonly) NSSet *requiredStringKeys;
@end

@implementation FSPStandingsValidator
@synthesize requiredStringKeys = _requiredStringKeys;

- (NSSet *)requiredStringKeys;
{
    if (_requiredStringKeys == nil) {
        _requiredStringKeys = [NSSet setWithObjects:FSPTeamOrganizationIdentifierKey, FSPTeamConferenceNameKey, nil];
    }
    return _requiredStringKeys;
}

- (NSSet *)requiredKeys;
{
    return [NSSet setWithObjects:FSPTeamOrganizationIdentifierKey, FSPTeamConferenceNameKey, nil];
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    id validatedObj = obj;
    if ([self.requiredStringKeys containsObject:key]) {
        if (![obj isKindOfClass:[NSString class]]) {
            validatedObj = nil;
        }
    } else {
        validatedObj = [super validateObject:obj forKey:key];
    }
    return validatedObj;
}

@end
