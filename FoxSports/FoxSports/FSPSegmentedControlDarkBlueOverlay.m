//
//  FSPSegmentedControlDarkBlueOverlay.m
//  FoxSports
//
//  Created by Matthew Fay on 3/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSegmentedControlDarkBlueOverlay.h"

@interface FSPSegmentedControlDarkBlueOverlay ()
@property (nonatomic) CGGradientRef sideGradient;
@end 

@implementation FSPSegmentedControlDarkBlueOverlay

@synthesize sideGradient = _sideGradient;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.opaque = NO;
	}
	return self;
}

- (void)dealloc;
{
    if (_sideGradient) {
        CGGradientRelease(_sideGradient);
        _sideGradient = NULL;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // draw linear gradient across
    CGPoint startPoint = CGPointMake(0.0f, 0.0f);
    CGPoint endPoint = CGPointMake(rect.size.width, 0.0f);
    CGContextDrawLinearGradient(ctx, self.sideGradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    
}

- (CGGradientRef)sideGradient
{
    if (_sideGradient) {
        return _sideGradient;
    }
    
    size_t numLocations = 3;
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
    CGFloat components[] = { 0.0f, 0.4f,    // start color
        0.0f, 0.0f,     // middle color
        0.0f, 0.4f};    // end color
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    _sideGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
    
    CGColorSpaceRelease(colorSpace);
    
    return _sideGradient;
}

@end
