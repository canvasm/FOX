//
//  FSPPatternedToolbar.m
//  FoxSports
//
//  Created by greay on 5/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPatternedToolbar.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPPatternedToolbar ()
@property (nonatomic, strong, readwrite) UIToolbar *toolbar;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *flare;
@property (nonatomic, readonly) CGGradientRef gradient;
@end


@implementation FSPPatternedToolbar

@synthesize toolbar, titleLabel;
@synthesize flare;
@synthesize gradient = _gradient;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.autoresizesSubviews = YES;
		
		self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
		self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[[UIToolbar appearance] setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
		[self addSubview:self.toolbar];

		self.titleLabel = [[UILabel alloc] initWithFrame:frame];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		self.titleLabel.textColor = [UIColor colorWithRed:0.77 green:0.95 blue:1.0 alpha:1.0];
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		self.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15];
		[self addSubview:self.titleLabel];
		
		self.flare = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flare_game_header"]];
		self.flare.frame = CGRectMake(frame.origin.x, frame.origin.y - 5.0, frame.size.width, frame.size.height);
		self.flare.contentMode = UIViewContentModeTop | UIViewContentModeScaleAspectFit;
		self.flare.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.flare];
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
	}
    return self;
}

- (void)dealloc
{
    if (_gradient)
        CGGradientRelease(_gradient);
}


- (CGGradientRef)gradient
{
    if (_gradient)
        return _gradient;
    
    size_t numLocations = 3;
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
    CGFloat components[] = { 0.0f, 0.6f,    // start color
        0.0f, 0.0f,     // middle color
        0.0f, 0.6f};    // end color
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    _gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
    
    CGColorSpaceRelease(colorSpace);
    
    return _gradient;
}

- (void)drawRect:(CGRect)rect
{
    //fill with blue color
    [[UIColor colorWithRed:18/255.0f green:85/255.0f blue:173/255.0f alpha:1.0f] set];
    UIRectFillUsingBlendMode(self.bounds, kCGBlendModeMultiply);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // draw linear gradient across
    CGPoint startPoint = CGPointMake(0.0f, 0.0f);
    CGPoint endPoint = CGPointMake(rect.size.width, 0.0f);
    CGContextDrawLinearGradient(ctx, self.gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(ctx);
}

@end
