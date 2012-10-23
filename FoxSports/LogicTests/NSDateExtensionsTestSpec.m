#import "Kiwi.h"
#import "NSDate+FSPExtensions.h"

#define ONE_DAY (24 * 60 * 60)

SPEC_BEGIN(NSDateExtensionTests)

describe(@"comparing dates", ^{
   
    context(@"to check if it is today", ^{

        it(@"should return false for days that are in the past", ^{
            NSDate *old = [NSDate dateWithTimeIntervalSinceNow:-2 * ONE_DAY];
            [[theValue([old isToday]) should] beNo];
        });
        
        it(@"should return false for days that are in the future", ^{
            NSDate *future = [NSDate distantFuture];
            [[theValue([future isToday]) should] beNo];
        });
        
        it(@"should return true for [NSDate date]", ^{
            NSDate *now = [NSDate date];
            [[theValue([now isToday]) should] beYes];
        });
        
        it(@"should be true for dates at the zero hour of the day", ^{
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:now];
            [components setHour:0];
            [components setMinute:0];
            [components setSecond:0];
            
            NSDate *zeroedDate = [calendar dateFromComponents:components];
            [[theValue([zeroedDate isToday]) should] beYes];
        });
    });
});

describe(@"creating dates", ^{
    
    context(@"when normalizing dates", ^{
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
       
        it(@"two dates with different timestamps should be equal when normalized", ^{
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = 2000;
            components.month = 1;
            components.day = 2;
            components.hour = 12;
            components.minute = 33;
            components.second = 1;
            
            NSDate *dateA = [calendar dateFromComponents:components];
            
            components.hour = 1;
            components.minute = 3;
            components.second = 33;
            
            NSDate *dateB = [calendar dateFromComponents:components];
            
            NSDate *normalizedA = [dateA normalizedDate];
            NSDate *normalizedB = [dateB normalizedDate];
            
            [[theValue([normalizedA isEqualToDate:normalizedB]) should] beYes];
        });
        
        it(@"it should have 0 for all of the time components", ^{
            NSDate *date = [NSDate date];
            NSDate *normalizedDate = [date normalizedDate];
            
            NSDateComponents *components = [calendar components:kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:normalizedDate];
            [[theValue(components.hour) should] beZero];
            [[theValue(components.minute) should] beZero];
            [[theValue(components.second) should] beZero];
        });
        
        it(@"should not equal another normalized date that does not have the same date", ^{
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = 2000;
            components.month = 1;
            components.day = 2;
            components.hour = 8;
            components.minute = 33;
            components.second = 1;
            
            NSDate *dateA = [calendar dateFromComponents:components];
            
            components.day = 5;
            components.hour = 1;
            components.minute = 3;
            components.second = 33;
            
            NSDate *dateB = [calendar dateFromComponents:components];
            
            NSDate *normalizedA = [dateA normalizedDate];
            NSDate *normalizedB = [dateB normalizedDate];
            
            [[theValue([normalizedA isEqualToDate:normalizedB]) should] beNo];
        });
        
        it(@"should normalize to the epoch for the middle of the epoch day", ^{
            NSDate *d = [NSDate dateWithTimeIntervalSince1970:100];
            NSDate *date = [[NSDate dateWithTimeIntervalSince1970:100] normalizedDate];
            BOOL equalDates = [date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]];
            [[theValue(equalDates) should] beYes];
        });
        
    });
    
});


SPEC_END