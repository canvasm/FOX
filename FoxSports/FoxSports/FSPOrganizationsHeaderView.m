//
//  FSPOrganizationsHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 6/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationsHeaderView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

static CGGradientRef
FSPOrganizationHeaderGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        size_t numLocations = 2;
        CGFloat locations[2] = { 0.0f, 1.0f };
        CGFloat components[8] = { 94.0/255.0f, 94.0/255.0f, 94.0/255.0f, 1.0f,  // start color
            59.0/255.0f, 59.0/255.0f, 59.0/255.0f, 1.0f }; // end color
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numLocations);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

@interface FSPOrganizationsHeaderView ()
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong, readwrite) UIImageView *star;
@end

@implementation FSPOrganizationsHeaderView
@synthesize headerLabel;
@synthesize star;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headerLabel = [[UILabel alloc] init];
        self.headerLabel.backgroundColor = [UIColor clearColor];
        self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.headerLabel.textAlignment = UITextAlignmentLeft;
		self.headerLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.headerLabel.textColor = [UIColor colorWithWhite:0.816 alpha:1.000];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.headerLabel.textColor = [UIColor whiteColor];
        }
        self.headerLabel.frame = self.bounds;
        
		[self addSubview:self.headerLabel];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPoint startPoint = CGPointZero;
        CGPoint endPoint = CGPointMake(0.0f, rect.size.height);
        
        CGContextSaveGState(context);
        CGContextDrawLinearGradient(context, FSPOrganizationHeaderGradient(), startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        [[UIColor fsp_colorWithIntegralRed:128 green:128 blue:128 alpha:1.0] setStroke];
        CGPoint highlightSegment[] = { CGPointMake(0.0, 1.0), CGPointMake(self.frame.size.width, 1.0) };
        CGContextStrokeLineSegments(context, highlightSegment, 2);
        CGContextRestoreGState(context);
    } else {
        CGContextSaveGState(context);
        [[UIColor fsp_colorWithHexString:@"131313"] setFill];
        CGContextFillRect(context, rect);
        CGContextSetLineWidth(context, 2.0);
        [[UIColor fsp_colorWithHexString:@"2c2c2c"] setStroke];
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGContextStrokePath(context);
        [[UIColor fsp_colorWithHexString:@"040404"] setStroke];
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

- (void)selectHeaderForSection:(int)section
{
    CGRect labelFrame = self.frame;

    switch (section) {
        case FSPOrganizationFavoritesSection: {
            self.headerLabel.text = @"FAVORITES";

            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"A_Star_Favorite"]];
                star.contentMode = UIViewContentModeCenter;
                star.frame = CGRectMake(4, 0, star.image.size.width, self.frame.size.height);
                [self addSubview:star];

                // account for slight font mis-alignment with the favorites star icon
                labelFrame.origin.y+=2;
                labelFrame.origin.x+=20;
                self.headerLabel.frame = labelFrame;
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Favorite_star"]];
                star.contentMode = UIViewContentModeCenter;
                star.frame = CGRectMake(17, 0, star.image.size.width, self.frame.size.height);
                [self addSubview:star];

                labelFrame.origin.y+=2;
                labelFrame.origin.x+=50;
                self.headerLabel.frame = labelFrame;
            }
            break;
        }
        case FSPOrganizationAllSection: {
            self.headerLabel.text = @"SPORTS";

            labelFrame.origin.y+=2;
            labelFrame.origin.x+=20;
            self.headerLabel.frame = labelFrame;
            break;
        }
        case FSPOrganizationChannelsSection: {
            self.headerLabel.text = @"CHANNELS";
            
            // channels will always be way below sports/favorites and looks odd when not offset a little less
            labelFrame.origin.y+=2;
            labelFrame.origin.x+=14;
            self.headerLabel.frame = labelFrame;
            break;
        }
    }

    self.headerLabel.frame = labelFrame;
}

@end
