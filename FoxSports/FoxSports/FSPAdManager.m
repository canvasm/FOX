//
//  FSPAdManager.m
//  FoxSports
//
//  Created by Laura Savino on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//


#import "FSPAdManager.h"
#import <AdManager/FWSDK.h>

static const NSUInteger FSPFreewheelTestNetworkID = 116457;
static const NSTimeInterval FSPFreewheelAdRequestTimeout = 20;
static NSString *FSPFreewheelTestServerURL = @"http://1c6e9.v.fwmrm.net/";
static NSString *FSPFreewheelTestProfile = @"116457:FDM_iOS_Test";
static NSString *FSPFreewheelTestVideoID = @"11093961";
static NSString *FSPSiteSection = @"FOXSports_2go_test";

@interface FSPAdManager () {}

/**
 * Associates a retrieved ad's delegate with the ad slot ID. 
 */
@property (nonatomic, strong) NSMutableDictionary *delegatesForSlotIDs;

/**
 * The Freewheel ad manager that this class provides a wrapper for. 
 */
@property (nonatomic, strong) id<FWAdManager> freewheelManager;


/**
 * Holds references to ad contexts
 */
@property (nonatomic, strong) NSMutableArray *contexts;

/**
 * Returns the size associated with the given ad type.
 */
+ (CGSize)sizeForAdType:(FSPImageAdType)adType;

/**
 * Returns a view with the house ad associated with this ad type.
 */
+ (UIView *)houseAdForAdType:(FSPImageAdType)adType;

@end

@implementation FSPAdManager

@synthesize delegatesForSlotIDs = _delegatesForSlotIDs;
@synthesize freewheelManager = _freewheelManager;
@synthesize contexts = _contexts;

#pragma mark Lifecycle Management

+ (FSPAdManager *)sharedManager;
{
    static FSPAdManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSetLogLevel(FW_LOG_LEVEL_QUIET);
        _sharedManager = [[FSPAdManager alloc] init];
    });

    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if(!self) return nil;
    
    self.freewheelManager = newAdManager();
    [self.freewheelManager setNetworkId:FSPFreewheelTestNetworkID];
    [self.freewheelManager setServerUrl:FSPFreewheelTestServerURL]; //Freewheel takes an NSString as a URL parameter.

    self.delegatesForSlotIDs = [[NSMutableDictionary alloc] init];
    self.contexts = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)requestAdViewForAdType:(FSPImageAdType)adType delegate:(id<FSPAdViewDelegate>)delegate acceptHouseAd:(BOOL)acceptHouseAd;
{
    FSPLogVideo(@"requestAdViewForAdType");
    int foo = 5;
    NSString *slotTempID = [NSString stringWithFormat: @"slot-temp-id-%p", &foo];

    id<FWContext> adContext = [self.freewheelManager newContext];
    [self.contexts addObject:adContext]; //This increases the retain count on the context, so we can reference it when we receive the notification.

    FSPLogVideo(@"requested slot ID %@", slotTempID);
    [self.delegatesForSlotIDs setObject:delegate forKey:slotTempID];

    __block FSPAdManager *blockSelf = self;
    //Register for notification for the completion of the context's request.
    [[NSNotificationCenter defaultCenter] addObserverForName:FW_NOTIFICATION_REQUEST_COMPLETE object:adContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        id<FWContext> returnedContext = [note object];
        NSArray *nonTemporalSlots = [returnedContext siteSectionNonTemporalSlots];
        FSPLogVideo(@"returned non temporal slots = %@", nonTemporalSlots);
        FSPLogVideo(@"returned temporal slots = %@", [returnedContext temporalSlots]);
        for (id<FWSlot> fwSlot in nonTemporalSlots)
        {
            NSString *slotID = [fwSlot customId];
            UIView *ad = [fwSlot slotBase];
            [fwSlot play];
            id<FSPAdViewDelegate> delegate = [self.delegatesForSlotIDs objectForKey:slotID];

            [delegate adManager:self didReceiveAd:ad];
            
            //Remove references to delegates whose requests have been filled
            [self.delegatesForSlotIDs removeObjectForKey:slotID];
        }

        //For remaining delegates, if they will accept a house ad, send the house ad; otherwise, send 'nil'
        for(NSString *slotID in blockSelf.delegatesForSlotIDs)
        {
            id<FSPAdViewDelegate> delegate = [blockSelf.delegatesForSlotIDs objectForKey:slotID];
            UIView *houseAdView = nil;
            if(acceptHouseAd)
                houseAdView = [FSPAdManager houseAdForAdType:delegate.adType];
            [delegate adManager:self didReceiveAd:houseAdView];
        }
    }];

    [adContext setProfile:FSPFreewheelTestProfile :nil :nil :nil];
    [adContext setSiteSection:FSPSiteSection :0 :FSPFreewheelTestNetworkID :FW_ID_TYPE_CUSTOM :0];

    //According to Freewheel:
            /**
             Due to a network wide restriction in place, for app environments, a video asset must be specified, 
             even for display only cases.
             
             For the case of display only (just banner ads), we'll use a single hard coded video asset.  For 
             testing, we'll use the one Clayton supplied ["11093961"].  This will change once we swap over to Live.
             */
    [adContext setVideoAsset:FSPFreewheelTestVideoID//videoAssetId 
                            :10 //duration
                            :nil //location
                            :FW_VIDEO_ASSET_AUTO_PLAY_TYPE_ATTENDED //autoPlayType
                            :(NSUInteger)&foo //videoPlayRandom
                            :0 //networkId
                            :FW_ID_TYPE_CUSTOM //idType
                            :0 //fallbackId
                            :FW_VIDEO_ASSET_DURATION_TYPE_VARIABLE]; //durationType

    CGSize adSize = [FSPAdManager sizeForAdType:adType];

    //See Freewheel documentation in FWProtocols.h for parameters.
    [adContext addSiteSectionNonTemporalSlot:slotTempID //customId
                                            :nil //adUnit
                                            :adSize.width //width
                                            :adSize.height //height
                                            :nil //slotProfile
                                            :YES //acceptCompanion
                                            :FW_SLOT_OPTION_INITIAL_AD_STAND_ALONE //initialAdOption
                                            :@"text/html_doc_lit_mobile" //acceptPrimaryContentType
                                            :nil //acceptContentType
                                            :nil]; //compatibleDimensions

    [adContext submitRequest:FSPFreewheelAdRequestTimeout];
}

- (void)requestPrerollAdForVideoAssetId:(NSString *)videoAssetId delegate:(id<FSPAdViewDelegate>)delegate
{
    int foo = 6;
    NSString *slotTempID = [NSString stringWithFormat: @"temporal-slot-id-%p", &foo];
    
    id<FWContext> adContext = [self.freewheelManager newContext];
    [self.contexts addObject:adContext]; //This increases the retain count on the context, so we can reference it when we receive the notification.
    
    [adContext setParameter:FW_PARAMETER_COUNTDOWN_TIMER_DISPLAY withValue:@"YES" forLevel:FW_PARAMETER_LEVEL_OVERRIDE];
    [adContext setParameter:FW_PARAMETER_TRANSPARENT_BACKGROUND withValue:@"YES" forLevel:FW_PARAMETER_LEVEL_GLOBAL];
	[adContext setParameter:FW_PARAMETER_IN_APP_VIEW_NAVIGATION_BAR_BACKGROUND_COLOR withValue:@"0xC2CFF1" forLevel:FW_PARAMETER_LEVEL_OVERRIDE];        
	[adContext setParameter:FW_PARAMETER_IN_APP_VIEW_NAVIGATION_BAR_ALPHA withValue:@"0.9" forLevel:FW_PARAMETER_LEVEL_OVERRIDE];
    

    
    FSPLogVideo(@"requested slot ID %@", slotTempID);
    
    //Register for notification for the completion of the context's request.
    [[NSNotificationCenter defaultCenter] addObserverForName:FW_NOTIFICATION_REQUEST_COMPLETE object:adContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        id<FWContext> returnedContext = [note object];
        [delegate adManager:self didReceiveVideoAd:returnedContext];
    }];
    
    [adContext setProfile:FSPFreewheelTestProfile :nil :nil :nil];
    [adContext setSiteSection:FSPSiteSection :0 :FSPFreewheelTestNetworkID :FW_ID_TYPE_CUSTOM :0];
    
    [adContext setRequestMode:FW_REQUEST_MODE_ON_DEMAND];
    [adContext setVideoAsset:FSPFreewheelTestVideoID//videoAssetId         
                            :0 //duration
                            :nil //location
                            :FW_VIDEO_ASSET_AUTO_PLAY_TYPE_ATTENDED //autoPlayType
                            :0 //videoPlayRandom
                            :0 //networkId
                            :FW_ID_TYPE_CUSTOM //idType
                            :0 //fallbackId
                            :FW_VIDEO_ASSET_DURATION_TYPE_VARIABLE]; //durationType
    
    [adContext addTemporalSlot:slotTempID //custom id of the slot
                              :FW_ADUNIT_PREROLL //ad unit
                              :0 //time position
                              :nil //profile name (using default)
                              :0 //sequence of the cuepoint
                              :0 // max duration (using default)
                              :nil // accepted primary content types (using default)
                              :nil // accepted content types (using default)
                              :0]; // min duration (using default)
    
    [adContext submitRequest:FSPFreewheelAdRequestTimeout];
}

+ (CGSize)sizeForAdType:(FSPImageAdType)adType;
{
    CGSize adSize;
    switch(adType)
    {
        case FSPAdTypeEventDetailHeader:
            adSize = CGSizeMake(320.0, 50.0);
            break;
        case FSPAdTypeChip:
            adSize = CGSizeMake(216, 54);
        default:
            break;
    }

    return adSize;
}


+ (UIView *)houseAdForAdType:(FSPImageAdType)adType;
{
    UIImageView *adImageView;
    switch (adType) {
        case FSPAdTypeEventDetailHeader:
            adImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house-ad-sample-event-detail-header"]];
            break;
        case FSPAdTypeChip:
            adImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house-ad-sample-chip"]];
        default:
            break;
    }
    
    return adImageView;
}
@end
