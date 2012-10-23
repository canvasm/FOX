//
//  FSPDarkBlueSegmentedControl.m
//  FoxSports
//
//  Created by Laura Savino on 5/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSecondarySegmentedControl.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPSegmentedControlDarkBlueOverlay.h"

@interface FSPSecondarySegmentedControl ()
@property (nonatomic, strong) IBOutlet UIImageView *selectedSegmentView;
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation FSPSecondarySegmentedControl

- (void)commonInit
{
	[super commonInit];
	
	self.backgroundColor = [UIColor clearColor];

	// NOTE: Apple recommends replacing the deprecated -stretchableImageWithLeftCapWidth:topCapHeight: with -resizableImageWithCapInsets:,
	// specifying cap insets such that the interior is a 1x1 area.
	// what they don't tell you is that if you supply any other cap insets, it is highly likely that you will crash when you set the frame of
	// the view you use it in.
	UIImage *blank = [[UIImage imageNamed:@"seg_control_sub_div"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 1, 18, 1)];

    [self setBackgroundImage:blank forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:blank forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
	//set attributes for the text in the segmented control
	NSDictionary *normalStateDict = @{UITextAttributeTextColor: [UIColor fsp_mediumBlueColor],
                                    UITextAttributeTextShadowColor: [UIColor fsp_blackDropShadowColor],
                                    UITextAttributeFont: [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f]};
    
	NSDictionary *selectedStateDict = @{UITextAttributeTextColor: [UIColor whiteColor],
                                        UITextAttributeTextShadowColor: [UIColor fsp_blackDropShadowColor],
                                        UITextAttributeFont: [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f]};
    
    [self setTitleTextAttributes:normalStateDict forState:UIControlStateNormal];
	[self setTitleTextAttributes:selectedStateDict forState:UIControlStateSelected];
	
    //TODO: Set selectedSegmentView width based on number of segments (varying inversely with number of segments)g; currently, there are no designs for this.
	
	UIImageView *segmentView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sub-segment"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	segmentView.frame = self.frame;
	FSPSegmentedControlDarkBlueOverlay *overlay = [[FSPSegmentedControlDarkBlueOverlay alloc] initWithFrame:segmentView.bounds];
	overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[segmentView addSubview:overlay];
	[self.superview insertSubview:segmentView belowSubview:self];
	[self.backgroundView addSubview:segmentView];
	
	self.selectedSegmentView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"segment-selected-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
	[self addSubview:self.selectedSegmentView];
	self.selectedSegmentView.frame = CGRectMake(0, 0, 150, 4);
	
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
	[super setSelectedSegmentIndex:selectedSegmentIndex];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    if (self.selectedSegmentIndex >= 0) {
        int numControls = self.numberOfSegments;
        if (numControls > 0)
        {
            self.selectedSegmentView.hidden = NO;
            float segmentControlWidth = self.frame.size.width;
            float segmentWidth = segmentControlWidth/numControls;
            
            CGPoint centerPoint = CGPointMake((segmentWidth/ 2.0f) + (self.selectedSegmentIndex * segmentWidth), self.frame.size.height - self.selectedSegmentView.frame.size.height / 2);
            self.selectedSegmentView.center = centerPoint;
        }
        
    } else {
        self.selectedSegmentView.hidden = YES;
    }
}

@end

