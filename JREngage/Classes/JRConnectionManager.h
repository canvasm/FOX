/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 Copyright (c) 2010, Janrain, Inc.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer. 
 * Redistributions in binary form must reproduce the above copyright notice, 
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution. 
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.
 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 File:   JRConnectionManager.h 
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JRConnectionManagerDelegate <NSObject>
@optional
- (void)connectionDidFinishLoadingWithPayload:(NSString*)payload request:(NSURLRequest*)request andTag:(void*)userdata;
- (void)connectionDidFinishLoadingWithFullResponse:(NSURLResponse*)fullResponse 
                                  unencodedPayload:(NSData*)payload 
                                           request:(NSURLRequest*)request 
                                            andTag:(void*)userdata;
- (void)connectionDidFailWithError:(NSError*)error request:(NSURLRequest*)request andTag:(void*)userdata;
- (void)connectionWasStoppedWithTag:(void*)userdata;
@end

@interface JRConnectionManager : NSObject 
{
    CFMutableDictionaryRef connectionBuffers;
}

@property CFMutableDictionaryRef connectionBuffers;

+ (bool)createConnectionFromRequest:(NSURLRequest*)request 
                        forDelegate:(id<JRConnectionManagerDelegate>)delegate 
                            withTag:(void*)userdata;

+ (bool)createConnectionFromRequest:(NSURLRequest*)request 
                        forDelegate:(id<JRConnectionManagerDelegate>)delegate 
                 returnFullResponse:(BOOL)returnFullResponse
                            withTag:(void*)userdata;

+ (void)stopConnectionsForDelegate:(id<JRConnectionManagerDelegate>)delegate;

+ (NSUInteger)openConnections;
@end
