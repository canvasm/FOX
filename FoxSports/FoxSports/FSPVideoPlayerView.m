//
//  FSPVideoView.m
//  FoxSports
//
//  Created by Jason Whitford on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation FSPVideoPlayerView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = @"video player";
    }
    return self;
}

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}


- (void)setPlayer:(AVPlayer *)player
{
	[(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
