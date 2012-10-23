//
//  FSPSlidingAdView.h
//  FoxSports
//
//  Created by Chase Latta on 3/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPAdManager.h"

@interface FSPSlidingAdView : UIView<FSPAdViewDelegate>

@property (nonatomic, strong) UIView *ad;
@property (nonatomic, strong) UIButton *dismissButton;

@end
