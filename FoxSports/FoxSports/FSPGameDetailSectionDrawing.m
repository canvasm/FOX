//
//  FSPGameDetailSectionDrawing.m
//  FoxSports
//
//  Created by Laura Savino on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailSectionDrawing.h"
#import "UIColor+FSPExtensions.h"

void FSPDrawHighlightLine(CGContextRef context, CGPoint segment[2])
{
    CGContextSaveGState(context);
    [[UIColor colorWithWhite:1.0f alpha:0.1f] set];
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeLineSegments(context, segment, 1);
    CGContextRestoreGState(context);
}

void FSPDrawBlackLine(CGContextRef context, CGPoint segment[2])
{
    CGContextSaveGState(context);
    [[UIColor colorWithWhite:0.0f alpha:0.0f] set];
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeLineSegments(context, segment, 1);
    CGContextRestoreGState(context);
}


void FSPDrawGrayWhiteDividerLine(CGContextRef context, CGRect rect)
{
    CGFloat bottomDividerTopY = CGRectGetMaxY(rect) - 2;
    CGFloat maxX = CGRectGetMaxX(rect);
    
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, bottomDividerTopY, maxX, 1.0f)];
    [[UIColor fsp_colorWithIntegralRed:191 green:191 blue:191 alpha:1.0] set];
    [path fill];
    
    CGContextTranslateCTM(context, 0.0f, 1.0f);
    [[UIColor whiteColor] set];
    [path fill];

    CGContextRestoreGState(context);
}
