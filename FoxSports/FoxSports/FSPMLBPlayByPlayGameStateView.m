//
//  FSPMLBPlayByPlayGameStateView.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPlayByPlayGameStateView.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import <CoreText/CoreText.h>

@interface FSPMLBPlayByPlayGameStateView ()
@property (nonatomic, strong) UIColor *baseFillColor;
@property (nonatomic, strong) UIColor *baseStrokeColor;
@property (nonatomic, strong) UIColor *outFillColor;
@property (nonatomic, strong) UIColor *notOutFillColor;
- (void)drawBases;
- (void)drawOuts;
- (void)setupColors;

- (void)colorBase:(FSPBaseRunners)runner path:(UIBezierPath *)path;
@end

@implementation FSPMLBPlayByPlayGameStateView

@synthesize baseRunnersMask = _baseRunnersMask;
@synthesize outs = _outs;
@synthesize baseFillColor = _baseFillColor;
@synthesize baseStrokeColor = _baseStrokeColor;
@synthesize outFillColor = _outFillColor;
@synthesize notOutFillColor = _notOutFillColor;

- (void)setupColors;
{
    self.baseFillColor = [UIColor fsp_colorWithIntegralRed:44 green:149 blue:252 alpha:1.0];
    self.baseStrokeColor = [UIColor fsp_colorWithIntegralRed:44 green:149 blue:252 alpha:1.0]; 
    self.notOutFillColor = [UIColor fsp_colorWithIntegralRed:118 green:182 blue:255 alpha:0.3];
    self.outFillColor = [UIColor fsp_colorWithIntegralRed:118 green:182 blue:255 alpha:1.0];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self setupColors];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self setupColors];
    }
    return self;
}

- (void)setBaseRunnersMask:(NSInteger)baseRunnersMask;
{
    if (_baseRunnersMask != baseRunnersMask) {
        _baseRunnersMask = baseRunnersMask;
        [self setNeedsDisplay];
    }
}

- (void)setOuts:(NSUInteger)outs;
{
    if (_outs != outs) {
        if (outs > 3)
            outs = 3;
        _outs = outs;
        [self setNeedsDisplay];
    }
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    if (self.baseRunnersMask != -1) {
        [self drawBases];
        [self drawOuts];
    }
}


#pragma mark - Utility methods
- (void)drawBases;
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    const CGRect baseSize = CGRectMake(0, 0, 11, 11);
    const CGFloat phoneThirdBaseX = width / 3.0 - 2;
    const CGFloat phoneThirdBaseY = height / 4.0;
    const CGFloat padThirdBaseX = width / 8.0 + width / 2.0 + 6;
    const CGFloat padThirdBaseY = height / 4.0 + 2;
    const CGFloat phoneSecondBaseX = width / 8.0 + 4;
    const CGFloat phoneSecondBaseY = - height / 4.0 + 4.0;
    const CGFloat padSecondBaseX = width / 8.0 - 1;
    const CGFloat padSecondBaseY = - height / 4.0 - 1;
    const CGFloat phoneFirstBaseX = width / 8.0 + 4;
    const CGFloat phoneFirstBaseY = height / 4.0 - 4.0;
    const CGFloat padFirstBaseX = width / 8.0 - 1;
    const CGFloat padFirstBaseY = height / 4.0 + 1;
    
    CGFloat thirdBaseX, thirdBaseY, secondBaseX, secondBaseY, firstBaseX, firstBaseY;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        thirdBaseX = padThirdBaseX;
        thirdBaseY = padThirdBaseY;
        secondBaseX = padSecondBaseX;
        secondBaseY = padSecondBaseY;
        firstBaseX = padFirstBaseX;
        firstBaseY = padFirstBaseY;
    } else {
        thirdBaseX = phoneThirdBaseX;
        thirdBaseY = phoneThirdBaseY;
        secondBaseX = phoneSecondBaseX;
        secondBaseY = phoneSecondBaseY;
        firstBaseX = phoneFirstBaseX;
        firstBaseY = phoneFirstBaseY;
    }
    
    UIBezierPath *basePath = [UIBezierPath bezierPathWithRect:baseSize];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [[UIColor colorWithRed:178/255.0 green:214/255.0 blue:255/255.0 alpha:1.0] set];
    
    // Draw third base
    CGContextTranslateCTM(ctx, thirdBaseX, thirdBaseY);
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, M_PI_4);
    [self colorBase:FSPThirdBaseRunner path:basePath];
    CGContextRestoreGState(ctx);
    
    // Draw second base
    CGContextTranslateCTM(ctx, secondBaseX, secondBaseY);
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, M_PI_4);
    [self colorBase:FSPSecondBaseRunner path:basePath];
    CGContextRestoreGState(ctx);
    
    // Draw first base
    CGContextTranslateCTM(ctx, firstBaseX,  firstBaseY);
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, M_PI_4);
    [self colorBase:FSPFirstBaseRunner path:basePath];
    CGContextRestoreGState(ctx);
    
    CGContextRestoreGState(ctx);
}

- (void)colorBase:(FSPBaseRunners)runner path:(UIBezierPath *)path;
{
    if (runner & self.baseRunnersMask) {
        [self.baseFillColor set];
        [path fill];
    } else {
        [self.baseStrokeColor set];
        [path stroke];
    }
}

- (void)drawOuts;
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    const CGFloat radius = 6;
    const CGFloat phoneOutsX = width / 4.0 - (radius/2) - 3;
    const CGFloat phoneOutsY = height / 2.0 + 8;
    const CGFloat padOutsX = width / 14.0 - (radius/2);
    const CGFloat padOutsY = height / 4.0 + 2;
    const CGFloat phoneSpacingX = width / 3.0 - 3;
    const CGFloat padSpacingX = width / 6.0;
    
    CGFloat outsX, outsY, spacingX;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        outsX = padOutsX;
        outsY = padOutsY;
        spacingX = padSpacingX;
    } else {
        outsX = phoneOutsX;
        outsY = phoneOutsY;
        spacingX = phoneSpacingX;
    }
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
	
    CGContextTranslateCTM(ctx, outsX, outsY);
    for (NSUInteger outCount = 1; outCount <= 3; outCount++) {
        if (outCount <= self.outs) {
            [self.outFillColor set];
        } else {
            [self.notOutFillColor set];
        }
        [circle fill];
        CGContextTranslateCTM(ctx, spacingX, 0);
    }
    
    CGContextRestoreGState(ctx);
}

@end
