//
//  NSNumber+FSPExtensions.m
//  FoxSports
//
//  Created by greay on 7/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "NSNumber+FSPExtensions.h"

@implementation NSNumber (FSPExtensions)

- (NSString *)fsp_ordinalStringValue
{
	NSInteger n = [self integerValue];
	if (n < 0) return @"--";
	
    NSInteger onesValue = n % 10;
    NSString *suffix = @"th";
    
	if(n < 4 || n > 20) {
		switch (onesValue) {
			case 1:
				suffix = @"st";
				break;
			case 2:
				suffix = @"nd";
				break;
			case 3:
				suffix = @"rd";
				break;
        }
    }
	
    return [NSString stringWithFormat:@"%d%@", n, suffix];
}

- (NSString *)fsp_stringValue
{
	if ([self integerValue] < 0) return @"--";
	else return [self stringValue];
}

@end
