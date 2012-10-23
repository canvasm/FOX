//
//  FSPBaseballChipIndicatorView.m
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBaseballChipIndicatorView.h"
#import "UIFont+FSPExtensions.h"
#import <CoreText/CoreText.h>

@interface FSPBaseballChipIndicatorView ()
@property (nonatomic, strong) UIColor *baseFillColor;
@property (nonatomic, strong) UIColor *baseStrokeColor;
@property (nonatomic, strong) UIColor *outFillColor;
@property (nonatomic, strong) UIColor *notOutFillColor;
- (void)drawBases;
- (void)drawOuts;
- (void)setupColors;

- (void)colorBase:(FSPBaseRunners)runner path:(UIBezierPath *)path;
@end

@implementation FSPBaseballChipIndicatorView
@synthesize baseRunnersMask = _baseRunnersMask;
@synthesize outs = _outs;
@synthesize baseFillColor = _baseFillColor;
@synthesize baseStrokeColor = _baseStrokeColor;
@synthesize outFillColor = _outFillColor;
@synthesize notOutFillColor = _notOutFillColor;
@synthesize selected = _selected;

- (void)setupColors;
{
    if (self.selected) {
        self.baseFillColor = [UIColor whiteColor];
        self.baseStrokeColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        self.notOutFillColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        self.outFillColor = [UIColor whiteColor];
    } else {
        self.baseFillColor = [UIColor colorWithRed:43/255.0 green:87/255.0 blue:134/255.0 alpha:1.0];
        self.baseStrokeColor = [UIColor colorWithRed:182/255.0 green:182/255.0 blue:183/255.0 alpha:1.0];
        self.notOutFillColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0];
        self.outFillColor = [UIColor colorWithRed:43/255.0 green:87/255.0 blue:134/255.0 alpha:1.0];
    }
    
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

- (void)setSelected:(BOOL)selected;
{
    if (_selected != selected) {
        _selected = selected;
        [self setupColors];
        [self setNeedsDisplay];
    }
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

- (NSString *)runnersString;
{
    NSString *string;
    switch (self.baseRunnersMask) {
        case 0:
            string = @"No Runners on base";
            break;
        case FSPFirstBaseRunner:
            string = @"Runner on first";
            break;
        case FSPSecondBaseRunner:
            string = @"Runner on second";
            break;
        case FSPThirdBaseRunner:
            string = @"Runner on third";
            break;
        case FSPFirstBaseRunner | FSPSecondBaseRunner:
            string = @"Runners on first and second";
            break;
        case FSPFirstBaseRunner | FSPThirdBaseRunner:
            string = @"Runners on first and third";
            break;
        case FSPFirstBaseRunner | FSPSecondBaseRunner | FSPThirdBaseRunner:
            string = @"Bases are loaded";
            break;
        case FSPSecondBaseRunner | FSPThirdBaseRunner:
            string = @"Runners on second and third";
            break;
        default:
            break;
    }
    return string;
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
    
    UIBezierPath *basePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 13, 13)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [[UIColor colorWithRed:178/255.0 green:214/255.0 blue:255/255.0 alpha:1.0] set];
    
    // Draw third base
    CGContextTranslateCTM(ctx, width / 4.0, height / 4.0);
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, M_PI_4);
    [self colorBase:FSPThirdBaseRunner path:basePath];
    CGContextRestoreGState(ctx);
    
    // Draw second base
    CGContextTranslateCTM(ctx, width / 4.0, - height / 4.0);
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, M_PI_4);
    [self colorBase:FSPSecondBaseRunner path:basePath];
    CGContextRestoreGState(ctx);
    
    // Draw first base
    CGContextTranslateCTM(ctx, width / 4.0,  height / 4.0);
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
    CGFloat radius = 6;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
        
    CGContextTranslateCTM(ctx, width / 4.0 - (radius/2), 3.0 * height / 4.0);
    for (NSUInteger outCount = 1; outCount <= 3; outCount++) {
        if (outCount <= self.outs) {
            [self.outFillColor set];
        } else {
            [self.notOutFillColor set];
        }
        [circle fill];
        CGContextTranslateCTM(ctx, width / 4.0, 0);
    }
    
    CGContextRestoreGState(ctx);
}

@end
