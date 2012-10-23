//
//  FSPEventDetailBackgroundView.m
//  FoxSports
//
//  Created by Laura Savino on 4/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventDetailBackgroundView.h"

static CGGradientRef eventDetailBackgroundGradient()
{
    static CGGradientRef backGroundGradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        static CGFloat components[] = { 0.0f, 71.0/255.0f, 161.0/255.0f, 1.0f,
            0.0f, 46.0/255.0f, 106.0/255.0f, 1.0f
        };
        static CGFloat locations[] = {0.0f, 1.0f};
        backGroundGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
        CGColorSpaceRelease(colorspace);
    });
    return backGroundGradient;
}


@implementation FSPEventDetailBackgroundView

@synthesize drawsBackground;

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.drawsBackground = YES;
}

- (void)drawRect:(CGRect)rect
{
	if (!self.drawsBackground) return;
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    // draw linear gradient
    CGPoint startPoint = CGPointMake(0.0f, CGRectGetMinY(self.bounds));
    CGPoint endPoint = CGPointMake(0.0f, CGRectGetMaxY(self.bounds));
    CGContextDrawLinearGradient(ctx, eventDetailBackgroundGradient(), startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
}

@end
