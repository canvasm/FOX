//
//  FSPChannelCellSelectedBackgroundView.m
//  FoxSports
//
//  Created by Jason Whitford on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPChannelCellSelectedBackgroundView.h"

static CGGradientRef
FSPChannelCellSelectedBackgroundGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        size_t numLocations = 2;
        CGFloat locations[2] = { 0.0f, 1.0f };
        CGFloat components[8] = { 25.0/255.0f, 122.0/255.0f, 205.0/255.0f, 1.0f,  // start color
            10.0f/255.0f, 50.0f/255.0f, 120.0f/255.0f, 1.0f }; // end color
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

@interface FSPChannelCellSelectedBackgroundView ()
@property (nonatomic, strong) UIImageView *topGlow;
@property (nonatomic, strong) UIImageView *bottomGlow;
@end

@implementation FSPChannelCellSelectedBackgroundView

@synthesize topGlow, bottomGlow;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *top = [UIImage imageNamed:@"selected-top-flare"];
        self.topGlow = [[UIImageView alloc] initWithImage:top];
        [self addSubview:self.topGlow];
    }
    return self;
}

- (void)layoutSubviews
{
    self.topGlow.frame = CGRectMake(0.0f, 0.0f, self.superview.bounds.size.width, topGlow.frame.size.height);
    self.bottomGlow.frame = CGRectMake(0.0f, self.frame.size.height - bottomGlow.frame.size.height, bottomGlow.frame.size.width, bottomGlow.frame.size.height);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0.0f, rect.size.height);
    
    CGContextSaveGState(context);
    
    CGContextDrawLinearGradient(context, FSPChannelCellSelectedBackgroundGradient(), startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
}


@end
