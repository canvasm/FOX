//
//  FSPVideoPlayerViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPVideoPlayerView;

@interface FSPVideoPlayerViewController : NSObject
{
}
@property(nonatomic, copy) NSString *currentURL;
@property(nonatomic, strong) UIView *view;


- (id)initWithURL:(NSString *)url;


@end
