//
//  FSPStatIndicatorView.m
//  FoxSports
//
//  Created by Matthew Fay on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStatIndicatorView.h"
#import "FSPTeam.h"
#import "UIColor+FSPExtensions.h"

@implementation FSPStatIndicatorView {
    FSPDirection displayDirection;
    UIColor *displayColor;
    NSNumber *statValue;
    NSUInteger multValue;
}

- (id)initWithTeam:(FSPTeam *)team withNumber:(NSNumber *)stat withDirection:(FSPDirection)direction;
{
    self = [super init];
    if (self) {
        displayDirection = direction;
        displayColor = [UIColor fsp_colorWithHexString:team.colorInHex];
        statValue = stat;
        self.backgroundColor = [UIColor clearColor];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            multValue = 8;
        else
            multValue = 4;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGRect size = CGRectNull;
    if (displayDirection == FSPLeftDirection)
        size = CGRectMake(rect.size.width - (statValue.intValue * multValue), 0, statValue.intValue * multValue, rect.size.height);
    else if (displayDirection == FSPRightDirection)
        size = CGRectMake(0, 0, statValue.intValue * multValue, rect.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:size];
    [displayColor set];
    [path fill];
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, size);
    CGContextClip(context);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat colorComponents[] = { 0.0f, 0.0f, //Gradient top
		0.0f, 0.3f }; //Gradient bottom
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0, CGRectGetMaxY(rect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(context);
    
}

@end
