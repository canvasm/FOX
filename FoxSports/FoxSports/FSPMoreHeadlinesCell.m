//
//  FSPMoreHeadlinesCell.m
//  FoxSports
//
//  Created by greay on 6/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMoreHeadlinesCell.h"

#import "FSPLabel.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

static CGGradientRef
_FSPMoreChipBackgroundGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        const CGFloat components[] = {
            221.0/255.0, 221.0/255.0, 221.0/255.0, 1.0,
			242.0/255.0, 242.0/255.0, 242.0/255.0, 1.0
		};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}


@implementation FSPMoreHeadlinesCell

@synthesize moreLabel;

- (void)awakeFromNib
{
	self.moreLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16];
	self.moreLabel.highlightedTextColor = [UIColor whiteColor];
	self.moreLabel.textColor = [UIColor colorWithRed:0.24 green:0.39 blue:0.54 alpha:1.0];
	self.moreLabel.backgroundColor = [UIColor clearColor];
	self.moreLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
	self.moreLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
}


- (void)drawRect:(CGRect)rect;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGGradientRef gradient = _FSPMoreChipBackgroundGradient();
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);
	
	CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextAddLineToPoint(ctx, self.bounds.size.width, 0);
	CGContextMoveToPoint(ctx, 0, 1);
	CGContextAddLineToPoint(ctx, self.bounds.size.width, 1);
	CGContextStrokePath(ctx);
	
    CGContextSetRGBStrokeColor(ctx, 196.0/255.0, 196.0/255.0, 196.0/255.0, 1.0);
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height);
    CGContextAddLineToPoint(ctx, self.bounds.size.width,self.bounds.size.height);
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, self.bounds.size.width,self.bounds.size.height - 1);
    CGContextStrokePath(ctx);

    self.moreLabel.shadowColor = self.selected ? [UIColor chipTextShadowSelectedColor] : [UIColor chipTextShadowUnselectedColor];
}

@end
