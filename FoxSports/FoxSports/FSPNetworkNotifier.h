//
//  FSPNetworkNotifier.h
//  FoxSports
//
//  Created by Chase Latta on 5/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/**
 The FSPNetworkDidChangeStatusNotification is posted when the network state changes
 to one of the FSPNetworkType values.  Each notification will contain
 the FSPNetworkFromConnectionTypeKey and FSPNetworkToConnectionTypeKey in the userInfo 
 dictionary with the value that the network is transitioning from and to.
 */
extern NSString * const FSPNetworkDidChangeStatusNotification;

extern NSString * const FSPNetworkToConnectionTypeKey;
extern NSString * const FSPNetworkFromConnectionTypeKey;

enum {
    // Indicates a wireless network
    FSPNetworkWirelessType,
    
    // Indicates a cell network
    FSPNetworkWWANType,
    
    // Indicates that the network type is unknown
    FSPNetworkUnknownType
};
typedef NSUInteger FSPNetworkType;

typedef void(^FSPNetworkDidChangeBlock)(FSPNetworkType fromType, FSPNetworkType toType);

/**
 The FSPNetworkNotifier is a system that allows users
 to register for network change notifications.  This system
 should not be used to test whether an endpoint is reachable; if
 users need to see if they can reach an endpoint they should just
 try to connect and respond to errors accordingly.
 */
@interface FSPNetworkNotifier : NSObject

+ (id)defaultNotifier;

/**
 Called when the user is interested in the system posting notifications
 of the specified type.  The caller is still responsible for registering
 with the default notificaiton center to actually receive the notifications.
 */
- (void)beginPostingNotifications;

/**
 Called when the user does not care about receiving notifications of the 
 given type anymore.  Note that this does not mean that the system will
 stop posting these notifications if there are others interested.
 */
- (void)stopPostingNotifications;

/**
 Adds a block to be executed when the network changes.  If no queue is specified blocks
 will be dispatched to the main queue.  You do not need to call beginPostingNotifications
 if you use this method.  The return type is an opaque object that can be used with
 removeNetworkDidChangeBlock.
 */
- (id)addNetworkDidChangeBlock:(FSPNetworkDidChangeBlock)block;
- (id)addNetworkDidChangeBlock:(FSPNetworkDidChangeBlock)block queue:(dispatch_queue_t)queue;

/**
 Removes a given block from the dispatch table.  The identifier is the identifier that is 
 returned from the addNetworkDidChangeBlock: methods.
 */
- (void)removeNetworkDidChangeBlock:(id)identifier;
@end
