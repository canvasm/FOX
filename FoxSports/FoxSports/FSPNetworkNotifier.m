//
//  FSPNetworkNotifier.m
//  FoxSports
//
//  Created by Chase Latta on 5/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNetworkNotifier.h"
#import <netinet/in.h>

NSString * const FSPNetworkDidChangeStatusNotification = @"FSPNetworkDidChangeStatusNotification";
NSString * const FSPNetworkToConnectionTypeKey = @"FSPNetworkToConnectionTypeKey";
NSString * const FSPNetworkFromConnectionTypeKey = @"FSPNetworkFromConnectionTypeKey";

@interface _FSPNetworkNotifierBlockWrapper : NSObject
@property (nonatomic, copy) FSPNetworkDidChangeBlock block;
@property (nonatomic) dispatch_queue_t queue;

+ (id)blockWrapperWithBlock:(FSPNetworkDidChangeBlock)aBlock queue:(dispatch_queue_t)targetQueue;
- (id)initWithBlock:(FSPNetworkDidChangeBlock)aBlock queue:(dispatch_queue_t)targetQueue;

- (void)executeBlockWithFromType:(FSPNetworkType)from toType:(FSPNetworkType)to;
@end

@implementation _FSPNetworkNotifierBlockWrapper
@synthesize block = _block;
@synthesize queue = _queue;

+ (id)blockWrapperWithBlock:(FSPNetworkDidChangeBlock)aBlock queue:(dispatch_queue_t)targetQueue;
{
    return [[self alloc] initWithBlock:aBlock queue:targetQueue];
}

- (id)initWithBlock:(FSPNetworkDidChangeBlock)aBlock queue:(dispatch_queue_t)targetQueue;
{
    self = [super init];
    if (self) {
        self.block = aBlock;
        
        if (!targetQueue)
            targetQueue = dispatch_get_main_queue();
        dispatch_retain(targetQueue);
        self.queue = targetQueue;
    }
    return self;
}

- (void)dealloc;
{
    if (self.queue)
        dispatch_release(self.queue);
}

- (void)executeBlockWithFromType:(FSPNetworkType)from toType:(FSPNetworkType)to;
{
    dispatch_async(self.queue, ^{
        if (self.block)
            self.block(from , to);
    });
}

@end


@interface FSPNetworkNotifier ()  {
    dispatch_queue_t _syncQueue;
    NSUInteger _registerdListeners;
    dispatch_queue_t _callbackQueue;
}
@property (nonatomic, readonly) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic) FSPNetworkType currentType;
@property (nonatomic, strong) NSMutableSet *blocks;

- (BOOL)startNotifier;
- (BOOL)stopNotifier;

- (FSPNetworkType)networkTypeFromFlags:(SCNetworkReachabilityFlags)flags;
@end


// This method must be defined after the class extension because it technically is using private methods on the FSPNetworkNotifier.
static void
FSPNetworkNotifierCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    // We need to be careful here because we are altering our state in a method that potentially can be
    // called from multiple threads.  However, we are dispatching our notifications on our private queue
    // so we don't need to worry.
    
    FSPNetworkNotifier *notifier = (__bridge FSPNetworkNotifier *)info;
    
    // Figure out what we are moving to
    FSPNetworkType toType = [notifier networkTypeFromFlags:flags];
    FSPNetworkType fromType = notifier.currentType;
    
    NSDictionary *userInfo = @{FSPNetworkToConnectionTypeKey: @(toType),
                              FSPNetworkFromConnectionTypeKey: @(fromType)};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FSPNetworkDidChangeStatusNotification object:nil userInfo:userInfo];
    });
    
    // execute our blocks
    for (_FSPNetworkNotifierBlockWrapper *wrapper in notifier.blocks) {
        [wrapper executeBlockWithFromType:fromType toType:toType];
    }
    
    notifier.currentType = toType;
}

@implementation FSPNetworkNotifier
@synthesize reachabilityRef = _reachabilityRef;
@synthesize currentType = _currentType;
@synthesize blocks = _blocks;

+ (id)defaultNotifier;
{
    static FSPNetworkNotifier *master = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        master = [[self alloc] init];
    });
    return master;
}

- (id)init
{
    self = [super init];
    if (self) {
        _registerdListeners = 0;
        _syncQueue = dispatch_queue_create("com.foxsports.networkNotifier.syncQueue", 0);
        _callbackQueue = dispatch_queue_create("com.foxsports.networkNotifier.callbackQueue", 0);
        self.blocks = [NSMutableSet set];
        
        FSPLogFetching(@"Network Notifier initiated");
    }
    return self;
}

- (void)dealloc
{
    [self stopNotifier];
    
    if (_reachabilityRef)
        CFRelease(_reachabilityRef);
    if (_syncQueue)
        dispatch_release(_syncQueue);
    if (_callbackQueue)
        dispatch_release(_callbackQueue);
}

#pragma mark - :: Reachability Methods ::
- (SCNetworkReachabilityRef)reachabilityRef;
{
    if (!_reachabilityRef) {
        // We only support general reachability
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        _reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
        
        if (_reachabilityRef) {
            // Set our initial type
            SCNetworkReachabilityFlags flags;
            SCNetworkReachabilityGetFlags(_reachabilityRef, &flags);
            self.currentType = [self networkTypeFromFlags:flags];
        }
    }
    return _reachabilityRef;
}

- (BOOL)startNotifier;
{
    BOOL didStart = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    // Set our callback
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, FSPNetworkNotifierCallback, &context)) {
        // Schedule this on our dispatch queue
        if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, _callbackQueue)) {
            FSPLogFetching(@"FSPNetworkNotifier schedule on the main queue");
            didStart = YES;
        }
    }
    return didStart;
}

- (BOOL)stopNotifier;
{
    return SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
}

- (FSPNetworkType)networkTypeFromFlags:(SCNetworkReachabilityFlags)flags;
{
    if (!(flags & kSCNetworkReachabilityFlagsReachable))
        return FSPNetworkUnknownType;
    
    
    FSPNetworkType type = FSPNetworkUnknownType;
    
    if (!(flags & kSCNetworkReachabilityFlagsConnectionRequired))
        type = FSPNetworkWirelessType;

    if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)) {
        if (!(flags & kSCNetworkReachabilityFlagsInterventionRequired))
            type = FSPNetworkWirelessType;
    }
	
	
    
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
        type = FSPNetworkWWANType;

    return type;
}

#pragma mark - :: API Methods ::
- (void)beginPostingNotifications;
{
    dispatch_async(_syncQueue, ^{
        FSPLogFetching(@"FSPNetworkNotifier beginPostingNotifications");
        if (_registerdListeners == 0) {
            [self startNotifier];
        }
        _registerdListeners++;
    });
}

- (void)stopPostingNotifications;
{
    dispatch_async(_syncQueue, ^{
        FSPLogFetching(@"FSPNetworkNotifier stopPostingNotifications");
        _registerdListeners--;
        
        if (_registerdListeners <= 0) {
            //stop notifier
            [self stopNotifier];
            _registerdListeners = 0;
        }
    });
}

- (id)addNetworkDidChangeBlock:(FSPNetworkDidChangeBlock)block;
{
    return [self addNetworkDidChangeBlock:block queue:NULL];
}

- (id)addNetworkDidChangeBlock:(FSPNetworkDidChangeBlock)block queue:(dispatch_queue_t)queue;
{
    __block _FSPNetworkNotifierBlockWrapper *wrapper = nil;
    dispatch_sync(_syncQueue, ^{
        if ([self.blocks count] == 0) {
            [self beginPostingNotifications];
        }
        wrapper = [_FSPNetworkNotifierBlockWrapper blockWrapperWithBlock:block queue:queue];
        [self.blocks addObject:wrapper];
    });
    
    return wrapper;
}

- (void)removeNetworkDidChangeBlock:(id)identifier;
{
    dispatch_sync(_syncQueue, ^{
        if ([self.blocks containsObject:identifier]) {
            // This if statement is need to ensure that objects that 
            // are already removed don't decrement our _registeredListeners
            [self.blocks removeObject:identifier];
            if ([self.blocks count] == 0)
                [self stopPostingNotifications];
        }
    });
}
@end
