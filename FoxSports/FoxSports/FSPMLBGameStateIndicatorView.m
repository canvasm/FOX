//
//  FSPMLBGameStateIndicatorView.m
//  FoxSports
//
//  Created by greay on 6/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameStateIndicatorView.h"
#import "FSPBaseballGame.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPPitchEvent.h"
#import "UIFont+FSPExtensions.h"
#import <CoreText/CoreText.h>

@interface FSPMLBGameStateIndicatorView ()
@property (nonatomic, strong) UIColor *baseFillColor;
@property (nonatomic, strong) UIColor *baseStrokeColor;
@property (nonatomic, strong) UIColor *outFillColor;
@property (nonatomic, strong) UIColor *notOutFillColor;
- (void)drawBases;
- (void)drawOuts;
- (void)setupColors;

- (void)colorBase:(FSPBaseRunners)runner path:(UIBezierPath *)path;
@end

@implementation FSPMLBGameStateIndicatorView
@synthesize baseRunnersMask = _baseRunnersMask;
@synthesize outs = _outs;
@synthesize balls = _balls;
@synthesize strikes = _strikes;
@synthesize baseFillColor = _baseFillColor;
@synthesize baseStrokeColor = _baseStrokeColor;
@synthesize outFillColor = _outFillColor;
@synthesize notOutFillColor = _notOutFillColor;

- (void)setupColors;
{
	self.baseStrokeColor = [UIColor colorWithRed:36/255.0 green:126/255.0 blue:251/255.0 alpha:1.0];
	self.baseFillColor = self.baseStrokeColor;
	self.notOutFillColor = [UIColor colorWithRed:61/255.0 green:104/255.0 blue:173/255.0 alpha:1.0];
	self.outFillColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
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

- (void)populateWithGame:(FSPBaseballGame *)game
{
	self.baseRunnersMask = [[game baseRunners] unsignedIntegerValue];
	self.outs = [[game outs] unsignedIntegerValue];
    
    
    NSUInteger strikes = 0;
    NSUInteger balls = 0;
    FSPGamePlayByPlayItem *pitchingObjects = [game.playByPlayItems lastObject];
    for (FSPPitchEvent *pitch in pitchingObjects.pitches) {
        if ([pitch.result isEqualToString:@"B"])
            balls++;
        else if (![pitch.result isEqualToString:@"H"])
            strikes++;
    }
    self.strikes = strikes;
    self.balls = balls;
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

- (void)setBalls:(NSUInteger)balls;
{
    if (_balls != balls) {
        if (balls > 3)
            balls = 3;
        _balls = balls;
        [self setNeedsDisplay];
    }
}

- (void)setStrikes:(NSUInteger)strikes
{
    if (_strikes != strikes) {
        if (strikes > 3)
            strikes = 3;
        _strikes = strikes;
        [self setNeedsDisplay];
    }
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    if (self.baseRunnersMask != -1) {
        [self drawBases];
        
        [self drawOuts];
        [self drawBalls];
        [self drawStrikes];
    }
}


#pragma mark - Utility methods

- (CGSize)sizeOfString:(NSString *)string
{
    int charCount = [string length];
    CGGlyph glyphs[charCount];
    CGRect rects[charCount];
	
    NSString *fontName = FSPClearFOXGothicMediumFontName;
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, 11, &CGAffineTransformIdentity);
	
    CTFontGetGlyphsForCharacters(font, (const unichar*)[string cStringUsingEncoding:NSUnicodeStringEncoding], glyphs, charCount);
    CTFontGetBoundingRectsForGlyphs(font, kCTFontDefaultOrientation, glyphs, rects, charCount);
    CFRelease(font);
	
    int totalwidth = 0, maxheight = 0;
    for (int i=0; i < charCount; i++)
    {
        totalwidth += rects[i].size.width;
        maxheight = maxheight < rects[i].size.height ? rects[i].size.height : maxheight;
    }
	
    return CGSizeMake(totalwidth, maxheight);
}

- (void)drawBases;
{
    CGFloat width = CGRectGetWidth(self.bounds) / 2.0;
    CGFloat height = CGRectGetHeight(self.bounds) / 2.0;
    
    UIBezierPath *basePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 13, 13)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [[UIColor colorWithRed:178/255.0 green:214/255.0 blue:255/255.0 alpha:1.0] set];
    
    // Draw third base
    CGContextTranslateCTM(ctx, width / 4.0 * 3.0, height / 4.0);
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


- (void)drawDots:(NSUInteger)dots filled:(NSUInteger)filledDots label:(NSString *)label atPosition:(CGPoint)point
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    CGContextSaveGState(ctx);
    [[UIColor whiteColor] set];
	
    CGContextTranslateCTM(ctx, point.x, point.y);
    CGContextScaleCTM(ctx, 1.0, -1.0);
	
    CGContextSelectFont(ctx, "ClearFOXGothic-Heavy", 14, kCGEncodingMacRoman);
    const char *string = [label cStringUsingEncoding:NSMacOSRomanStringEncoding];
    CGContextShowTextAtPoint(ctx, 0, 0, string, label.length);
	
    CGContextTranslateCTM(ctx, 20.0, 0);
	
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 2, 6, 6)];
    for (NSUInteger i = 1; i <= dots; i++) {
        if (i <= filledDots) {
			[self.outFillColor set];
		} else {
			[self.notOutFillColor set];
		}
		[circle fill];
        CGContextTranslateCTM(ctx, 16.0, 0);
    }
	
    CGContextRestoreGState(ctx);
}

- (void)drawOuts;
{
    [self drawDots:3 filled:self.outs label:@"O" atPosition:CGPointMake((self.bounds.size.width - 80.0) / 2, self.bounds.size.height / 2.0 + 40.0)];
}

- (void)drawStrikes;
{
    [self drawDots:3 filled:self.strikes label:@"S" atPosition:CGPointMake((self.bounds.size.width - 80.0) / 2, self.bounds.size.height / 2.0 + 22.0)];
}

- (void)drawBalls;
{
    [self drawDots:4 filled:self.balls label:@"B" atPosition:CGPointMake((self.bounds.size.width - 80.0) / 2, self.bounds.size.height / 2.0 + 4.0)];
}


@end
