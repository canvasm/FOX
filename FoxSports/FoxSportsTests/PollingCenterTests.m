#import "Kiwi.h"
#import "FSPPollingCenter.h"
#import "FSPPollingAction.h"

@interface FakeObject : NSObject 
-(void)someMethod;
@end

@implementation FakeObject
- (void)someMethod; {}
@end


SPEC_BEGIN(PollingCenter)

describe(@"FSPPollingCenter", ^{
    
    context(@"singleton", ^{
        
        it(@"should return the same default manager", ^{
            FSPPollingCenter *center = [FSPPollingCenter defaultCenter];
            [center shouldNotBeNil];
            
            [[center should] beIdenticalTo:[FSPPollingCenter defaultCenter]];
        });
    });
    
    context(@"adding and removing actions", ^{
        
        __block id action = nil;
        __block NSString *toUpdate = nil;
        __block FakeObject *fake;
        
        double divisor = 10.0;
        NSInteger maxExecutions = 5;
        
        NSTimeInterval interval = (double)1/divisor;
        
        beforeEach(^{
            toUpdate = nil;
            fake = [[FakeObject alloc] init];
            action = [[FSPPollingCenter defaultCenter] insertPollingActionWithInterval:interval usingBlock:^{
                toUpdate = @"updated";
                [fake someMethod];
            }];
        });
        
        afterEach(^{
            [[FSPPollingCenter defaultCenter] removePollingAction:action];
            action = nil;
        });
        
        it(@"should return an action on insert", ^{
            [action shouldNotBeNil];
        });
        
        it(@"should return a polling action", ^{
            [[action should] beKindOfClass:[FSPPollingAction class]];
        });
        
        it(@"should eventually execute its action", ^{
            [[toUpdate shouldEventually] beNonNil];
        });
        
        it(@"should start with 0 actions", ^{
            FSPPollingCenter *center = [[FSPPollingCenter alloc] init];
            [[theValue(center.numberOfActions) should] equal:theValue(0)];
        });
        
        it(@"should increment actions when adding", ^{
            FSPPollingCenter *center = [[FSPPollingCenter alloc] init];
            [center insertPollingActionWithInterval:1 usingBlock:nil];
            [[theValue(center.numberOfActions) should] equal:theValue(1)];
        });
        
        it(@"should decrement actions when removing", ^{
            FSPPollingCenter *center = [[FSPPollingCenter alloc] init];
            id action = [center insertPollingActionWithInterval:1 usingBlock:nil];
            [center insertPollingActionWithInterval:1 usingBlock:nil];
            NSUInteger count = center.numberOfActions;
            [center removePollingAction:action];
            
            [[theValue(center.numberOfActions) should] equal:theValue(count - 1)];
        });
        
        it(@"should stop executing when removed", ^{
            
            
            double delayInSeconds = maxExecutions / divisor;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[FSPPollingCenter defaultCenter] removePollingAction:action];
            });
            
            [[[fake shouldEventually] receiveWithCountAtLeast:1] someMethod];
            [[[fake shouldEventuallyBeforeTimingOutAfter(2)] receiveWithCountAtMost:maxExecutions] someMethod];
        });

// TODO: these are never actually used anywhere in the app; are they necessary?
		
//        it(@"should stop executing when paused", ^{
//            
//            double delayInSeconds = (maxExecutions / divisor);
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [[FSPPollingCenter defaultCenter] pausePollingAction:action];
//            });
//            
//            [[[fake shouldEventually] receiveWithCountAtLeast:1] someMethod];
//            [[[fake shouldEventuallyBeforeTimingOutAfter(2)] receiveWithCountAtMost:maxExecutions] someMethod];
//        });
//        
//        
//        it(@"should be pausable and resumable", ^{
//            NSLog(@"actions = %@", [[FSPPollingCenter defaultCenter] performSelector:@selector(pollingActions)]);
//            double delayInSeconds = 0.3;
//            dispatch_time_t pauseTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(pauseTime, dispatch_get_main_queue(), ^(void){
//                [[FSPPollingCenter defaultCenter] pausePollingAction:action];
//            });
//
//            
//            delayInSeconds = 0.5;
//            dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
//                [[FSPPollingCenter defaultCenter] resumePollingAction:action];
//            });
//            
//            [[[fake shouldEventually] receiveWithCountAtLeast:6] someMethod];
//        });

    });
});

SPEC_END
