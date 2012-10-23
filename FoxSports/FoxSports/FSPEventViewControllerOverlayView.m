//
//  FSPEventViewControllerOverlayView.m
//  FoxSports
//
//  Created by Jason Whitford on 2/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventViewControllerOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FSPEventViewControllerOverlayView {
    CGGradientRef overlayGradient;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc;
{
    if (overlayGradient) {
        CGGradientRelease(overlayGradient);
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!overlayGradient) {
        CGColorSpaceRef colorSpace;
        size_t numLocations = 2;
        CGFloat locations[2] = { 0.0f, 1.0f };
        CGFloat components[8] = { 1.0f, 1.0f, 1.0f, 0.2f, // start color
            0.0f, 0.0f, 0.0f, 0.2f }; // end color
        colorSpace = CGColorSpaceCreateDeviceRGB();
        overlayGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        CGColorSpaceRelease(colorSpace);
    }
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0.0f, rect.size.height);
    
    CGContextSaveGState(context);
    
    CGContextDrawLinearGradient(context, overlayGradient, startPoint, endPoint, 0);

    CGContextRestoreGState(context);    
}


@end
