//
//  FSPVideoDetailViewController.h
//  FoxSports
//
//  Created by greay on 8/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPVideo;

@interface FSPVideoDetailViewController : UIViewController

@property (nonatomic, strong) FSPVideo *video;

- (id)initWithVideo:(FSPVideo *)video;


@end
