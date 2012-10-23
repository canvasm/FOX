//
//  FSPPollingCenter.m
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPollingCenter.h"

@interface FSPPollingCenter ()
@property (atomic, strong) NSMutableDictionary *pollingActions;
@end

@implementation FSPPollingCenter
@synthesize pollingActions = _pollingActions;

- (NSUInteger)numberOfActions;
{
    return [self.pollingActions count];
}

+ (id)defaultCenter;
{
    static dispatch_once_t onceToken;
    static FSPPollingCenter *defaultCenter = nil;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[FSPPollingCenter alloc] init];
    });
    return defaultCenter;
}

- (id)init;
{
    self = [super init];
    if (self) {
        self.pollingActions = [NSMutableDictionary dictionary];
    }
    return self;
}


- (NSTimer *)addPollingActionForKey:(NSString *)key timeInterval:(NSTimeInterval)interval usingBlock:(void (^)(void))block
{
	[self stopPollingActionForKey:key];
	
	NSTimer *action = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(poll:) userInfo:[block copy] repeats:YES];
    [action fire];
    [self.pollingActions setObject:action forKey:key];
	[[NSRunLoop mainRunLoop] addTimer:action forMode:NSRunLoopCommonModes];
	
    return action;
}

- (void)stopPollingActionForKey:(NSString *)key
{
	if ([self.pollingActions valueForKey:key]) {
		NSTimer *oldAction = [self.pollingActions objectForKey:key];
		[oldAction invalidate];
	}
}


- (void)poll:(NSTimer *)timer
{
	void (^block)() = (void (^)())[timer userInfo];
	block();
}

@end
