//
//  FSPAdManager.h
//  FoxSports
//
//  Created by Laura Savino on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The type of non-video ad, based on location within the app. 
 *
 * The ad manager uses this type to determine what size ad to request, since not
 * every width/height combination will result in a valid ad response. 
 */
typedef enum {
    FSPAdTypeChip = 0,
    FSPAdTypeEventDetailHeader
} FSPImageAdType;


@class FSPAdManager;
@protocol FWContext;
/**
 * The protocol that views containing ads must implement to respond to ad retrieval success & failure.
 */
@protocol FSPAdViewDelegate

@optional
/**
 * The type (indicating size) of ad requested by the caller.
 */
@property (nonatomic, assign) FSPImageAdType adType;

/**
 * Called upon completion of the ad request. If the network request failed but the caller will accept a house ad, the adView
 * contains the house ad; otherwise, the adView will be nil.
 */
- (void)adManager:(FSPAdManager *)adManager didReceiveAd:(UIView *)adView;

/**
 * Called upon completion of a video ad request.
 */
- (void)adManager:(FSPAdManager *)adManager didReceiveVideoAd:(id<FWContext>)adContext;

@end


/**
 * This class provides control for ads within the application.
 *
 * The underlying FreeWheel ad manager interacts frequently with UI elements;
 * according to its documentation, it should be used only on the main queue.
 */

@interface FSPAdManager : NSObject

/**
 * Returns a shared instance of the ad manager. This class should only be
 * accessed via the shared manager.
 */
+ (FSPAdManager *)sharedManager;

/**
 * Requests an ad appropriate for display for the given view and passes the result to the specified delegate.
 * If the request fails and acceptHouseAd is YES, the ad view will contain a house ad of the appropriate size. 
 * If the request fails and acceptHouseAd is NO (or if there is no available house ad), this method will return nil. 
 *
 */
- (void)requestAdViewForAdType:(FSPImageAdType)adType delegate:(id<FSPAdViewDelegate>)delegate acceptHouseAd:(BOOL)acceptHouseAd;

- (void)requestPrerollAdForVideoAssetId:(NSString *)videoAssetId delegate:(id<FSPAdViewDelegate>)delegate;

@end

