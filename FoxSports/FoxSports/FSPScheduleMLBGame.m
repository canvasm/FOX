//
//  FSPScheduleMLBGame.m
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleMLBGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleMLBGame
@synthesize winningPlayer;
@synthesize losingPlayer;
@synthesize savingPlayer;

- (NSString *)lastNameFromFullName:(NSString *)fullName {
	NSRange r = [fullName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
	if (r.location != NSNotFound) {
		return [fullName substringFromIndex:r.location + 1];
	} else {
		return fullName;
	}
}

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
    
    NSArray * stats = [dictionary objectForKey:@"stats"];
    for (NSDictionary * d in stats) {
        NSString *stat = [d objectForKey:@"stat"];
        if ([stat isEqualToString:@"WP"]) {
            self.winningPlayer = [self lastNameFromFullName:[d fsp_objectForKey:@"name" defaultValue:@""]];
        } else if ([stat isEqualToString:@"LP"]) {
            self.losingPlayer = [self lastNameFromFullName:[d fsp_objectForKey:@"name" defaultValue:@""]];
        } else if ([stat isEqualToString:@"SVP"]) {
            self.savingPlayer = [self lastNameFromFullName:[d fsp_objectForKey:@"name" defaultValue:@""]];
        }
    }
}
@end
