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
#import "ServerAPIVersion.h"

#define CLIENT_VERSION @"1.3"

#define DEFAULT_SP_URL @"sp.auth.adobe.com/adobe-services"

#pragma mark - HTTP errors
#define ERROR_HTTP_NOT_FOUND @"HTTP Status 400 - Requestor not found for given ID"
#define ERROR_HTTP_400 @"HTTP Status 40"
#define ERROR_HTTP_410 @"410 Gone"


#pragma mark - AdobePass web-service paths
#define SP_URL_DOMAIN_NAME                      @"adobe.com"
#define SP_URL_PATH_SET_REQUESTOR               @"/config/"
#define SP_URL_PATH_GET_AUTHENTICATION          @"/authenticate/saml"
#define SP_URL_PATH_GET_AUTHENTICATION_TOKEN    @"/sessionDevice"
#define SP_URL_PATH_GET_AUTHORIZATION_TOKEN     @"/authorizeDevice"
#define SP_URL_PATH_GET_SHORT_MEDIA_TOKEN       @"/deviceShortAuthorize"
#define SP_URL_PATH_LOGOUT                      @"/logout"
#define SP_URL_PATH_GET_METADATA                @"/getMetadataDevice"
#define SP_URL_PATH_CHECK_PREAUTHZ_RESOURCES    @"/preauthorize"
#define ADOBEPASS_REDIRECT_URL                  @"http://adobepass.ios.app/"

#pragma mark - AccessEnabler status codes
#define ACCESS_ENABLER_STATUS_ERROR  0
#define ACCESS_ENABLER_STATUS_SUCCESS  1

#pragma mark - AccessEnabler error codes
#define USER_AUTHENTICATED              @""
#define USER_NOT_AUTHENTICATED_ERROR    @"User Not Authenticated Error"
#define USER_NOT_AUTHORIZED_ERROR       @"User Not Authorized Error"
#define PROVIDER_NOT_SELECTED_ERROR     @"Provider Not Selected Error"
#define GENERIC_AUTHENTICATION_ERROR    @"Generic Authentication Error"
#define SERVER_API_TOO_OLD				@"API Version too old. Please update your application."

#pragma mark - getMetadata operation codes
#define METADATA_AUTHENTICATION     0
#define METADATA_AUTHORIZATION      1
#define METADATA_DEVICE_ID          2
#define METADATA_OPCODE_KEY         @"opCode"
#define METADATA_RESOURCE_ID_KEY    @"resource_id"

#pragma mark - sendTrackingData event types
#define TRACKING_AUTHENTICATION         0
#define TRACKING_AUTHORIZATION          1
#define TRACKING_MVPD_SELECTION         2

#pragma mark - sendTrackingData return values
#define TRACKING_NONE  @"None"
#define TRACKING_YES  @"YES"
#define TRACKING_NO   @"NO"
