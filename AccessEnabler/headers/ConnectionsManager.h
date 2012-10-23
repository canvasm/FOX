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
#import "NSURLConnectionWithTag.h"
#import "GetMVPDXMLParser.h"
#import "TokensXMLParser.h"
#import "AccessEnablerConstants.h"
#import "Requestor.h"
#import "StorageManager.h"

#pragma mark - Connection tags
#define GET_REQUESTOR_TAG 10
#define GET_AUTHENTICATION_TOKEN_TAG 2
#define GET_AUTHORIZATION_TOKEN_TAG 3
#define GET_SHORT_MEDIA_TOKEN_TAG 4
#define GET_METADATA_TAG 5
#define CHECK_PREAUTHORIZATION_TOKEN_TAG 6

#pragma mark - Callbacks into AccessEnabler
@protocol ConnectionsManagerDelegate <NSObject>
- (void) processSuccessfulInSetRequestor: (Requestor*)localRequestor andDeviceInfo: (NSMutableDictionary*) localDeviceInfo;
- (void) processFailInSetRequestor;
- (void) processSuccessGetAuthToken:(AuthenticationToken *)token;
- (void) processFailGetAuthTokenWithErrorCode:(NSString *)errorCode;
- (void) processFailGetAuthToken;
- (void) processSuccessGetAuthorizationToken:(AuthorizationToken *)token;
- (void) processFailGetAuthorizationTokenForResource:(NSString *)resourceId withDetails:(NSString *)details;
- (void) processSuccessGetShortMediaTokenForResource:(NSString *)resourceId withToken:(NSString*)shortMediaToken;
- (void) processFailGetMetadata;
- (void) processSuccessGetMetadata:(NSString *)metadata;
- (void) processSuccessCheckPreauthorization:(NSMutableDictionary *)resourceDic;
@end

@interface ConnectionsManager : NSObject {   

@private    
    id <ConnectionsManagerDelegate> delegate;
    int nrSpUrls;
    NSMutableDictionary *dataFromConnectionsByTag;
    NSString *authenticationXML;
    NSMutableData *responseData;    
    Requestor *requestor;
    NSMutableDictionary *deviceInfo;
    BOOL configDataReceived;
    NSURLConnectionWithTag *urlConnectionWithTag;
}

@property (assign) id <ConnectionsManagerDelegate> delegate;
@property (nonatomic, assign) int nrSpUrls;
@property (nonatomic, retain) NSURLConnectionWithTag *urlConnectionWithTag;

- (void)startGETConnectionWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url andSpUrl:(NSString *)spUrl;
- (void)startPOSTConnectionForGetAuthenticationWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url withData:(NSDictionary*)data andCookies:(NSString *)cookies;
- (void)startPOSTConnectionForGetAuthorizationWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url withData:(NSDictionary*)data andCookies:(NSString *)cookies;
- (void)startPOSTConnectionForCheckPreauthorizationWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url withData:(NSDictionary*)data andCookies:(NSString *)cookies;
- (void)startPOSTConnectionForShortMediaTokenWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url withData:(NSDictionary*)data andCookies:(NSString *)cookies;
- (void)startPOSTConnectionForDeviceIdWithTag:(NSNumber *)connectionTag andURL:(NSURL *)url withData:(NSDictionary *)data;

- (void)deleteCookiesFileFromDisk;

@end
