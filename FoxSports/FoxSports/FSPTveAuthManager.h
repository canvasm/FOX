//
//  FSPTveAuthManager.h
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 4/13/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AccessEnabler.h"

#define REQUESTOR_SUCCESS_NOTIFICATION @"RequestorSuccessNotification"
#define REQUESTOR_FAILURE_NOTIFICATION @"RequestorFailureNotification"
#define CERTIFICATE_FAILURE_NOTIFICATION @"CerticateFailuerNotification"

// Toggles between staging and production environments
#define USE_STAGING 1

// The URL to load the certificates from
#define CERTIFICATE_URL @"http://10.40.1.173/~jdubey/fs2go_um1_store.p12"

// This is here principally for showing or hiding the testing buttons.  It is not
// necessary for this switch to be on to enable or disable the other switches
// that can be used for testing.
#define TVE_DEBUG 0

// If NO, use the adobepass.p12 certificate in the application resources, and the AdobeBEAST
// requestor name.  Useful for testing login/logout if your machine is not
// white listed.  In this case the only MVPD that will be returned is Adobe, albeit 3 different
// flavors.  Any of them will work.  Login is randy/randy
#define USE_FOX_CERTS 1

#if USE_FOX_CERTS
#define REQUESTOR_NAME @"fs2go"
#else
#define REQUESTOR_NAME @"AdobeBEAST"
#endif

// If yes, then use the .p12 files in the application resources for
// signing of resources.  This will be removed once remote certificate
// downloads are finalized.
#define USE_LOCAL_CERTS 1

@protocol FSPTveAuthManagerDelegate <NSObject,NSURLConnectionDelegate>

@optional
/**
 * Called in response to "getAuthentication"
 
 * providers - An array of available providers
 */
- (void)displayProviderDialog:(NSArray *)providers;

/**
 * Called in response to "getAuthorizaton" if the authorization request failed.
 
 * resource - The name of the requested resource.
 * provider - The name of the cable provider the request was for.
 */
- (void)tokenRequestFailed:(NSString *)resource
                  provider:(NSString *)provider
                 errorCode:(NSString *)errorCode
          errorDescription:(NSString *)errorDescription;

/*!
 * Called in response to "checkAuthenticationStatus", as well after the user has attempted a login
 
 * status - 0 for failure, 1 for success
 */
- (void) setAuthenticationStatus:(int)status errorCode:(NSString *)errorCode;

/*!
 * Called in response to "getSelectedProvider".
 
 * mvpd - The selected provider
 */
- (void) selectedProvider:(MVPD *)mvpd;

/**
 * Called in response to "getAuthorization" if the authorization succeeds
 
 * token - The authorization token
 * resource - The name of the requested resource
 */
- (void) setToken:(NSString *)token forResource:(NSString *)resource;

/**
 * Called when the providerWebView is unhidden.
 */
- (void)didShowProviderWebView;

/**
 * Called when the providerWebView is hidden
 */
- (void)didHideProviderWebView;


/**
 * Called after authentication, authorization, or provider selection requests.  Provides tracking
 * data for these events
 */
- (void) sendTrackingData:(NSArray *)data forEventType:(int)event;

/**
 * Called in response to "getMetadata:"
 * 
 * status - 
 */
- (void) setMetadataStatus:(NSString *)metadata forKey:(int)key andArguments:(NSDictionary *)arguments;

/**
 * Called in response to "setSelectedProvider:".
 
 * url - The adobe pass url which will ultimately display the providers login page.
 */
- (void) navigateToUrl:(NSString *)url;

/**
 * Called in response to "getMetaData" or one of the metadata
 * convenience methods
 */
- (void)onMetaData:(NSString *)key data:(NSArray *)data;

/**
 * Called upon successful logout
 */
- (void)didLogout;

@end

@interface FSPTveAuthManager : NSObject <EntitlementDelegate, UIWebViewDelegate>

@property (nonatomic, assign) id<FSPTveAuthManagerDelegate>delegate;
@property (nonatomic, retain) NSString *requestorName;
@property (nonatomic, readonly) UIWebView *providerWebView;
@property (nonatomic, readonly) MVPD *currentProvider;
@property (nonatomic, readonly) NSArray *providers;
@property (nonatomic, assign) BOOL didAuthenticateWithProvider;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, assign, readonly) BOOL isEntitlementLoaded;

- (NSString *)requestorName;

/**
 * Check whether the user is authenticated.  Calls back "setAuthenticationStatus:errorCode:"
 */
- (void)checkAuthentication;

/**
 * Asks to authenticate the user.  Calls back "displayProviderDialog" if user is not authenticated.
 * If user has authenticated but the authentication token has expired, calls "navigateToUrl:", taking
 * the user to the login page of her provider.
 */
- (void)getAuthentication;

/**
 * Checks whether resource has been authorized.  Calls back "setToken:forResource" if successful, "tokenRequestFailed:withError"
 * if not.
 */
- (void)checkAuthorization:(NSString *)resource;

/**
 * Requests authorization for a resource.  Calls back "setToken:forResource" if successful, "tokenRequestFailed:withError"
 * if not.
 */
- (void)getAuthorization:(NSString *)resource;

/**
 * Checks whether their is a possibility of playing the resource, before the user has authenticated.
 * Calls back "preauthorizedResources:"
 */
- (void) checkPreauthorizedResources:(NSArray *)resources;

/**
 Sets the selected provider.  Calls back "navigateToURL:"
 */
- (void)setSelectedProvider:(NSString *)provider;

/**
 * Gets the currently selected provider. Calls back "selectedProvider:"
 */
- (void)getSelectedProvider;

/**
 * Get metadata for one of authorization. authentication, or device ID operation codes (see AccessEnablerConstants.h)
 * Calls back setMetadataStatus:forKey:andArguments:
 */
- (void)getMetadata:(NSDictionary *)dict;

/**
 * Get the metadata for a specific key.  Calls back "onMetaData:data:encrypted".
 *
 * As of press time, available keys are:
 * zipCode
 * channels
 * rating
 * dvrid
 */
- (void) getMetadataForKey:(NSString *)key;

/**
 * Convenience method for getting zipCode metadata
 */
- (void) getZipCodes;


/**
 * Logs the user out.
 */
- (void)logout;

/**
 * Returns the authentication token;  If call fails, calls "setAuthenticationStatus:errorCode" indicationg
 * failure.
 */
- (void)getAuthenticationToken;

/**
 Cancels the user login.  Call this if the user cancels out of the provider selection page.
 */
- (void)cancelLogin;

/**
 * Only works in DEBUG mode
 */
- (void) deletePrivateKey;

+ (FSPTveAuthManager *)sharedManager;

@end
