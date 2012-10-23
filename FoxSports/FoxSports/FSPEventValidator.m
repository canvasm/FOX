//
//  FSPEventValidator.m
//  FoxSports
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventValidator.h"
#import "FSPEvent.h"
#import "NSDate+FSPExtensions.h"

@interface FSPEventValidator ()
@property (nonatomic, strong, readonly) NSSet *keysThatAreStringsSet;

@end

@implementation FSPEventValidator {
    NSSet *requiredKeysSet;
}
@synthesize keysThatAreStringsSet = _keysThatAreStringsSet;

- (NSSet *)requiredKeys;
{
    if (requiredKeysSet == nil) {
        requiredKeysSet = [NSSet setWithObjects:FSPEventUniqueIdKey, FSPEventBranchKey, FSPEventItemTypeKey, FSPEventStartDateKey, FSPEventEventStateKey, nil];
    }
    return requiredKeysSet;
}

- (NSSet *)keysThatAreStringsSet;
{
    if (_keysThatAreStringsSet == nil) {
        _keysThatAreStringsSet = [NSSet setWithObjects:FSPEventUniqueIdKey, FSPEventBranchKey, FSPEventItemTypeKey, FSPEventEventStateKey, nil];
    }
    return _keysThatAreStringsSet;
}

- (id)validateObject:(id)obj forKey:(id)key;
{
    id validatedObj = obj;
    if ([self.keysThatAreStringsSet containsObject:key]) {
        if (![obj isKindOfClass:[NSString class]])
            validatedObj = nil;
    } else if ([key isEqualToString:FSPEventStartDateKey]) {
        // Convert the string to a date.
		// TODO: handle dates that are sent as date strings
        if ([obj isKindOfClass:[NSString class]]) {
			NSDate *convertedDate = nil;
			if (!(convertedDate = [NSDate fsp_dateFromISO8601String:obj])) {
				NSTimeInterval doubleDate = ((NSString *)obj).doubleValue;
				convertedDate = [NSDate dateWithTimeIntervalSince1970:doubleDate];
			}
            validatedObj = convertedDate;
        }
    } else {
        validatedObj = [super validateObject:obj forKey:key];
    }
    return validatedObj;
}

@end
