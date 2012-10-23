//
//  FSPNBAConferenceSectionHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsSectionHeaderView.h"
#import "FSPGameDetailSectionDrawing.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

CGFloat const FSPNBAStandingsConferenceSectionHeaderHeight = 50.0;
CGFloat const FSPNBAStandingsDivisionSectionHeaderHeight = 30.0;

@interface FSPStandingsSectionHeaderView()
@property (nonatomic, weak, readwrite) IBOutlet UILabel *sectionNameLabel;
@property (nonatomic, strong, readwrite) IBOutletCollection(UILabel) NSArray *columnHeadingLabels;
@end

@implementation FSPStandingsSectionHeaderView
@synthesize divisionName = _divisionName;
@synthesize sectionNameLabel = _sectionNameLabel;
@synthesize columnHeadingLabels = _columnHeadingLabels;

- (void)awakeFromNib
{
    UIFont *headingFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIColor *headingColor = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];
    for (UILabel *label in self.columnHeadingLabels) {
        label.font = headingFont;
        label.textColor = headingColor;
    }
    self.sectionNameLabel.hidden = YES;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    for (UILabel *label in self.columnHeadingLabels) {
        label.shadowColor = shadowColor;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    FSPDrawGrayWhiteDividerLine(context, rect);
}

- (void)setDivisionName:(NSString *)divisionName;
{
    if(divisionName != nil) {
       if(_divisionName != divisionName) {
            self.sectionNameLabel.text = [divisionName uppercaseString];
            self.sectionNameLabel.hidden = NO;
       } else {
           self.sectionNameLabel.hidden = YES;
       }
    }
}

@end
