//
//  FSPNBAInjuryReportTitle.m
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailSectionHeader.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPGameDetailSectionHeader()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
void FSPDrawHeaderSectionDividerLine(CGContextRef context, CGPoint lineStartPoint, CGPoint lineEndPoint, BOOL drawHighlight, BOOL drawDarkLine);
@end

@implementation FSPGameDetailSectionHeader

@synthesize titleLabel = _titleLabel;
@synthesize highlightLineFlag;
@synthesize darkLineFlag;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;

    self.backgroundColor = [UIColor clearColor];
    self.highlightLineFlag = @(YES);
    self.darkLineFlag = @(YES);
    return self;
}

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
    self.titleLabel.textColor = [UIColor whiteColor];
}

void FSPDrawHeaderSectionDividerLine(CGContextRef context, CGPoint lineStartPoint, CGPoint lineEndPoint, BOOL drawHighlight, BOOL drawDarkLine)
{
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    
    //This can be a little confusing
    //if only one flag is set it will be drawn in the place of the other one
    if (drawHighlight && drawDarkLine) {
        [[UIColor colorWithRed:0.0f green:16/255.0f blue:35/255.0f alpha:1.0] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y, lineEndPoint.x - lineStartPoint.x, 1));
        
        [[UIColor colorWithRed:0.102 green:0.345 blue:0.655 alpha:1.000] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y + 1, lineEndPoint.x - lineStartPoint.x, 1));
    } else if (drawDarkLine){
        [[UIColor colorWithRed:0.0f green:16/255.0f blue:35/255.0f alpha:1.0] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y + 1, lineEndPoint.x - lineStartPoint.x, 1));
    } else if (drawHighlight) {
        [[UIColor colorWithRed:0.102 green:0.345 blue:0.655 alpha:1.000] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y, lineEndPoint.x - lineStartPoint.x, 1));
    }
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[] = { 0.0 / 255.0, 51.0 / 255.0, 115.0 / 255.0, 1.0, //Gradient top
                                   0.0 / 255.0, 43.0 / 255.0, 98.0 / 255.0, 1.0 }; //Gradient bottom
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0, CGRectGetMaxY(rect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    CGContextRestoreGState(context);
    CGContextSaveGState(context);

    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGFloat lineBottomY = CGRectGetMaxY(rect) - 2;
    CGFloat lineMaxX = CGRectGetMaxX(rect);

    //Draw bottom divider line
    FSPDrawGameSectionDividerLine(context, CGPointMake(0.0, lineBottomY), CGPointMake(lineMaxX, lineBottomY), [self.highlightLineFlag boolValue], YES);

    //Draw top divider line
    FSPDrawHeaderSectionDividerLine(context, CGPointMake(0.0, 0.0), CGPointMake(lineMaxX, 0.0), YES, [self.darkLineFlag boolValue]);

    CGContextRestoreGState(context);
}

void FSPDrawGameSectionDividerLine(CGContextRef context, CGPoint lineStartPoint, CGPoint lineEndPoint, BOOL drawHighlight, BOOL drawDarkLine)
{
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    
    //This can be a little confusing
    //if only one flag is set it will be drawn in the place of the other one
    if (drawHighlight && drawDarkLine) {
        [[UIColor colorWithRed:0.0f green:16/255.0f blue:35/255.0f alpha:1.0] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y, lineEndPoint.x - lineStartPoint.x, 1));
        
        [[UIColor colorWithWhite:1.0f alpha:0.1f] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y + 1, lineEndPoint.x - lineStartPoint.x, 1));
    } else if (drawDarkLine){
        [[UIColor colorWithRed:0.0f green:16/255.0f blue:35/255.0f alpha:1.0] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y + 1, lineEndPoint.x - lineStartPoint.x, 1));
    } else if (drawHighlight) {
        [[UIColor colorWithWhite:1.0f alpha:0.1f] set];
        UIRectFill(CGRectMake(0, lineStartPoint.y, lineEndPoint.x - lineStartPoint.x, 1));
    }
    CGContextRestoreGState(context);
}

@end
