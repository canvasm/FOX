//
//  FSPFieldPositionView.m
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFieldPositionView.h"

static inline
CGFloat yardagePositionFromRect(NSUInteger yardage, CGRect rect)
{
    CGFloat width = rect.size.width;
    return  (yardage == 0) ? 0.0 : ((CGFloat)yardage * width) / 100.0;
}

// Gradients
static
CGGradientRef yardageGradient(BOOL isRedzone)
{
    // we have 2 gradients here, one for the selected state and one for not selected;
    static CGGradientRef redZoneGradient = NULL;
    static CGGradientRef regularGradient = NULL;
    CGGradientRef gradient = NULL;
    if (isRedzone) {
        static dispatch_once_t selectedOnce;
        dispatch_once(&selectedOnce, ^{
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGFloat components[] = {162.0/255.0, 0.0, 0.0, 1.0,
                207.0/255.0, 0.0, 0.0, 1.0};
            redZoneGradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
            CGColorSpaceRelease(colorSpace);
        });
        gradient = redZoneGradient;
    } else {
        static dispatch_once_t nonSelectedOnce;
        dispatch_once(&nonSelectedOnce, ^{
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGFloat components[] = {0.0/255.0, 62.0/255.0, 119.0/255.0, 1.0,
                0.0/255.0, 84.0/255.0, 161.0/255.0, 1.0};
            regularGradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
            CGColorSpaceRelease(colorSpace);
        });
        gradient = regularGradient;
    }
    return gradient;
}

static
CGGradientRef selectedBackgroundGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {120.0/255.0, 182.0/255.0, 228.0/255.0, 1.0,
            106.0/255.0, 172.0/255.0, 230.0/255.0, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

static 
CGGradientRef scoringPlayGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {0.0/255.0, 118.0/255.0, 0.0/255.0, 1.0,
            0.0/255.0, 152.0/255.0, 0.0/255.0, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

@interface FSPFieldPositionView () {
    BOOL isInRedZone;
}
@property (nonatomic, readonly) UIBezierPath *roundedRectPath;

- (UIBezierPath *)yardagePath;

- (void)drawScoringPlayWithPath:(UIBezierPath *)path;
- (void)drawBackgroundWithPath:(UIBezierPath *)path;
- (void)drawYardageIndicatorClippedByPath:(UIBezierPath *)clipPath;
- (void)drawQuarterTickMarks;
@end

@implementation FSPFieldPositionView
@synthesize yardagePosition = _yardagePosition;
@synthesize selected = _selected;
@synthesize scoringPlay = _scoringPlay;

- (void)setScoringPlay:(BOOL)scoringPlay;
{
    if (_scoringPlay != scoringPlay) {
        _scoringPlay = scoringPlay;
        [self setNeedsDisplay];
    }
}

- (void)setSelected:(BOOL)selected;
{
    if (_selected != selected) {
        _selected = selected;
        [self setNeedsDisplay];
    }
}

- (void)setYardagePosition:(NSUInteger)yardagePosition;
{
    if (_yardagePosition != yardagePosition) {
        if (yardagePosition > 100)
            yardagePosition = 100;
        
        if (yardagePosition >= 80)
            isInRedZone = YES;
        else {
            isInRedZone = NO;
        }
        
        _yardagePosition = yardagePosition;
        [self setNeedsDisplay];
    }
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark - Paths
- (UIBezierPath *)roundedRectPath;
{
    return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:2.0];
}

- (UIBezierPath *)yardagePath;
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    static CGFloat headLength = 10.0;
    CGRect rect = self.bounds;
    CGFloat yardage = floor(yardagePositionFromRect(self.yardagePosition, rect));
    CGFloat midPointY = CGRectGetMidY(rect);

    [path moveToPoint:rect.origin];
    
    if (yardage < headLength) {
        [path addLineToPoint:CGPointMake(yardage, midPointY)];
    } else {
        [path addLineToPoint:CGPointMake(yardage - headLength, rect.origin.y)];
        [path addLineToPoint:CGPointMake(yardage, midPointY)];
        [path addLineToPoint:CGPointMake(yardage - headLength, CGRectGetMaxY(rect))];
    }
    [path addLineToPoint:CGPointMake(rect.origin.x, CGRectGetMaxY(rect))];
    [path closePath];
    return path;
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *outerPath = self.roundedRectPath;
    if (self.scoringPlay) {
        [self drawScoringPlayWithPath:outerPath];
    } else {
        [self drawBackgroundWithPath:outerPath];
        [self drawYardageIndicatorClippedByPath:outerPath];
        [self drawQuarterTickMarks];
    }
}

- (void)drawScoringPlayWithPath:(UIBezierPath *)path;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [path addClip];
    CGContextDrawLinearGradient(ctx, scoringPlayGradient(), CGPointZero, CGPointMake(CGRectGetMaxX(self.bounds), 0.0), 0);
    
    CGContextRestoreGState(ctx);
}

- (void)drawBackgroundWithPath:(UIBezierPath *)path;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    if (self.selected) {
        [path addClip];
        CGContextDrawLinearGradient(ctx, selectedBackgroundGradient(), CGPointZero, CGPointMake(0.0, CGRectGetMaxY(self.bounds)), 0);
    } else {
        [[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0] set];
        [path fill];
    }
    
    CGContextRestoreGState(ctx);
}

- (void)drawYardageIndicatorClippedByPath:(UIBezierPath *)clipPath;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    UIBezierPath *yardPath = self.yardagePath;
    
    [clipPath addClip];
    [yardPath addClip];
    CGRect pathBounds = yardPath.bounds;
    CGContextDrawLinearGradient(ctx, yardageGradient(isInRedZone), pathBounds.origin, CGPointMake(pathBounds.size.width, 0.0), 0);

    CGContextRestoreGState(ctx);
}

- (void)drawQuarterTickMarks;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    UIColor *dark = [UIColor colorWithWhite:0.0 alpha:0.3];
    UIColor *light = [UIColor colorWithWhite:1.0 alpha:0.3];

    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointZero];
    [line addLineToPoint:CGPointMake(0.0, self.bounds.size.height)];
    
    for (NSUInteger yardage = 25; yardage < 100; yardage += 25) {
        CGFloat tickPosition = floor(yardagePositionFromRect(yardage, self.bounds)) + 0.5;
        CGContextSaveGState(ctx);
        // draw 2 one pixel vertical lines
        
        CGContextTranslateCTM(ctx, tickPosition, 0.0);
        [dark set];
        [line stroke];
        CGContextTranslateCTM(ctx, 1.0, 0.0);
        [light set];
        [line stroke];
        
        CGContextRestoreGState(ctx);
    }

    CGContextRestoreGState(ctx);
}

@end
