//
//  FSPGameDetailTeamHeader.m
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailTeamHeader.h"
#import "FSPTeam.h"
#import "FSPGameDetailSectionDrawing.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPGameDetailTeamHeader ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *teamNameLabel;

@end

@implementation FSPGameDetailTeamHeader

@synthesize teamNameLabel = _teamNameLabel;
@synthesize team = _team;

- (void)awakeFromNib
{
    self.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0];;
}

- (void)setTeamWithShortNameDisplay:(FSPTeam *)team teamColor:(UIColor *)teamColor;
{
    self.teamNameLabel.text = [team.abbreviation uppercaseString];
    self.backgroundColor = teamColor;
}

- (void)setTeam:(FSPTeam *)team teamColor:(UIColor *)teamColor;
{
    self.teamNameLabel.text = [team.shortNameDisplayString uppercaseString];
    self.backgroundColor = teamColor;
}

- (void)drawRect:(CGRect)rect
{
    self.teamNameLabel.shadowOffset = CGSizeMake(0, -1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat rectMaxY = CGRectGetMaxY(rect);
    CGFloat rectMaxX = CGRectGetMaxX(rect);

    //draw bottom shadow
    CGContextSaveGState(context);
    [[UIColor colorWithWhite:0.0f alpha:0.15f] set];
    UIRectFillUsingBlendMode(CGRectMake(0, rect.size.height/2, self.bounds.size.width, rect.size.height/2), kCGBlendModeMultiply);
    CGContextRestoreGState(context);

    CGContextSaveGState(context);
    //Draw top highlight
    CGPoint topSegment[] = {CGPointMake(0.0, 1.0), CGPointMake(rectMaxX, 1.0)};
    FSPDrawHighlightLine(context, topSegment);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);

    //Draw thicker dark blue border on sides
    [[UIColor fsp_colorWithIntegralRed:0 green:16 blue:35 alpha:1.0] setStroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 1.0);
    CGPoint sideSegments[] = {CGPointMake(0.0, 0.0), CGPointMake(0.0, rectMaxY), CGPointMake(rectMaxX, 0.0), CGPointMake(rectMaxX, rectMaxY)};
    CGContextStrokeLineSegments(context, sideSegments, 4);

    //Draw thinner dark Blue border on bottom
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 2.0);
    CGPoint topBottomSegments[] = {CGPointMake(0.0, rectMaxY), CGPointMake(rectMaxX, rectMaxY)};
    CGContextStrokeLineSegments(context, topBottomSegments, 2);
    CGContextRestoreGState(context);
}


@end
