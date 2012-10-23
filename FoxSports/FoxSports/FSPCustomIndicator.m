//
//  FSPCustomIndicator.m
//  FoxSports
//
//  Created by Rowan Christmas on 9/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPCustomIndicator.h"

@implementation FSPCustomIndicator

- (id)init;
{
    self = [super initWithImage:[UIImage imageNamed:@"spinner"]];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)startAnimating;
{
    CATransform3D rotationTransform = CATransform3DMakeRotation(1.0f * M_PI/2, 0, 0, 1.0);
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = 0.32f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;

    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating;
{
    [self.layer removeAllAnimations];
}

@end
