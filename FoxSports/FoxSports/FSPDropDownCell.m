//
//  FSPDropDownCell.m
//  FoxSports
//
//  Created by greay on 5/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownCell.h"
#import "UIColor+FSPExtensions.h"
@implementation FSPDropDownCell

- (void)drawRect:(CGRect)rect;
{
    CGFloat lineMaxX = CGRectGetMaxX(rect);
    CGFloat lineTopY = CGRectGetMaxY(rect) - 1;
    
    //Draw bottom divider line
    if (self.drawBottomDivider) {
        UIBezierPath *bottomLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, lineTopY, lineMaxX, 1.0f)];
        [[UIColor fsp_colorWithIntegralRed:0 green:16 blue:35 alpha:1.0] set];
        [bottomLine fill];
    }
    
    //Draw top divider line
    if (self.drawTopDivider) {
    UIBezierPath *topLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, lineMaxX, 1.0f)];
    [[UIColor fsp_colorWithIntegralRed:13 green:46 blue:102 alpha:1.0] set];
    [topLine fill];
    }
    
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    [self.textLabel sizeToFit];
    CGPoint textCenter = self.contentView.center;
    textCenter.y = textCenter.y + 2;
    self.textLabel.center = textCenter;
    self.textLabel.frame = CGRectIntegral(self.textLabel.frame);
    CGRect textFrame = self.textLabel.frame;

	CGRect iconRect = self.imageView.frame;
	iconRect.origin.x = textFrame.origin.x - self.imageView.bounds.size.width - 12;
	self.imageView.frame = iconRect;
}

- (void)prepareForReuse
{
    self.drawBottomDivider = YES;
    self.drawTopDivider = YES;
}

@end
