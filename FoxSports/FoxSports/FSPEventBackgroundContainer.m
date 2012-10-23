//
//  FSPEventBackgroundContainer.m
//  FoxSports
//
//  Created by Matthew Fay on 3/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventBackgroundContainer.h"

@interface FSPEventBackgroundContainer()
@property (nonatomic) CGGradientRef gradient;
@end

@implementation FSPEventBackgroundContainer

@synthesize gradient = _gradient;

- (CGGradientRef)gradient
{
    if (_gradient)
        return _gradient;
    
    size_t numLocations = 3;
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
    CGFloat components[] = { 0.0f, 0.6f,    // start color
        0.0f, 0.0f,     // middle color
        0.0f, 0.6f};    // end color
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    _gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
    
    CGColorSpaceRelease(colorSpace);
    
    return _gradient;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    }
    return self;
}

- (void)dealloc
{
    if (_gradient)
        CGGradientRelease(_gradient);
}

- (void)drawRect:(CGRect)rect
{
    //fill with blue color
    [[UIColor colorWithRed:18/255.0f green:85/255.0f blue:173/255.0f alpha:1.0f] set];
    UIRectFillUsingBlendMode(self.bounds, kCGBlendModeMultiply);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // draw linear gradient across
    CGPoint startPoint = CGPointMake(0.0f, 0.0f);
    CGPoint endPoint = CGPointMake(rect.size.width, 0.0f);
    CGContextDrawLinearGradient(ctx, self.gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(ctx);
}


@end
