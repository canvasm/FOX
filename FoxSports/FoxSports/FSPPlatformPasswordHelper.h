//
//  FSPPlatformPasswordHelper.h
//  FoxSports
//
//  Created by Joshua Dubey on 8/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface FSPPlatformPasswordHelper : NSObject

+ (NSString *)authenticationPasswordForUserName:(NSString *)userName;
@end
