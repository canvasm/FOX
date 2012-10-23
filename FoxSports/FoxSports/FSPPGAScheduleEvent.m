//
//  FSPPGAScheduleEvent.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAScheduleEvent.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPPGAScheduleEvent

@synthesize winnerStrokesRelativeToPar = _winnerStrokesRelativeToPar;
@synthesize winnerEarnings = _winnerEarnings;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
    
    // There should be only one entry in the PGA schedule stats array.
    NSArray *stats = [dictionary objectForKey:@"stats"];
    for (NSDictionary *stat in stats) {
        self.winnerStrokesRelativeToPar = [stat fsp_objectForKey:@"value" defaultValue:@"--"];
        NSString *earnings = [self formattedCurrency:[stat fsp_objectForKey:@"value2" defaultValue:@""]];
        self.winnerEarnings = earnings ?: @"--";
    }
}

@end
