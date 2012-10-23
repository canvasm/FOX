//
//  NSData+FSPExtensions.h
//  FoxSports
//
//  Created by Joshua Dubey on 8/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

// Derived from http://colloquy.info/project/browser/trunk/NSDataAdditions.h?rev=1576
// Created by khammond on Mon Oct 29 2001.
// Formatted by Timothy Hatcher on Sun Jul 4 2004.
// Copyright (c) 2001 Kyle Hammond. All rights reserved.
// Original development by Dave Winer.
//

/*!
 This is a collection of useful extensions of NSData behaviors.
 */

#import <Foundation/Foundation.h>

@interface NSData (UberCoreExtensions)

/**Returns an NSData object with the Base64-encoded characters in str.
 
 @param string A string of Base64-encoded characters
 */
+ (NSData *) fsp_dataWithBase64String:(NSString *) string;

/**Returns a Base64-encoded string that contains all of the bytes of the
 receiver.
 */
- (NSString *) fsp_base64String;

@end
