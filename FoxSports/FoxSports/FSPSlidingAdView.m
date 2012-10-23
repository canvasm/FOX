//
//  FSPSlidingAdView.m
//  FoxSports
//
//  Created by Chase Latta on 3/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSlidingAdView.h"

@interface FSPSlidingAdView ()

- (void)commonInit;
@property (nonatomic, assign) CGRect adFrame;

@end

@implementation FSPSlidingAdView
@synthesize ad = _ad;
@synthesize adFrame = _adFrame;
@synthesize adType = _adType;
@synthesize dismissButton;

- (void)commonInit;
{
    self.backgroundColor = [UIColor clearColor];
    CGRect adRect = CGRectMake(0, 0, 320.0, 50.0);

    adRect.origin.x = (self.bounds.size.width - adRect.size.width) / 2.0;
    adRect.origin.y = (self.bounds.size.height - adRect.size.height) / 2.0;
    self.adFrame = adRect;
	self.dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.dismissButton.frame = CGRectMake(1, 1, 48, 48);
	[self.dismissButton setTitle:@"X" forState:UIControlStateNormal];
	[self addSubview:self.dismissButton];
}

- (id)init;
{
    return [self initWithFrame:CGRectMake(0, 0, 508.0, 100.0)];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:10.0];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    [[UIColor colorWithWhite:0.15 alpha:1.0] set];
    [ovalPath fill];
    
    [[UIColor colorWithWhite:0.9 alpha:1.0] set];
    [ovalPath setLineWidth:2.0];
    [ovalPath stroke];
    
    CGContextRestoreGState(ctx);
}

#pragma mark Ad delegate

- (void)adManager:(FSPAdManager *)adManager didReceiveAd:(UIView *)adView
{
    adView.frame = self.adFrame;
    self.ad = adView;
    [self addSubview:self.ad];
	[self bringSubviewToFront:self.dismissButton];
}

- (FSPImageAdType) adType
{
    return FSPAdTypeEventDetailHeader;
}

@end
