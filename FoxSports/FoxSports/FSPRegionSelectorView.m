//
//  FSPRegionSelectorView.m
//  FoxSports
//
//  Created by Stephen Spring on 7/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRegionSelectorView.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPRegionSelectorView

@synthesize selectRegionButton = _selectRegionButton;
@synthesize selectedRegionLabel = _selectedRegionLabel;
@synthesize gradientImageView = _gradientImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"FSPRegionSelectorView" owner:self options:nil];
        UIView *topLevelView = [nibObjects objectAtIndex:0];
        topLevelView.frame = frame;
        [self addSubview:topLevelView];
        for (UIView *view in [topLevelView subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                _selectRegionButton = (UIButton *)view;
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                _selectedRegionLabel = (UILabel *)view;
            }
        }
        _selectedRegionLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0];
        _selectRegionButton.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_selectRegionButton setBackgroundImage:[UIImage imageNamed:@"news_dropdown.png"] forState:UIControlStateNormal];
            [_selectRegionButton setBackgroundImage:[UIImage imageNamed:@"news_dropdown_selected.png"] forState:UIControlStateHighlighted];
            [_selectRegionButton setBackgroundImage:[UIImage imageNamed:@"news_dropdown_selected.png"] forState:UIControlStateSelected];
        } else {
            UIImage *backgroundImage = [UIImage imageNamed:@"close_button.png"];
            backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 24.0, 15.0, 24.0)];
            [_selectRegionButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        }
        _gradientImageView.image = [UIImage imageNamed:@"city_select_background_gradient"]; 
    }
    return self;
}

- (void)swapColor:(BOOL)selected
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
    
    UIImage *selectedImage = [UIImage imageNamed:@"news_dropdown_selected.png"];
    UIImage *nonSelectedImage = [UIImage imageNamed:@"news_dropdown.png"];
    
    if (selected) {
        [self.selectRegionButton setBackgroundImage:selectedImage forState:UIControlStateNormal];
        [self.selectRegionButton setBackgroundImage:nonSelectedImage forState:UIControlStateHighlighted];
        [self.selectRegionButton setBackgroundImage:nonSelectedImage forState:UIControlStateSelected];
    } else {
        [self.selectRegionButton setBackgroundImage:nonSelectedImage forState:UIControlStateNormal];
        [self.selectRegionButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        [self.selectRegionButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
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
