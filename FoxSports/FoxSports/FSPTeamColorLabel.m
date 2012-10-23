//
//  FSPTeamColorLabel.m
//  FoxSports
//
//  Created by Jason Whitford on 2/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamColorLabel.h"
#import "UIFont+FSPExtensions.h"

static CGGradientRef overlayGradient()
{
    static CGGradientRef overlayGradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size_t numLocations = 2;
        CGFloat locations[] = { 0.0f, 1.0f };
        CGFloat components[] = { 0.0f, 0.6f,  // start color
            0.0f, 0.0f }; // end color
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        overlayGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        
        CGColorSpaceRelease(colorSpace);
    });
    return overlayGradient;
}

static CGGradientRef flareLinearGradient()
{
    static CGGradientRef flareLinearGradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size_t numLocations = 3;
        CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
        CGFloat components[] = { 0.0f, 0.0f,    // start color
            1.0f, 1.0f,     // middle color
            0.0f, 0.0f};    // end color
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        flareLinearGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        
        CGColorSpaceRelease(colorSpace);
    });
    return flareLinearGradient;
}

static CGGradientRef flareRadialGradient()
{
    static CGGradientRef flareRadialGradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size_t numLocations = 2;
        CGFloat locations[] = { 0.0f, 1.0f };
        CGFloat components[] = { 1.0f, 0.8f,     // start color
            1.0f, 0.0f};    // end color
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        flareRadialGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        
        CGColorSpaceRelease(colorSpace);
    });
    return flareRadialGradient;
}


@implementation FSPTeamColorLabel

@synthesize teamColor = _teamColor;

- (void)setTeamColor:(UIColor *)teamColor
{
    if (_teamColor != teamColor) {
        _teamColor = teamColor;
        [self setNeedsDisplay];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = NO;
        self.font = [UIFont fontWithName:FSPUScoreRGHFontName size:14];
    }
    return self;
}

- (void)drawRect:(CGRect)aRect
{
    CGRect rect = CGRectInset(aRect, 0, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    // build clip path
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3];
    CGContextAddPath(context, roundedRect.CGPath);
    CGContextClip(context);
    
    // fill with team color
    CGContextSetFillColorWithColor(context, self.teamColor.CGColor);
    CGContextFillRect(context, rect);
    
    // draw linear gradient from bottom
    CGPoint startPoint = CGPointMake(0.0f, rect.size.height + (aRect.size.height - rect.size.height)/2);
    CGPoint endPoint = CGPointMake(0.0f, 0.0f + (aRect.size.height - rect.size.height)/2);
    CGContextDrawLinearGradient(context, overlayGradient(), startPoint, endPoint, 0);
    
    // Stroke the border
    [[UIColor colorWithWhite:0.0 alpha:1.0] set];
    [roundedRect setLineWidth:2.0];
    [roundedRect stroke];
    
    
    CGContextRestoreGState(context);
    
    
    /*
     
    // REMOVED OLD FLARE CODE
     
    CGContextSaveGState(context);

    //remove rect. stuff for full stuff
    CGContextClipToRect(context, CGRectMake(0, (aRect.size.height - rect.size.height)/2, rect.size.width, 1));
    
    startPoint = CGPointMake(0.0f, (aRect.size.height - rect.size.height)/2);
    endPoint = CGPointMake(rect.size.width, (aRect.size.height - rect.size.height)/2);
    CGContextDrawLinearGradient(context,flareLinearGradient(), startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    
    CGRect ovalRect = CGRectMake(rect.size.width/2 - 6, (aRect.size.height - rect.size.height)/2 - 1, 12, 4);
    UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    [oval addClip];

    startPoint = CGPointMake(rect.size.width/2.0f, (aRect.size.height - rect.size.height)/2 );
    endPoint = CGPointMake(rect.size.width/2.0f, (aRect.size.height - rect.size.height)/2 );
    CGFloat startRadius = 0.0f;
    CGFloat endRadius = 4.0f;

    CGContextDrawRadialGradient(context, flareRadialGradient(), startPoint, startRadius, endPoint, endRadius, 0);
    
    
    CGContextRestoreGState(context);
    */
    
    [super drawRect:rect];
}


@end
