//
//  FSPPlatformPasswordHelper.m
//  FoxSports
//
//  Created by Joshua Dubey on 8/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlatformPasswordHelper.h"

// Found in AccessEnabler framework
#import "NSData+FSPExtensions.h"

#import "JSONKit/JSONKit.h"

#include <openssl/rc4.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>

#define kChosenCipherKeySize 128

@interface FSPPlatformPasswordHelper()

+ (NSData *)rC4encryptData:(NSData*)data withKey:(NSString *)encryptionKey;
+ (NSData *)rsaEncryptData:(NSData *)data;
+ (NSString *)generateSymmetricKey;

@end

@implementation FSPPlatformPasswordHelper

static const NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

+ (NSString *)authenticationPasswordForUserName:(NSString *)userName
{
    // The authentication password is created as follows:
    // 1) RC4 Encypt the userinfo json dictionary using a random symmetric key
    // 2) RSA Encrypt the random symmetric key using the private key provided by FOX.
    // 3) base64 encode each result, and concatenate together with a '|' separator.
    // The final format is as below:
    // (Base64 encoded (RSA-encrypted (Random symmetric session key)))|(Base 64 encoded (Session-key encrypted (JSON UserInfo object )))
    
    NSDictionary *userinfoDictionary = @{ @"userName" : userName };
    NSString *jsonUserInfoDictionary = [userinfoDictionary JSONString];
    
    // Generate the symmetric key
    NSString *rc4Key = [FSPPlatformPasswordHelper generateSymmetricKey];
    
    // Encrypt the userInfo
    NSData *encryptedUserInfo = [FSPPlatformPasswordHelper rC4encryptData:[jsonUserInfoDictionary dataUsingEncoding:NSUTF8StringEncoding] withKey:rc4Key];
    if (encryptedUserInfo == nil)
        return nil;
    
    // base64 encode the result
    NSString *encodedUserInfo = [encryptedUserInfo fsp_base64String];
    
    NSData *rc4KeyData = [[NSData alloc] initWithBytes:[rc4Key UTF8String] length:rc4Key.length];
    NSData *encryptedKey = [FSPPlatformPasswordHelper rsaEncryptData:rc4KeyData];
    if (encryptedKey == nil)
        return nil;
    
    // base64 encode the result
    NSString *encodedKey = [encryptedKey fsp_base64String];
    
    // Create the password
    NSString *password = [NSString stringWithFormat:@"%@|%@",encodedKey, encodedUserInfo];
    
    return password;
}


+ (NSString *)generateSymmetricKey {
    
    NSMutableString *key = [NSMutableString stringWithCapacity:kChosenCipherKeySize];
    for (NSInteger i = 0U; i < kChosenCipherKeySize; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [key appendFormat:@"%C", c];
    }
    return key;
}

+ (NSData *)rC4encryptData:(NSData*)data withKey:(NSString *)encryptionKey
{
    const char *symmetricKey = [encryptionKey UTF8String];
    char dataToEncrypt[data.length];
    [data getBytes:dataToEncrypt length:data.length];
    uint8_t * encryptedUserInfo = NULL;
    encryptedUserInfo = malloc( kChosenCipherKeySize * sizeof(uint8_t) );
    memset((void *)encryptedUserInfo, 0x0, kChosenCipherKeySize);
    
    RC4_KEY rc4_key;
    
    RC4_set_key(&rc4_key, strlen(symmetricKey), (const unsigned char *)symmetricKey);
    RC4(&rc4_key, data.length, (const unsigned char *)dataToEncrypt, encryptedUserInfo);
        
    NSData *encryptedUserData = [[NSData alloc] initWithBytes:encryptedUserInfo length:strlen((const char*)encryptedUserInfo)];
    free(encryptedUserInfo);
    
    return encryptedUserData;
}


+ (NSData *)rsaEncryptData:(NSData *)data
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"privatekey" ofType:@"pem"];
    NSAssert(path != nil, @"The PEM file path does not exist!");
    uint8_t *encryptedBytes = NULL;
    NSData *encryptedData = nil;
    
    char dataToEncrypt[data.length];
    [data getBytes:dataToEncrypt length:data.length];
    char padded [128];
    
    size_t backpad = 0;
    for (int i = 127; i >= 0; i--) {
        if (backpad < data.length) {
            padded[i]= dataToEncrypt[data.length - backpad - 1];
            backpad++;
        }
        else {
            padded[i]= '\0';
        }
    }
        
    const char *private_key_file_name = [path cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE *fp = fopen(private_key_file_name, "r");
    RSA *rsa = RSA_new();
        
    if (PEM_read_RSAPrivateKey(fp, &rsa, 0, "Cr*C6eneVeFR") ==  NULL) {
        NSLog(@"FSPPlatformAuthenticator: FAILED TO READ PRIVATE KEY FILE.");
        return nil;
    }
    
    size_t encryptedBytesSize = RSA_size(rsa);
    
    // malloc a buffer to hold signature
    encryptedBytes = malloc(encryptedBytesSize * sizeof(uint8_t));
    memset((void *)encryptedBytes, 0x0, encryptedBytesSize);
    fclose(fp);
    
    int result = RSA_private_encrypt(128, (const unsigned char*)padded, encryptedBytes, rsa,RSA_NO_PADDING);
    if (result < 0) {
        NSLog(@"FSPPlatformAuthenticator: RSA ENCRYPTION ERROR");
        free(encryptedBytes);
        return nil;
    }
    
    encryptedData = [NSData dataWithBytes:(const void *)encryptedBytes
                                   length:encryptedBytesSize];
    free(encryptedBytes);
    return encryptedData;
}

@end
