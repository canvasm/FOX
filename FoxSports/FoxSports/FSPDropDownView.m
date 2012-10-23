//
//  FSPDropDownView.m
//  FoxSports
//
//  Created by greay on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownView.h"

#import "UIFont+FSPExtensions.h"

@implementation FSPDropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.button = [UIButton buttonWithType:UIButtonTypeCustom];
		self.button.frame = self.bounds;
		self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.button];
		[self.button setImage:[UIImage imageNamed:@"down_arrow_white"] forState:UIControlStateNormal];
		self.button.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16];
		
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(0, -1);
		self.layer.shadowOpacity = 0.6;
		self.layer.shadowRadius = 8.0;
    }
    return self;
}

- (void)setButtonTitle:(NSString *)title
{
	[self.button setTitle:title forState:UIControlStateNormal];
	CGSize size = [[self.button titleForState:UIControlStateNormal] sizeWithFont:self.button.titleLabel.font];
	[self.button setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, -(size.width + self.button.imageView.image.size.width) * 2 - 10)];
	[self.button setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, self.button.imageView.image.size.width)];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSaveGState(context);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[] = { 0.0 / 255.0, 78.0 / 255.0, 168.0 / 255.0, 1.0, //Gradient top
		0.0 / 255.0, 53.0 / 255.0, 119.0 / 255.0, 1.0 }; //Gradient bottom
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0, CGRectGetMaxY(rect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
	
    CGContextRestoreGState(context);
	
	CGContextSetRGBStrokeColor(context, 15.0 / 255.0, 88.0 / 255.0, 168.0 / 255.0, 1.0);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, self.bounds.size.width, 0);
}

@end
