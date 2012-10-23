//
//  FSPChannel.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPChannel.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPChannel

@synthesize callSign = _callSign;
@synthesize broadcastDate = _broadcastDate;
@synthesize isDelayed = _isDelayed;

- (void)populateWithDictionary:(NSDictionary *)channelData
{
    self.callSign = [channelData fsp_objectForKey:@"callSign" defaultValue:@""];
    self.isDelayed = [channelData fsp_objectForKey:@"isDelayed" defaultValue:@0];
    self.broadcastDate = [channelData fsp_objectForKey:@"broadcastDate" defaultValue:@""];
}

- (NSString *)formattedBroadcastDate
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.broadcastDate intValue]];
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return [dateFormatter stringFromDate:date];
}

@end
