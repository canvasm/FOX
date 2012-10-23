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
#import "MVPD.h"

@interface Requestor : NSObject {

@private    
    NSString *requestorId;
    NSString *signedRequestorId;
    NSString *requestorName;
    NSMutableArray *mvpds;
    BOOL isValid;
    BOOL isAuthenticated;

}

@property (nonatomic, retain) NSString *requestorId;
@property (nonatomic, retain) NSString *signedRequestorId;
@property (nonatomic, retain) NSString *requestorName;
@property (nonatomic, retain) NSMutableArray *mvpds;
@property (nonatomic, assign) BOOL isValid; 
@property (nonatomic, assign) BOOL isAuthenticated;

- (void)initWithRequestor:(Requestor *)requestor;

- (BOOL)isMvpdValid:(NSString *)mvpdId;
- (MVPD *)getMvpdForId:(NSString *)mvpdId;

@end
