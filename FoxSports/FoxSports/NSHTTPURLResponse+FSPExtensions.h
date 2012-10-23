//
//  NSHTTPURLResponse+FSPExtensions.h
//  FoxSports
//
//  Created by Chase Latta on 4/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (FSPExtensions)

/**
 Returns the max-age value specified in the Cache-Control header of the response.
 If the value is not specified 0 is returned.
 */
- (NSTimeInterval)fsp_cacheDuration;

@end
