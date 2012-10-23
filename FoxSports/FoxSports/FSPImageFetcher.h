//
//  FSPImageFetcher.h
//  FoxSports
//
//  Created by Ed McKenzie on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPImageFetcher : NSObject

+ (FSPImageFetcher *)sharedFetcher;

- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *image))callback;

- (void)invalidateURL:(NSURL *)url;

@end
