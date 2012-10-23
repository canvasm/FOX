//
//  FSPMLBGameTraxHotZoneView.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxHotZoneView.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPMLBGameTraxHotZoneView

@synthesize view;
@synthesize hotLabel1, hotLabel2, hotLabel3, hotLabel4, hotLabel5, hotLabel6, hotLabel7, hotLabel8, hotLabel9;
@synthesize hotZone1, hotZone2, hotZone3, hotZone4, hotZone5, hotZone6, hotZone7, hotZone8, hotZone9;
@synthesize _hotValues, hotLabels, hotZones;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxHotZoneView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxHotZoneView" owner:self options:nil];
    [self addSubview:self.view];
    //[self setHotValues:[NSArray arrayWithObjects:@".308", @".327", @".192", @".260", @".198", @".188", @".251", @".156", @".313", nil]];

    hotZones = [NSArray arrayWithObjects:hotZone1, hotZone2, hotZone3, hotZone4, hotZone5, hotZone6, hotZone7, hotZone8, hotZone9, nil];
    hotLabels = [NSArray arrayWithObjects:hotLabel1, hotLabel2, hotLabel3, hotLabel4, hotLabel5, hotLabel6, hotLabel7, hotLabel8, hotLabel9, nil];

    for (NSUInteger i = 0; i < [hotLabels count]; i++) {
        [(UILabel *)[hotLabels objectAtIndex:i] setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0]];
    }
}

- (void)setHotValues:(NSArray *)hotValues
{
    [hotLabel1 setText:[hotValues objectAtIndex:0]];
    [hotLabel2 setText:[hotValues objectAtIndex:1]];
    [hotLabel3 setText:[hotValues objectAtIndex:2]];
    [hotLabel4 setText:[hotValues objectAtIndex:3]];
    [hotLabel5 setText:[hotValues objectAtIndex:4]];
    [hotLabel6 setText:[hotValues objectAtIndex:5]];
    [hotLabel7 setText:[hotValues objectAtIndex:6]];
    [hotLabel8 setText:[hotValues objectAtIndex:7]];
    [hotLabel9 setText:[hotValues objectAtIndex:8]];

    _hotValues = hotValues;

    for (NSUInteger i = 0; i < [hotLabels count]; i++) {
        float hotValue = [[(UILabel *)[hotLabels objectAtIndex:i] text] floatValue];

        if (hotValue < .1) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:27/255.0 green:102/255.0 blue:194/255.0 alpha:1.0]];
        } else if (hotValue < .149) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:20/255.0 green:86/255.0 blue:168/255.0 alpha:1.0]];
        } else if (hotValue < .199) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:12/255.0 green:67/255.0 blue:135/255.0 alpha:1.0]];
        } else if (hotValue < .249) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:0/255.0 green:45/255.0 blue:101/255.0 alpha:1.0]];
        } else if (hotValue < .299) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:2/255.0 green:31/255.0 blue:67/255.0 alpha:1.0]];
        } else if (hotValue < .349) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:58/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]];
        } else if (hotValue < .399) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:86/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]];
        } else if (hotValue < .449) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:112/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]];
        } else if (hotValue < .499) {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:135/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]];
        } else {
            [[hotZones objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:166/255.0 green:8/255.0 blue:8/255.0 alpha:1.0]];
        }
    }

    //[self setNeedsLayout];
}

- (void)setHotLabelsHidden:(BOOL)hidden
{
//    [hotLabel1 setHidden:hidden];
//    [hotLabel2 setHidden:hidden];
//    [hotLabel3 setHidden:hidden];
//    [hotLabel4 setHidden:hidden];
//    [hotLabel5 setHidden:hidden];
//    [hotLabel6 setHidden:hidden];
//    [hotLabel7 setHidden:hidden];
//    [hotLabel8 setHidden:hidden];
//    [hotLabel9 setHidden:hidden];

    for (NSUInteger i = 0; i < [hotLabels count]; i++) {
        [[hotLabels objectAtIndex:i] setHidden:hidden];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
