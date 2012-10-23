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

@protocol NSURLConnectionWithTagProtocol

@required 

@property (nonatomic, retain) NSNumber *tag;
@property (nonatomic, retain) NSString *shortMediaResourceID;
@property (nonatomic, retain) NSString *spUrl;

@end


@class NSURLConnectionWrapper;


@interface NSURLConnectionWithTag : NSObject {
    
@private    
    id<NSURLConnectionWithTagProtocol> urlConnection;
    NSString *local_shortMediaResourceID; 
    NSString *local_spUrl;
    NSNumber *local_tag;
    
}

@property (nonatomic, retain) id<NSURLConnectionWithTagProtocol> urlConnection;

- (void)createWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSNumber*)_tag;

- (void)createWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately 
                      tag:(NSNumber*)_tag shortMediaResourceID:(NSString *)_shortMediaResourceID;

- (void)createWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately 
                      tag:(NSNumber*)_tag spUrl:(NSString*)_spUrl;

- (NSNumber*)tag;
- (NSString*)shortMediaResourceID;
- (NSString*)spUrl;

- (void)setTag:(NSNumber*) tag;
- (void)setShortMediaResourceID:(NSString*) shortMediaResourceID;
- (void)setSpUrl:(NSString*) spUrl;

@end


// helper class
@interface NSURLConnectionWrapper : NSURLConnection<NSURLConnectionWithTagProtocol> {
    
@private    
	NSNumber *tag;
    NSString *shortMediaResourceID; 
    NSString *spUrl;
    
}

@end

