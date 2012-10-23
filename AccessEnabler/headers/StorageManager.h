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
#import <UIKit/UIPasteboard.h>
#import "AuthenticationToken.h"
#import "AuthorizationToken.h"

@interface StorageManager : NSObject {    
    
@private    
    AuthenticationToken *authnToken;
    NSString *currentMvpdId;
    BOOL canAuthenticate;
    BOOL useSharedStorage;
    NSMutableArray *authzTokens;
    NSDictionary *preAuthorizedResources;
    UIPasteboard *pasteBoard;

}

@property (nonatomic, retain) AuthenticationToken *authnToken;
@property (nonatomic, retain) NSString *currentMvpdId;
@property (nonatomic, retain) NSDictionary *preAuthorizedResources;
@property (nonatomic, assign) BOOL canAuthenticate;

- (void) importAuthorizationToken:(AuthorizationToken*)authzToken;
- (AuthorizationToken*) getAuthorizationToken:(NSString*)resourceId;

- (void) savePreAuthorizedResources:(NSDictionary *)preAuthorizedResourceList;

- (void)clearAll;
- (void)updateCurrentMvpdId:(NSString *)newMvpdId;
- (void)updateAuthnToken:(AuthenticationToken *)newToken;
- (void)useSharedStorage:(BOOL)choice;

- (void)readDataFromStorage;
- (void)writeDataToStorage;


@end
