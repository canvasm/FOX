//
//  FSPGameSegmentedControl.m
//  FoxSports
//
//  Created by Matthew Fay on 2/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPrimarySegmentedControl.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPPrimarySegmentedControl()

@property (nonatomic, strong) UIImageView *topFlare;

- (void)moveFlareToIndex:(NSInteger)index;

@end

@implementation FSPPrimarySegmentedControl
@synthesize topFlare;

- (void)commonInit
{
	[super commonInit];
	self.wrapTitles = YES;
	
	// NOTE: Apple recommends replacing the deprecated -stretchableImageWithLeftCapWidth:topCapHeight: with -resizableImageWithCapInsets:,
	// specifying cap insets such that the interior is a 1x1 area.
	// what they don't tell you is that if you supply any other cap insets, it is highly likely that you will crash when you set the frame of
	// the view you use it in.
    UIImage *originalNormal = [[UIImage imageNamed:@"segmented-nonselected-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 1, 18, 1)];
    UIImage *originalSelected = [[UIImage imageNamed:@"segmented-selected-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 1, 18, 1)];
	
	[self setBackgroundImage:originalNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:originalSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

	// UIAccessibilty needs identifiers
	self.accessibilityIdentifier = @"eventDetailsSegmentedController";
	
	//set attributes for the text in the segmented control
	NSDictionary *normalStateDict = @{UITextAttributeTextColor: [UIColor fsp_mediumBlueColor],
                                     UITextAttributeTextShadowColor: [UIColor fsp_blackDropShadowColor],
									 UITextAttributeFont: [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f]};
    
	NSDictionary *selectedStateDict = @{UITextAttributeTextColor: [UIColor whiteColor],
                                        UITextAttributeTextShadowColor: [UIColor fsp_blackDropShadowColor],
                                        UITextAttributeFont: [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f]};
    
	[self setTitleTextAttributes:normalStateDict forState:UIControlStateNormal];
	[self setTitleTextAttributes:selectedStateDict forState:UIControlStateSelected];
	
	//create and add the flare on the selected segmented control
	UIImage *flare = [UIImage imageNamed:@"selected-top-flare"];
	self.topFlare = [[UIImageView alloc] initWithImage:flare];
	self.topFlare.hidden = YES;
	self.topFlare.frame = CGRectMake(0, 0, 90, 7);
	[self addSubview:self.topFlare];
	
	self.selectedSegmentIndex = -1;
}

- (void)moveFlareToIndex:(NSInteger)index
{
    if ( index >= 0 ) {
        int numControls = self.numberOfSegments;
        if (numControls > 0)
        {
            self.topFlare.hidden = NO;
            float segmentControlWidth = self.frame.size.width;
            float segmentWidth = segmentControlWidth/numControls;
            float borderWidth = (self.bounds.size.width - self.frame.size.width)/2.0f;
            float borderHeight = (self.bounds.size.height - self.frame.size.height)/2.0f;
            
            //flare placement (The 5 added to height is to take into account the shadow on the top of the segments)
            CGPoint centerPoint = CGPointMake(floorf(borderWidth + (segmentWidth/ 2.0f) + (index * segmentWidth)), floorf(borderHeight + 4));
            self.topFlare.center = centerPoint;
        }
		
    } else {
        self.topFlare.hidden = YES;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
	[super setSelectedSegmentIndex:index];
	[self moveFlareToIndex:index];
}

@end
