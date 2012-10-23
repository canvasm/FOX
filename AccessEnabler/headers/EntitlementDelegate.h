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
#import "Mvpd.h"

@protocol EntitlementDelegate <NSObject>

- (void) setRequestorComplete:(int)status;
- (void) setAuthenticationStatus:(int)status errorCode:(NSString *)code;
- (void) setToken:(NSString *)token forResource:(NSString *)resource;
- (void) preauthorizedResources:(NSArray *)resources;
- (void) tokenRequestFailed:(NSString *)resource errorCode:(NSString *)code errorDescription:(NSString *)description;
- (void) selectedProvider:(MVPD *)mvpd;
- (void) displayProviderDialog:(NSArray *)mvpds;
- (void) sendTrackingData:(NSArray *)data forEventType:(int)event;
- (void) setMetadataStatus:(NSString *)metadata forKey:(int)key andArguments:(NSDictionary *)arguments;
- (void) navigateToUrl:(NSString *)url;

@end


