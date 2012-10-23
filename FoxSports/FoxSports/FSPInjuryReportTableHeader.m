//
//  FSPNBAInjuryReportTableHeader.m
//  FoxSports
//
//  Created by Matthew Fay on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPInjuryReportTableHeader.h"
#import "UIFont+FSPExtensions.h"

CGFloat const FSPNBAInjuryReportHeaderHeight = 72;

@interface FSPInjuryReportTableHeader()
@property (nonatomic, strong) UIImage *lineMaskImage;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;
@end

@implementation FSPInjuryReportTableHeader

@synthesize gradient = _gradient;
@synthesize lineMaskImage = _lineMaskImage;
@synthesize labels = _labels;
@synthesize teamHeader = _teamHeader;
@synthesize teamHeaderHome = _teamHeaderHome;

- (void)setGradient:(CGGradientRef)gradient;
{
    if (_gradient != gradient) {
        if (_gradient)
            CGGradientRelease(_gradient);
        if (gradient)
            CGGradientRetain(gradient);
        _gradient = gradient;
        [self setNeedsDisplay];
    }
}

- (void)dealloc;
{
    self.gradient = NULL;
}

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"FSPInjuryReportTableHeader" bundle:nil];
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    self = [nibObjects lastObject];
    
    if(!self) return nil;
    
    self.frame = frame;
    return self;
}

- (void)awakeFromNib
{
    UIFont *headerFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];

    for(UILabel *label in self.labels)
        label.font = headerFont;
}

- (void)drawRect:(CGRect)rect
{
    if (_gradient) {
        static CGFloat lineYPosition = FSPNBAInjuryReportHeaderHeight - 2;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        //draw background gradient
        CGPoint startPoint = CGPointMake(0.0f, 0.0f);
        CGPoint endPoint = CGPointMake(rect.size.width, 0.0f);
        CGContextDrawLinearGradient(ctx, self.gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(ctx);
        
        //draw bottom line
        CGContextSaveGState(ctx);
        
        [[UIColor colorWithRed:0 green:0.0627 blue:0.137 alpha:1.0] set];
        UIRectFill(CGRectMake(0, lineYPosition, self.bounds.size.width, 2));
        
        [[UIColor colorWithRed:0.149 green:0.345 blue:0.5765 alpha:0.4] set];
        UIRectFill(CGRectMake(0, lineYPosition + 1, self.bounds.size.width, 1));
        
        CGContextRestoreGState(ctx);
        
        //draw top line
        CGContextSaveGState(ctx);
        
        [[UIColor colorWithRed:0 green:0.0627 blue:0.137 alpha:1.0] set];
        UIRectFill(CGRectMake(0, 0, self.bounds.size.width, 2));
        
        [[UIColor colorWithRed:0.149 green:0.345 blue:0.5765 alpha:0.4] set];
        UIRectFill(CGRectMake(0, 1, self.bounds.size.width, 1));
        
        CGContextRestoreGState(ctx);
    }
}


@end
