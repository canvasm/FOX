//
//  FSPEventChipsSectionHeader.m
//  FoxSports
//
//  Created by Laura Savino on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventChipsSectionHeader.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import <QuartzCore/QuartzCore.h>

void FSPDrawEventChipSectionDividerLine(CGContextRef context, CGPoint lineStartPoint, CGPoint lineEndPoint, UIColor *lineColor);

@interface FSPEventChipsSectionHeader () {}

@property (nonatomic, strong) IBOutlet UILabel *startDateGroupLabel;

@end

@implementation FSPEventChipsSectionHeader {
    CGGradientRef _backgroundGradient;
}
@synthesize startDateGroupLabel;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(!self) return nil;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    static CGFloat components[] = {37/255.0, 97/255.0, 172/255.0, 1.0,
        17/255.0, 74/255.0, 141/255.0, 1.0};
    _backgroundGradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

- (void)dealloc;
{
    if (_backgroundGradient)
        CGGradientRelease(_backgroundGradient);
}

- (void)awakeFromNib
{
    self.startDateGroupLabel.font = [UIFont fontWithName:FSPUScoreRGKFontName size:14.0];
    self.startDateGroupLabel.shadowColor = [UIColor colorWithRed:46/255.0 green:83/255.0 blue:122/255.0 alpha:.8];
    self.startDateGroupLabel.shadowOffset = CGSizeMake(0.0, 1.0);
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextDrawLinearGradient(ctx, _backgroundGradient, CGPointZero, CGPointMake(0.0, self.bounds.size.height), 0);
    
    CGFloat lineMaxX = CGRectGetMaxX(rect);
    CGFloat lineTopY = CGRectGetMaxY(rect) - 1;
    
    //Draw bottom divider line
    UIBezierPath *bottomLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, lineTopY, lineMaxX, 1.0f)];
    [[UIColor fsp_colorWithIntegralRed:0 green:52 blue:116 alpha:1.0] set];
    [bottomLine fill];
    
    //Draw top divider line
    UIBezierPath *topLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, lineMaxX, 1.0f)];    
    [[UIColor fsp_colorWithIntegralRed:44 green:113 blue:184 alpha:1.0] set];
    [topLine fill];
    
    CGContextRestoreGState(ctx);

}

@end
