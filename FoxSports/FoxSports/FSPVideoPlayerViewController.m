//
//  FSPVideoPlayerViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FSPVideoPlayerView.h"
#import <CoreMedia/CoreMedia.h>
#import "FSPAnalyticsManager.h"

static void *FSPVideoViewControllerStatusObservationContext = &FSPVideoViewControllerStatusObservationContext;
static void *FSPVideoViewControllerCurrentItemObservationContext = &FSPVideoViewControllerCurrentItemObservationContext;
static void *FSPVideoViewControllerRateObservationContext = &FSPVideoViewControllerRateObservationContext;
static void *FSPVideoViewControllerViewFrameContext = &FSPVideoViewControllerViewFrameContext;

@interface FSPVideoPlayerViewController () 

@property(nonatomic, strong) FSPVideoPlayerView *videoPlayerView;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) UIButton *playBtn;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) id playerObserver;

/*
 Creates a new video player if needed and passes it a new AVPlayerItem
 */
- (void)prepareToPlay;

/*
 Starts player
 */
- (void)play;

/*
 Pauses player
 */
- (void)pause;

/*
 Handles notification when the player plays to end
 */
- (void)videoDidFinishPlaying:(NSNotification *)notification;

/*
 Returns YES if player is playing
 */
- (BOOL)isPlaying;



// Temporary //
- (void)updateButtonTitle;
- (void)togglePlayState;

@end



@implementation FSPVideoPlayerViewController

@synthesize player, currentURL=mCurrentURL, playerItem;
@synthesize view, videoPlayerView, playBtn;
@synthesize playerObserver;

#pragma mark -

- (void)setCurrentURL:(NSString *)currentURL;
{
    if (mCurrentURL != currentURL) {
        mCurrentURL = [currentURL copy];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
          [self prepareToPlay];  
        });
        
    }
}


#pragma mark -

- (id)initWithURL:(NSString *)url;
{
    if (self = [super init]) {
        self.currentURL = url;
        
        self.view = [[UIView alloc] init];
        [self.view addObserver:self forKeyPath:@"frame" 
                       options:NSKeyValueObservingOptionNew 
                       context:FSPVideoViewControllerViewFrameContext];
        self.videoPlayerView = [[FSPVideoPlayerView alloc] init];
        
        // temporary play/pause button
        self.playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.playBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.playBtn addTarget:self action:@selector(togglePlayState) forControlEvents:UIControlEventTouchUpInside];
        [self updateButtonTitle];
        
        [self.view addSubview:self.videoPlayerView];
        [self.view addSubview:self.playBtn];
        
        self.view.accessibilityIdentifier = @"videoPlayer";
    }
    
    return self;
}

- (void)dealloc
{
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:nil];
        self.playerItem = nil;
    }
    
    if (self.player) {
        [self.player removeTimeObserver:self.playerObserver];
        [self.player pause];
        [self.player removeObserver:self forKeyPath:@"currentItem"];
        [self.player removeObserver:self forKeyPath:@"rate"];
        self.player = nil;
        self.playerObserver = nil;
    }
    
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == FSPVideoViewControllerStatusObservationContext) {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
               
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
              //TODO: play automatiically?
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    self.playBtn.enabled = YES;
                    self.playBtn.hidden = NO;
                    [self play];
                });
                
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                
            }
                break;
        }
    }
    else if (context == FSPVideoViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        // was the player item set to null?
        if (newPlayerItem == (id)[NSNull null]) {
            //TODO: disable play button ?
        }
        else
        {
            [self.videoPlayerView setPlayer:self.player]; 
        }
    }
    else if (context == FSPVideoViewControllerRateObservationContext)
    {
        [self updateButtonTitle];
    }
    else if (context == FSPVideoViewControllerViewFrameContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            self.videoPlayerView.frame = newFrame;
            self.playBtn.frame = CGRectMake(200, newFrame.size.height - 60.0f, 60.0f, 40.0f);
        });
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)togglePlayState;
{
    if ([self isPlaying]) [self pause];
    else [self play];
}

- (void)play;
{
    [self.player play];
    
    [[FSPAnalyticsManager sharedManager] trackVideoDidPlayForURL:self.currentURL];
}

- (void)pause;
{
    [self.player pause];
    [[FSPAnalyticsManager sharedManager] trackVideoDidPauseForURL:self.currentURL];
}

- (void)videoDidFinishPlaying:(NSNotification *)notification;
{
    [self updateButtonTitle];
}

- (void)prepareToPlay;
{
    self.playBtn.enabled = NO;
    self.playBtn.hidden = YES;
    
    // remove any observers/notifications for old item
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:nil];
    }
    
    
    
    NSURL *url = [NSURL URLWithString:self.currentURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    // listen for item status
    [self.playerItem addObserver:self 
           forKeyPath:@"status" 
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew 
              context:FSPVideoViewControllerStatusObservationContext];
    
    // listen for play to end notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    // create player if needed
    if (!self.player) {
        
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.player.allowsAirPlayVideo = YES;
        
        // add new observer
        __weak NSString *weakURL = self.currentURL;
        self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
            int currentTime = 0;
            if (time.timescale) {
                currentTime = time.value/time.timescale;
            }
            if (currentTime > 0)
                [[FSPAnalyticsManager sharedManager] trackVideoHeartbeat:[NSString stringWithFormat:@"video_heartbeat %lld", time.value/time.timescale] videoURL:weakURL];
        }];
        
        // listen for changes to the players currentItem
        [self.player addObserver:self 
                      forKeyPath:@"currentItem" 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FSPVideoViewControllerCurrentItemObservationContext];
        
        // listen for changes in player rate
        [self.player addObserver:self 
                      forKeyPath:@"rate" 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FSPVideoViewControllerRateObservationContext];
    }
    
    // replace existing player's currentItem
    if (![self.player.currentItem isEqual:self.playerItem])
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];

}

- (BOOL)isPlaying
{
    return self.player.rate != 0.f;
}

- (void)updateButtonTitle;
{
    NSString *buttonTitle = ([self isPlaying]) ? @"Pause" : @"Play";
    
    [self.playBtn setTitle:buttonTitle forState:UIControlStateNormal];
    self.playBtn.accessibilityLabel = buttonTitle;
}

@end
