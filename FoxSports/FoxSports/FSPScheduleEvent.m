//
//  FSPScheduleEvent.m
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleEvent.h"
#import "NSDate+FSPExtensions.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPChannel.h"
#import "FSPCoreDataManager.h"

@interface FSPScheduleEvent ()
@property (nonatomic, strong) NSDictionary *dictionary;
@end

@implementation FSPScheduleEvent

@synthesize uniqueIdentifier;
@synthesize startDate = _startDate;
@synthesize channelDisplayName = _channelDisplayName;
@synthesize normalizedStartDate;
@synthesize branch;
@synthesize seasonType;
@synthesize dictionary = _dictionary;
@synthesize endDate = _endDate;
@synthesize name = _name;
@synthesize stat = _stat;
@synthesize channels = _channels;

- (void)setStartDate:(NSDate *)newStartDate;
{
    _startDate = newStartDate;
    self.normalizedStartDate = [newStartDate fsp_normalizedDate];
}

- (id)valueForUndefinedKey:(NSString *)key;
{
    return [self.dictionary objectForKey:key];
}

- (void)populateWithDictionary:(NSDictionary *)dictionary;
{
    _dictionary = nil;
    _dictionary = dictionary;
    
    self.uniqueIdentifier = [dictionary objectForKey:@"fsId"];
    self.startDate = [dictionary objectForKey:@"startDate"];
    self.endDate = [self dateFromTimeInterval:[dictionary objectForKey:@"endDate"]];
    self.branch = [dictionary objectForKey:@"branch"];
    self.seasonType = [dictionary objectForKey:@"seasonType"];
    
    NSMutableArray *mutableChannels = [NSMutableArray array];
    NSArray * channels = [dictionary objectForKey:@"channel"];
    for (NSDictionary *channelData in channels) {
        FSPChannel *channel = [[FSPChannel alloc] init];
        [channel populateWithDictionary:channelData];
        [mutableChannels addObject:channel];
    }
    self.channels = [NSArray arrayWithArray:mutableChannels];
    self.channelDisplayName = @"";
    if (channels) {
        for (NSUInteger i = 0; i < [channels count]; ++i) {
            self.channelDisplayName = [NSString stringWithFormat:@"%@%@%@", self.channelDisplayName, i == 0 ? @"" : @", ", [[channels objectAtIndex:i] fsp_objectForKey:@"callSign" defaultValue:@""]];
        }
    }
    
    NSArray *stats = [dictionary objectForKey:@"stats"];
    for (NSDictionary *stat in stats) {
        self.stat = [stat objectForKey:@"stat"];
        if ([stat objectForKey:@"name"]) {
            self.name = [stat fsp_objectForKey:@"name" defaultValue:@"--"];
        }
    }
}

- (NSDate *)dateFromTimeInterval:(NSString *)timeInterval
{
    static NSNumberFormatter *numberFormatter   = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * dateNumber = [numberFormatter numberFromString:timeInterval];
    return [NSDate dateWithTimeIntervalSince1970:[dateNumber doubleValue]];
}

- (NSString *)displayStartTime
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:kCFDateFormatterShortStyle];
    });
    return [dateFormatter stringFromDate:self.startDate];
}

+ (NSString *)dateFormattedForDisplayInSectionHeader:(NSDate *)date
{
    static NSDateFormatter *displayDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayDateFormatter = [[NSDateFormatter alloc] init];
        [displayDateFormatter setDateFormat:@"E M/d"];
    });
    return [displayDateFormatter stringFromDate:date];
}

- (NSString *)formattedCurrency:(NSString *)prize;
{
    if ([prize length] < 2) {
        return prize;
    }
    
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSRange range = [prize rangeOfCharacterFromSet:numberSet];
    NSString *currency = nil;
    if (range.location != NSNotFound) {
        currency = [prize substringWithRange:NSMakeRange(0, 1)];
        prize = [prize substringFromIndex:range.location];
    }
    
    static NSNumberFormatter *currencyFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [currencyFormatter setGeneratesDecimalNumbers:NO];
    });
    return [NSString stringWithFormat:@"%@%@",currency, [currencyFormatter stringFromNumber:[NSNumber numberWithInt:[prize intValue]]]];
}

@end
