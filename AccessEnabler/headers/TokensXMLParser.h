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
#import "AuthenticationToken.h"

@interface TokensXMLParser : NSObject <NSXMLParserDelegate> {
    
@private    
    NSString *currentElementValue;
    AuthenticationToken *authnToken;
    
    BOOL isParsingAuthnToken;
    BOOL isParsingAuthzToken;
    
    NSString *authzTokenTTL;
    NSString *authzTokenresourceID;

    NSMutableArray *preAuthorizedResources;
    
}

@property (nonatomic, retain) AuthenticationToken *authnToken;
@property (nonatomic, retain) NSString *authzTokenTTL;
@property (nonatomic, retain) NSString *authzTokenresourceID;

- (TokensXMLParser *) initTokensXMLParser;

@end
