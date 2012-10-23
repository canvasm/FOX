//
//  FSPImageFetcher.m
//  FoxSports
//
//  Created by Ed McKenzie on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPImageFetcher.h"
#import "FSPCoreDataManager.h"
#import "NSHTTPURLResponse+FSPExtensions.h"
#import "FSPPurgeableImage.h"

static NSTimeInterval FSPMinimumPhotoCacheInterval = 10800; // 3 hours

@implementation FSPImageFetcher {
    // A processing queue to offload some of the non-UIKit work from the main thread.
    NSOperationQueue *fetcherQueue;
    
    // A map of URLs to sets of observers currently waiting on image data.
    // No need to lock this, as the only thread that accesses this is the master
    // context thread.
    NSMutableDictionary *imageCallbackListeners;
}

+ (FSPImageFetcher *)sharedFetcher {
    static FSPImageFetcher *sharedFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFetcher = FSPImageFetcher.new;
    });
    return sharedFetcher;
}

- (id)init {
    if ((self = [super init])) {
        fetcherQueue = NSOperationQueue.new;
        fetcherQueue.maxConcurrentOperationCount = 1;
        imageCallbackListeners = NSMutableDictionary.new;
    }
    return self;
}

- (NSArray *)removeExpiredImages:(NSArray *)images inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *validImages = images.mutableCopy;
    NSArray *expiredImages = [images filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        FSPPurgeableImage *image = (FSPPurgeableImage *)evaluatedObject;
        return NO; //!image.isExpired;
    }]];
    if (expiredImages.count) {
        [validImages removeObjectsInArray:expiredImages];
        for (FSPPurgeableImage *image in expiredImages) {
            FSPLogFetching(@"purging image %@ from cache", image.url);
            if ([image isInserted]) {
                [context deleteObject:image];
            }
        }
        NSError *error;
        if (![context save:&error]) {
            FSPLogFetching(@"error deleting expired images: %@", error.description);
        }
    }
    return validImages;
}

- (FSPPurgeableImage *)cachedImageForURL:(NSURL *)url inManagedObjectContext:(NSManagedObjectContext *)context {
	if (!url) return nil;
	
    NSError *error;
    FSPPurgeableImage *purgeableImage = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(FSPPurgeableImage.class)];
    NSString *cacheKey = url.absoluteString;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@" argumentArray:@[cacheKey]];
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    results = [self removeExpiredImages:results inManagedObjectContext:context];
    if (results && results.count) {
        FSPLogFetching(@"found cached image for %@", url);
        purgeableImage = [results objectAtIndex:0];
    } else {
        FSPLogFetching(@"cache miss for image %@", url);
    }
    return purgeableImage;
}

- (void)postImageCallback:(void (^)(UIImage *image))callback forURL:(NSURL*)url withImageData:(NSData *)imageData {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithData:imageData];
        if (imageData && !image) {
            FSPLogFetching(@"failed to create UIImage from data");
            [self invalidateURL:url];
        }
        if (callback) {
            callback(image);
        }
    });
}

- (void)saveFetchedImageData:(NSData *)imageData fromResponse:(NSHTTPURLResponse *)response
      inManagedObjectContext:(NSManagedObjectContext *)context {
    [context performBlock:^{
        FSPPurgeableImage *purgeableImage = nil;
        NSString *cacheKey = response.URL.absoluteString;
        NSError *error;
        
        NSParameterAssert(imageData);
        FSPLogFetching(@"saving image %@ to cache", cacheKey);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(FSPPurgeableImage.class)];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@" argumentArray:@[cacheKey]];
        
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        if (results.count == 0) {
            purgeableImage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(FSPPurgeableImage.class)
                                                           inManagedObjectContext:context];
        } else if (results.count == 1) {
            purgeableImage = [results objectAtIndex:0];
        } else {
            NSAssert(FALSE, @"found too many images in the store for url %@!", cacheKey);
        }
        
        purgeableImage.backingData = imageData;
        purgeableImage.url = response.URL.absoluteString;
        NSTimeInterval interval = [response fsp_cacheDuration];
        purgeableImage.expirationDate = [NSDate dateWithTimeIntervalSinceNow:(interval <= 5.0) ? FSPMinimumPhotoCacheInterval : interval];
        FSPLogFetching(@"cache expiration date is %@ (now = %@)", purgeableImage.expirationDate, NSDate.date);
        
        if (![context save:&error]) {
            FSPLogFetching(@"failed to save image to cache for %@", cacheKey);
        }
    }];
}

- (void)doFetchImageForURL:(NSURL *)url withContext:(NSManagedObjectContext *)context listeners:(NSSet *)listeners {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:fetcherQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [context performBlock:^{
                                   if (data) {
                                       [self saveFetchedImageData:data fromResponse:(NSHTTPURLResponse *)response
                                           inManagedObjectContext:context];
                                   } else {
                                       FSPLogFetching(@"Error fetching image: %@", error.description);
                                   }
                                   for (id opaqueCallback in listeners) {
                                       void (^pendingCallback)(UIImage *) = opaqueCallback;
                                       [self postImageCallback:pendingCallback forURL:url withImageData:data];
                                   }
                                   [imageCallbackListeners removeObjectForKey:url];
                               }];
                           }];
}

- (void)fetchImageFromStoreForURL:(NSURL *)url withCallback:(void (^)(UIImage *image))callback {
    if (callback && !url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil);
        });
        return;
    }

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = FSPCoreDataManager.sharedManager.masterContext;
    [context performBlock:^{
        __block FSPPurgeableImage *cachedImage = [self cachedImageForURL:url inManagedObjectContext:context];
        if (cachedImage) {
            FSPLogFetching(@"image found on first cache check");
            [self postImageCallback:callback forURL:url withImageData:cachedImage.backingData];
        } else {
            FSPLogFetching(@"cache miss on first cache check");
            NSMutableSet *callbacksForThisURL = [imageCallbackListeners objectForKey:url];
            if (!callbacksForThisURL) {
                FSPLogFetching(@"no callbacks pending for url %@", url);
                callbacksForThisURL = [NSMutableSet setWithObject:callback];
                [imageCallbackListeners setObject:callbacksForThisURL forKey:url];
                FSPLogFetching(@"added first callback");

                [context performBlock:^{
                    // Check again for the cached image - if there were multiple requests for this image, we only want to make a
                    // network request for the first-queued fetch
                    cachedImage = [self cachedImageForURL:url inManagedObjectContext:context];
                    if (cachedImage) {
                        FSPLogFetching(@"found image on second cache check");
                        [self postImageCallback:callback forURL:url withImageData:cachedImage.backingData];
                    } else {
                        FSPLogFetching(@"cache miss on second attempt for %@", url);
                        [self doFetchImageForURL:url withContext:context listeners:callbacksForThisURL];
                    }
                }];
            } else {
                // There's already a pending request for this image; add this callback to the queue
                [callbacksForThisURL addObject:callback];
                FSPLogFetching(@"adding new callback for %@ (%d total)", url, callbacksForThisURL.count);
            }
        }
    }];
}

- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *image))callback {
    NSParameterAssert(dispatch_get_current_queue() == dispatch_get_main_queue());
    
    static NSMutableDictionary *cachedImages = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedImages = NSMutableDictionary.new;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          FSPLogFetching(@"received memory warning - purging memory image cache");
                                                          [cachedImages removeAllObjects];
                                                      }];
    });
    
    UIImage *image = [cachedImages objectForKey:url.absoluteString];
    if (image) {
        callback(image);
    } else {
        [self fetchImageFromStoreForURL:url withCallback:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [cachedImages setObject:image forKey:url.absoluteString];
                }
                callback(image);
            });
        }];
    }
}

- (void)invalidateURL:(NSURL *)url {
    if (url) {
        NSString *cacheKey = url.absoluteString;
        NSParameterAssert(cacheKey);
        NSManagedObjectContext *context = FSPCoreDataManager.sharedManager.masterContext;
        [context performBlock:^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(FSPPurgeableImage.class)];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@" argumentArray:@[cacheKey]];
            NSError *error;
            NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
            if (results && results.count) {
                for (FSPPurgeableImage *image in results) {
                    FSPLogFetching(@"invalidating cache entry for %@", url);
                    if ([image isInserted]) {
                        [context deleteObject:image];
                    }
                }
            }
            [imageCallbackListeners removeObjectForKey:url];
        }];
    }
}

@end
