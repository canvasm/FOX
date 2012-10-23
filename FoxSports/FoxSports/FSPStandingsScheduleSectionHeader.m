//
//  FSPStandingsScheduleSectionHeader.m
//  FoxSports
//
//  Created by Laura Savino on 5/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsScheduleSectionHeader.h"
#import "FSPGameDetailSectionDrawing.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPStandingsScheduleSectionHeader ()

@property (nonatomic, strong) UILabel *sectionTitleLabel;

@end

@implementation FSPStandingsScheduleSectionHeader

@synthesize sectionTitleLabel = _sectionTitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sectionTitleLabel = [[UILabel alloc] init];
        self.sectionTitleLabel.frame = CGRectMake(10.0, 2.0f, frame.size.width, frame.size.height);
        self.sectionTitleLabel.backgroundColor = [UIColor clearColor];
        self.sectionTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
        self.sectionTitleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.sectionTitleLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGFloat components[] = {
        0.0 / 255.0, 52.0 / 255.0, 116.0 / 255.0, 1.0,
        0.0 / 255.0, 38.0 / 255.0,  86.0 / 255.0, 1.0
    };
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(width, 0.0), 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);

    CGContextRestoreGState(context);
    CGContextSaveGState(context);

    CGContextSetLineWidth(context, 1.0);
    //Draw top & bottom shadows
    [[UIColor fsp_colorWithIntegralRed:0 green:16 blue:35 alpha:1.0] setStroke];
    CGFloat bottomLineY = height;
    CGPoint shadowSegments[] = { CGPointMake(0.0, 0.0), CGPointMake(width, 0.0), CGPointMake(0.0, bottomLineY), CGPointMake(rect.size.width, bottomLineY) };
    CGContextStrokeLineSegments(context, shadowSegments, 4);

    //Draw top highlight
    [[UIColor fsp_colorWithIntegralRed:16 green:73 blue:148 alpha:1.0] setStroke];
    CGPoint highlightSegment[] = { CGPointMake(0.0, 1.0), CGPointMake(width, 1.0) };
    CGContextStrokeLineSegments(context, highlightSegment, 2);
    CGContextRestoreGState(context);
}

@end
