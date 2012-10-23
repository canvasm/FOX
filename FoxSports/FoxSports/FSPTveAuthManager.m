//
//  FSPTveAuthManager.m
//  DemoApp
//
//  Created by Joshua Dubey on 4/13/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import "FSPTveAuthManager.h"
#import "NSUtils.h"
#import "FSPLogging.h"

#define SP_AUTH_PRODUCTION  @"sp.auth.adobe.com/adobe-services"
#define SP_AUTH_STAGING     @"sp.auth-staging.adobe.com/adobe-services"
#define SP_AUTH_UAT1        @"sp.auth-uat1.adobe.com/adobe-services"

// See comment in FSPTveAuthManager.h
#if USE_FOX_CERTS
#define CERTIFICATE_FILENAME_1 @"fs2go_um1_store"
#define CERTIFICATE_PASSPHRASE_1 @"MB=xhzL(v2d!4y25xW+vAae@@wu-vpSD<YfQB4I*P9Xe9]Gsr,fyoDm.Jx--fnlo"
#define CERTIFICATE_FILENAME_2 @"fs2go_um2c_store"
#define CERTIFICATE_PASSPHRASE_2 @"4,b_CH3v!!s=CJlV>iX@Wk3O(0<Zc#jCy9E-0TB2,8gfU]cx+bCo_gYy#JC{vymP"
#else
#define CERTIFICATE_FILENAME_1 @"adobepass"
#define CERTIFICATE_PASSPHRASE_1 @"adobepass"


#endif

#define MAX_RETRY_COUNT 3

@interface FSPTveAuthManager ()
@property (nonatomic, strong) AccessEnabler *adobePassInterface;
@property (nonatomic, assign) BOOL didRetryKeyAdd;
@property (nonatomic, assign) BOOL didRetrySigning;
@property (nonatomic, assign) BOOL didRetryExtraction;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) BOOL isLogout;

- (NSString *)signRequestorId:(NSString *)requestorId
                      withKey:(SecKeyRef)key;
- (NSString *)htmlEntityEncode:(NSString *)string;
CFDataRef persistentRefForIdentity(SecIdentityRef identity);
- (void)showProviderWebView;
- (void)hideProviderWebView;
- (void)fetchCertificate;
- (void)deletePrivateKey;
@end


/*******************  TESTING - REMOVE BEFORE SUBMISSION ******************/
//needed to accept cookies.
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
/****************** END TESTING *******************************************/

@implementation FSPTveAuthManager

@synthesize adobePassInterface;
@synthesize delegate;
@synthesize requestorName;
@synthesize providerWebView;
@synthesize currentProvider;
@synthesize providers = _providers;
@synthesize didRetryKeyAdd;
@synthesize didRetrySigning;
@synthesize didRetryExtraction;
@synthesize retryCount;
@synthesize didAuthenticateWithProvider = _didAuthenticateWithProvider;
@synthesize isAuthenticated = _isAuthenticated;
@synthesize isLogout = _isLogout;
@synthesize isEntitlementLoaded = _isEntitlementLoaded;

static FSPTveAuthManager *sharedManager;

+ (FSPTveAuthManager *)sharedManager
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedManager = [[FSPTveAuthManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        providerWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        providerWebView.delegate = self;
        providerWebView.hidden = YES;
        self.adobePassInterface = [[AccessEnabler alloc] init];
        self.adobePassInterface.delegate = self;
        retryCount = 0;
        
        
        /*******************  TESTING - REMOVE BEFORE SUBMISSION ******************/
        // accept all HTTPS certificates from our SPs
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"sp.auth.adobe.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"sp.auth-staging.adobe.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"sp.auth-uat1.adobe.com"];
        
        // accept all HTTPS certificates from our IdP partners
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"idm.east.two.qa.cox.net"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"authentication.charter.net.ent-web01.dev.synacor.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"identity1.dishnetwork.com.ent-web01.dev.synacor.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"twcidp.eng.rr.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"login.stage.att.net"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"authorize.suddenlink.net.ent-web01.dev.synacor.com"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"tids.tpa.bhn.net"];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"auth.mediacomtoday.com.ent-web01.dev.synacor.com"];
        /****************** END TESTING *******************************************/

        dispatch_async(dispatch_queue_create("TVE", DISPATCH_QUEUE_CONCURRENT), ^{
            [self setRequestorName:REQUESTOR_NAME];
        });
        
        return self;
    }
    
    return nil;
}


- (void)setRequestorName:(NSString *)theRequestor
{
    requestorName = theRequestor;
    SecKeyRef privateKey = [self privateKey];
    if (privateKey != NULL) {
        NSString *signedRequestorId = [self signRequestorId:theRequestor
                                       withKey:privateKey];
        signedRequestorId = [self htmlEntityEncode:signedRequestorId];
        
#if USE_STAGING
        [self.adobePassInterface setRequestor:requestorName
                         setSignedRequestorId:signedRequestorId
                             serviceProviders:@[SP_AUTH_STAGING]];
#else
    [self.adobePassInterface setRequestor:requestorName
                     setSignedRequestorId:signedRequestorId
                         serviceProviders:[NSArray arrayWithObject:SP_AUTH_PRODUCTION]];

#endif
    }
    else {
        [self fetchCertificate];
    }
}

//------------------------------------------------------------------------------
// MARK: - API
//------------------------------------------------------------------------------

- (void)checkAuthentication
{
    FSPLogTve(@"checkAuthentication");
    [self.adobePassInterface checkAuthentication];
}

- (void)getAuthentication
{
    FSPLogTve(@"getAuthentication");
    [self.adobePassInterface getAuthentication];
}

- (void) getAuthenticationToken
{
    FSPLogTve(@"getAuthenticationToken");
    [self.adobePassInterface getAuthenticationToken];
}

- (void)checkAuthorization:(NSString *)resource
{
    FSPLogTve(@"checkAuthorization %@", resource);
    [self.adobePassInterface checkAuthorization:resource];
}

- (void)getAuthorization:(NSString *)resource;
{
    FSPLogTve(@"getAuthorization %@", resource);
    [self.adobePassInterface getAuthorization:(NSString *)resource];
}

- (void) checkPreauthorizedResources:(NSArray *)resources
{
    FSPLogTve(@"checkPreauthorizedResources %@", resources);
    [self.adobePassInterface checkPreauthorizedResources:resources];
}

- (void)setSelectedProvider:(NSString *)provider
{
    FSPLogTve(@"setSelectedProvider: %@",provider);
    [self.adobePassInterface setSelectedProvider:provider];
    [self showProviderWebView];
}

- (void) getSelectedProvider {
    FSPLogTve(@"getSelectedProvider");
    [self.adobePassInterface getSelectedProvider];
}

- (void) getMetadata:(NSDictionary *)dict {
    [self.adobePassInterface getMetadata:dict];
}

- (void) getMetadataForKey:(NSString *)key
{
    //[self.adobePassInterface getMetadata:key];
}

- (void) getZipCodes
{
    [self getMetadataForKey:@"zipCode"];
}

- (void)cancelLogin
{
    FSPLogTve(@"cancelLogin");
    [self setSelectedProvider:nil];
}

- (void) logout
{
    FSPLogTve(@"logout");
    self.isLogout = YES;
    [self.adobePassInterface logout];
}


- (void) deletePrivateKey
{
    FSPLogTve(@"deletePrivateKey key");
    while ([self privateKey]) {
        FSPLogTve(@"attempting to delete private key");
        OSStatus status = SecItemDelete ((__bridge CFDictionaryRef)[self queryForKey]);
        if (status != noErr) {
            FSPLogTve(@"Unable to delete private key");
        }
        else {
            FSPLogTve(@"Deleted private key");
        }
    }
}


//------------------------------------------------------------------------------
// MARK: - Entitlement Delegate
//------------------------------------------------------------------------------

- (void) setRequestorComplete:(int)status {
    NSString *notificationName = nil;
    switch (status) {
        case ACCESS_ENABLER_STATUS_SUCCESS:{
            _isEntitlementLoaded = YES;
            FSPLogTve(@"setRequestor: SUCCESS");
            notificationName = REQUESTOR_SUCCESS_NOTIFICATION;            
        }break;
            
        case ACCESS_ENABLER_STATUS_ERROR:{
            _isEntitlementLoaded = NO;
            FSPLogTve(@"setRequestor: FAILED");
            notificationName = REQUESTOR_FAILURE_NOTIFICATION;
        }break;
            
        default:{
            _isEntitlementLoaded = NO;
            FSPLogTve(@"setRequestor: UNKNOWN");
            notificationName = REQUESTOR_FAILURE_NOTIFICATION;
        }break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil];
    
}

- (void) selectedProvider:(MVPD *)mvpd {
    if (mvpd == nil) {
        FSPLogTve(@"selectedProvider: No Selected Provider");
    } else {
        FSPLogTve(@"selectedProvider: %@", mvpd.displayName);
    }
    currentProvider = mvpd;
    
    if ([self.delegate respondsToSelector:@selector(selectedProvider:)]) {
        [self.delegate selectedProvider:mvpd];
    }
}

- (void) displayProviderDialog:(NSArray *)providers {
    FSPLogTve(@"Displaying the provider dialog (%d MVPDs).", [providers count]);
    _providers = providers;
    [self hideProviderWebView];
    
    if ([self.delegate respondsToSelector:@selector(displayProviderDialog:)]) {
        [self.delegate displayProviderDialog:providers];
    }    
}

- (void) setAuthenticationStatus:(int)status errorCode:(NSString *)errorCode {
    
    switch (status) {
        case ACCESS_ENABLER_STATUS_SUCCESS: {
            _isAuthenticated = YES;
            FSPLogTve(@"Auth Status : Authenticated");
        } break;
            
        case ACCESS_ENABLER_STATUS_ERROR: {
            _isAuthenticated = NO;
            FSPLogTve(@"Auth Status : %@", errorCode);
        } break;            
            
        default: {
            _isAuthenticated = NO;
            FSPLogTve(@"Auth Status : Unknown operation status");
        } break;
    }
        
    if ([self.delegate respondsToSelector:@selector(setAuthenticationStatus:errorCode:)]) {
        [self.delegate setAuthenticationStatus:status errorCode:errorCode];
    }    
}

- (void) tokenRequestFailed:(NSString *)resource errorCode:(NSString *)code errorDescription:(NSString *)description {
    FSPLogTve(@"token request failed %@", [NSString stringWithFormat:@"RESOURCE:%@\nERROR:%@\nERROR DETAILS:%@", resource, code, description]);
}

- (void) preauthorizedResources:(NSArray *)resources
{
    FSPLogTve(@"Preauthorized resources are %@", resources);
}

- (void) navigateToUrl:(NSString *)url {
    FSPLogTve(@"navigateToURL: %@", url);
    [providerWebView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) setToken:(NSString *)token forResource:(NSString *)resource {
    FSPLogTve(@"Short media token: %@", token);
    
    FSPLogTve(@"setToken:forResource: %@", [NSString stringWithFormat: @"Authorized for resource %@",resource]);
    if ([self.delegate respondsToSelector:@selector(setToken:forResource:)]) {
        [self.delegate setToken:token forResource:resource];
    }
    // Need to send token for media server verification
    // Call back from media verification service is valid(?)  Pass token and resource to media server?
}

- (void) setMetadataStatus:(NSString *)metadata forKey:(int)key andArguments:(NSDictionary *)arguments {
    if (metadata == nil ) { // we have no metadata available
        FSPLogTve(@"setMetadataStatus:forKey:andArguments: no metadata");
    } else { // we have some metadata to process
        metadata = [metadata stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        switch (key) {
            case METADATA_AUTHENTICATION: {
                FSPLogTve(@"setMetadataStatus:forKey:andArguments: authentication metadata = %@", metadata);
            } break;
                
            case METADATA_AUTHORIZATION: {
                NSString *message = [NSString stringWithString:metadata];
                if ([arguments valueForKey:METADATA_RESOURCE_ID_KEY]) {
                    message = [message stringByAppendingFormat:@" resource id: %@", [arguments valueForKey:METADATA_RESOURCE_ID_KEY]];
                }
                FSPLogTve(@"setMetadataStatus:forKey:andArguments: authorization metadata = %@", message);
            } break;
                
            case METADATA_DEVICE_ID: {
                FSPLogTve(@"setMetadataStatus:forKey:andArguments: device_id metadata = %@", metadata);
            } break;
                
            default: {
                // do nothing
            } break;
        }
    }
        
    if ([self.delegate respondsToSelector:@selector(setMetadataStatus:forKey:andArguments:)]) {
        [self.delegate setMetadataStatus:metadata forKey:key andArguments:arguments];
    }
    
}

-(void) sendTrackingData:(NSArray *)data forEventType:(int)event {
    NSString *message = @"";
    NSEnumerator *e = [data objectEnumerator];
    
    NSString *eventName = @"";
    switch (event) {
        case TRACKING_MVPD_SELECTION:
            eventName = @"mvpdSelection";
            
            message = [message stringByAppendingFormat:@"MVPD ID: %@\n", (NSString*) [e nextObject]];
            
            message = [message stringByAppendingFormat:@"DEVICE TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"CLIENT TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"OS: %@\n", (NSString*) [e nextObject]];
            
            break;
            
        case TRACKING_AUTHENTICATION:
            eventName = @"authenticationDetection";
            
            message = [message stringByAppendingFormat:@"SUCCESSFUL: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"MVPD ID: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"GUID: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"AUTHN CACHED: %@\n", (NSString*) [e nextObject]];
            
            message = [message stringByAppendingFormat:@"DEVICE TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"CLIENT TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"OS: %@\n", (NSString*) [e nextObject]];
            
            break;
            
        case TRACKING_AUTHORIZATION:
            eventName = @"authorizationDetection";
            
            message = [message stringByAppendingFormat:@"SUCCESSFUL: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"MVPD ID: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"GUID: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"AUTHZ CACHED: %@\n", (NSString*) [e nextObject]];
            
            message = [message stringByAppendingFormat:@"ERROR: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"ERROR DETAILS: %@\n", (NSString*) [e nextObject]];                
            
            message = [message stringByAppendingFormat:@"DEVICE TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"CLIENT TYPE: %@\n", (NSString*) [e nextObject]];
            message = [message stringByAppendingFormat:@"OS: %@\n", (NSString*) [e nextObject]];
            
            break;
            
        default:
            // do nothing
            break;            
    }
    
    message = [NSString stringWithFormat:@"EVENT: %@ \n\n%@", eventName, message];
    
    FSPLogTve(@"TRACKING: %@", message);
    
    if ([self.delegate respondsToSelector:@selector(sendTrackingData:forEventType:)]) {
        [self.delegate sendTrackingData:data forEventType:event];
    }

}

- (void)onMetaData:(NSString *)key data:(NSArray *)data encrypted:(BOOL)encrypted
{
    // Encrypted not currently supported
    if ([self.delegate respondsToSelector:@selector(onMetaData:data:)]) {
        [self.delegate onMetaData:key data:data];
    }
}


//------------------------------------------------------------------------------
// MARK: - UIWebViewDelegate
//------------------------------------------------------------------------------

- (BOOL) webView:(UIWebView*)localWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {    
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {		
        FSPLogTve(@"loading path URL %@", [[[localWebView request] URL] absoluteString]);        
	}
    
	return YES;
}

- (void)webView:(UIWebView *)localWebView didFailLoadWithError:(NSError *)error {
    // NOTE: A load failure on the ADOBE_REDIRECT_URL is actually used to indicate that the authentication/logout request
    // has succeeded.
    if ([(NSString *)[[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"] isEqualToString:ADOBEPASS_REDIRECT_URL]) {
        [self hideProviderWebView];
        if (self.isLogout) {
            self.isLogout = NO;
            if ([self.delegate respondsToSelector:@selector(didLogout)]) {
                _isAuthenticated = NO;
                self.didAuthenticateWithProvider = NO;
                [self.delegate didLogout];
            }
            FSPLogTve(@"Successful log out from %@", self.currentProvider.displayName);
        }
        else {
            FSPLogTve(@"Successful log in");
            self.didAuthenticateWithProvider = YES;
            [self getAuthenticationToken];        
        }
    }
    else {
        FSPLogTve(@"Web view did fail load with error : %@", error);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)localWebView {
    FSPLogTve(@"did finish load %@", [[[ localWebView request ]URL] absoluteString]);
}


//------------------------------------------------------------------------------
// MARK: - Private
//------------------------------------------------------------------------------

- (void)fetchCertificate
{
#if USE_LOCAL_CERTS
    NSString *keyStoreName = CERTIFICATE_FILENAME_1;
    if (didRetryExtraction || didRetryKeyAdd || didRetrySigning) {
#if USE_FOX_CERTS
        FSPLogTve(@"USE File 2");
        keyStoreName = CERTIFICATE_FILENAME_2;
#endif
    }
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:keyStoreName ofType:@"p12"];
    NSData *PKCS12Data = [NSData dataWithContentsOfFile:thePath];
    SecKeyRef key = [self addPrivateKeyFromCertificateToKeyChain:PKCS12Data];
    if (key !=  NULL) {
        NSString *signedRequestorId = [self signRequestorId:requestorName
                                                    withKey:key];
        signedRequestorId = [self htmlEntityEncode:signedRequestorId];
    #if USE_STAGING
        [self.adobePassInterface setRequestor:requestorName
                         setSignedRequestorId:signedRequestorId
                             serviceProviders:@[SP_AUTH_STAGING]];
    #else
        [self.adobePassInterface setRequestor:requestorName
                         setSignedRequestorId:signedRequestorId
                             serviceProviders:[NSArray arrayWithObject:SP_AUTH_PRODUCTION]];
        
    #endif
    }

#else
    NSURLRequest *certRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:CERTIFICATE_URL]];
    [NSURLConnection sendAsynchronousRequest:certRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *certificateData, NSError *error) {
                               if (certificateData != nil) {
                                   FSPLogTve(@"Fetched certificate");
                                    
                                   retryCount = 0;
                                   
                                   SecKeyRef key = [self addPrivateKeyFromCertificateToKeyChain:certificateData];
                               
                                   if (key !=  NULL) {
                                       NSString *signedRequestorId = [self signRequestorId:requestorName
                                                                                   withKey:key];
                                       signedRequestorId = [self htmlEntityEncode:signedRequestorId];
    #if USE_STAGING
                                       [self.adobePassInterface setRequestor:requestorName
                                                        setSignedRequestorId:signedRequestorId
                                                            serviceProviders:[NSArray arrayWithObject:SP_AUTH_STAGING]];
    #else
                                       [self.adobePassInterface setRequestor:requestorName
                                                        setSignedRequestorId:signedRequestorId
                                                            serviceProviders:[NSArray arrayWithObject:SP_AUTH_PRODUCTION]];
                                  
    #endif
                                   }
                               }
                               
                               if (error != nil) {
                                   FSPLogTve(@"Certificate request error : %@", error);
                                   FSPLogTve(@"Retry count = %i", retryCount);
                                   // Try MAX more times
                                   // TODO Wait between tries?
                                   if (retryCount < MAX_RETRY_COUNT) {
                                       [self fetchCertificate];
                                       retryCount++;
                                   }
                               }
                           }];
#endif
}


- (void)showProviderWebView
{
    self.providerWebView.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(didShowProviderWebView)]) {
        [self.delegate didShowProviderWebView];
    }
}

- (void)hideProviderWebView
{
    providerWebView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didHideProviderWebView)]) {
        [self.delegate didHideProviderWebView];
    }
}


- (NSString *)htmlEntityEncode:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    return string;
}

- (NSString *)signRequestorId:(NSString *)requestorId
                      withKey:(SecKeyRef)key
{
    uint8_t *signedBytes = NULL;
    OSStatus status = noErr;
    NSString *signedRequestorId = nil;
    
    size_t signedBytesSize = SecKeyGetBlockSize(key);;
    
    // malloc a buffer to hold signature
    signedBytes = malloc(signedBytesSize * sizeof(uint8_t));
    memset((void *)signedBytes, 0x0, signedBytesSize);
    
    // sign data
    const char* nonce = [requestorId UTF8String];
    status = SecKeyRawSign(key,
                           kSecPaddingPKCS1,
                           (const uint8_t*)nonce,
                           strlen(nonce),
                           (uint8_t *)signedBytes,
                           &signedBytesSize);
    
    if (status == errSecSuccess) {
        NSData *encryptedBytes = [NSData dataWithBytes:(const void *)signedBytes
                                                length:signedBytesSize];
        
        signedRequestorId = [NSUtils base64Encoding:encryptedBytes];
    } else {
        FSPLogTve(@"Cannot sign the device id info: failed obtaining the signed bytes.");
        if (!didRetrySigning) {
            // Give it one more go, cert might have expired
             didRetrySigning = YES;
            [self fetchCertificate];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:CERTIFICATE_FAILURE_NOTIFICATION object:nil];
        }
    }            

    free(signedBytes);

    return signedRequestorId;
}

- (SecKeyRef)addPrivateKeyFromCertificateToKeyChain:(NSData *)certData
{
    uint8_t *signedBytes = NULL;
    OSStatus status = noErr;
    
    SecKeyRef privateKey = NULL;
    
    NSString *keyStorePass = CERTIFICATE_PASSPHRASE_1;
    if (didRetryKeyAdd || didRetryExtraction || didRetrySigning) {
#if USE_FOX_CERTS
        FSPLogTve(@"Initial certification failure, Using passphrase #2");
        keyStorePass = CERTIFICATE_PASSPHRASE_2;
#endif
    }

    CFStringRef password =  (__bridge CFStringRef)keyStorePass;
    
    CFDataRef inPKCS12Data = (__bridge CFDataRef)certData;

    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = NULL;
    status = SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    
    if (status == errSecSuccess) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);            
        // Store the key
        SecIdentityRef outIdentity = (SecIdentityRef)CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        status = SecIdentityCopyPrivateKey (outIdentity, &privateKey);
        if (status == errSecSuccess) {
            [self updatePrivateKey:privateKey];
        }
        else {
            FSPLogTve(@"Failed to extract the private key from the keystore.");
            if (!didRetryExtraction) {
                didRetryExtraction = YES;
                [self fetchCertificate];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:CERTIFICATE_FAILURE_NOTIFICATION object:nil];
            }
        }
    } else {
        FSPLogTve(@"Cannot sign the device id info: failed importing keystore.");
        // Try refetching once
        if (!didRetryKeyAdd) {
            didRetryKeyAdd = YES;
            [self fetchCertificate];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:CERTIFICATE_FAILURE_NOTIFICATION object:nil];
        }
    }

    // clean-up
    if (items) {
        CFRelease(items);
    }

    if (signedBytes) {
        free(signedBytes);
    }

    if (optionsDictionary) {
        CFRelease(optionsDictionary);
    }
    
    return privateKey;
}

- (NSMutableDictionary *)queryForKey
{
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassKey, kSecClass, CERTIFICATE_FILENAME_1, kSecAttrApplicationLabel, nil];
    // If there were any failures/retries, try the backup key
    if (didRetryExtraction || didRetryKeyAdd || didRetrySigning) {
#if USE_FOX_CERTS
        FSPLogTve(@"Initial certificate failure.  Using certificate 2");
        query = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassKey, kSecClass, CERTIFICATE_FILENAME_2, kSecAttrApplicationLabel, nil];
#endif
    }
    return query;
}

- (SecKeyRef)privateKey
{
    NSMutableDictionary *query = [self queryForKey];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];
    CFTypeRef data = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFMutableDictionaryRef)query, &data);
    if (status == noErr) {
        FSPLogTve(@"private key  returning %@", data);
        return (SecKeyRef)data;
    }
    return NULL;
}

- (BOOL) updatePrivateKey:(SecKeyRef) key
{
    FSPLogTve(@"Updating private key with key %@", key);
    NSMutableDictionary *attrs = [self queryForKey];
    [attrs setObject:(__bridge id)key forKey:(__bridge id)kSecValueRef];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) attrs, NULL);
    FSPLogTve(@"Update status %ld", status);
    return status == noErr;
}

@end
