/**
 * **********************************************************************
 * <p/>
 * ADOBE CONFIDENTIAL
 * ___________________
 * <p/>
 * Copyright 2011 Adobe Systems Incorporated
 * All Rights Reserved.
 * <p/>
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 * ************************************************************************
 */
#import <Foundation/Foundation.h>
#import "EntitlementDelegate.h"
#import "Context.h"
#import "AccessEnablerConstants.h"
#import "InternalStatus.h"

@interface AccessEnabler : NSObject <ConnectionsManagerDelegate> {
    id <EntitlementDelegate> delegate;

@private
    Context *context;
    InternalStatus *internalStatus;
    NSMutableArray *pendingCalls;
    NSMutableArray *pendingAuthorizationsRequests;
    NSMutableDictionary *authorizationRequestCachedStatuses;
    BOOL isAuthenticationTokenCached;
    BOOL isAuthenticatingFlag;
}
 
@property (assign) id <EntitlementDelegate> delegate;
@property (nonatomic, retain) Context *context;

- (id)init;

- (void) setRequestor:(NSString *)requestorID setSignedRequestorId:(NSString *)signedRequestorId;
- (void) setRequestor:(NSString *)requestorID setSignedRequestorId:(NSString *)signedRequestorId serviceProviders:(NSArray *)urls;
- (void) checkAuthentication;
- (void) getAuthentication;
- (void) checkAuthorization:(NSString *)resource;
- (void) getAuthorization:(NSString *)resource;
- (void) checkPreauthorizedResources:(NSArray *)resources;
- (void) setSelectedProvider:(NSString *)mvpdID;
- (void) getSelectedProvider;
- (void) getMetadata:(NSDictionary *)key;
- (void) logout;
- (void) getAuthenticationToken;

@end
