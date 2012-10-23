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
#import "Requestor.h"
#import "ConnectionsManager.h"
#import "StorageManager.h"

@interface Context : NSObject {

@private    
    ConnectionsManager *connectionsManager;
    StorageManager *storageManager;
    Requestor *requestor;
    NSMutableDictionary *deviceInfo;
    BOOL getAuthenticationWasCalled;
    BOOL setSelectedProviderWasCalled;
    NSString *signedRequestorId;
    
}

@property (nonatomic, retain) Requestor *requestor;
@property (nonatomic, retain) ConnectionsManager *connectionsManager;
@property (nonatomic, retain) StorageManager *storageManager;
@property (nonatomic, retain) NSMutableDictionary *deviceInfo;
@property (nonatomic, assign) BOOL getAuthenticationWasCalled;
@property (nonatomic, assign) BOOL setSelectedProviderWasCalled;
@property (nonatomic, retain) NSString *signedRequestorId;

@end
