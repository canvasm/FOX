//
//  FSPConferencesOverlayCell.m
//  FoxSports
//
//  Created by greay on 8/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConferencesOverlayCell.h"

#import "FSPOrganization.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPConferencesOverlayCell ()

@property (nonatomic, strong) NSArray *conferences;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) id selectionTarget;
@property (nonatomic, assign) SEL selector;

@end

@implementation FSPConferencesOverlayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIView *highlight = [[UIView alloc] init];
		highlight.backgroundColor = [UIColor colorWithRed:13/255.0f green:46/255.0f blue:102/255.0f alpha:1.0];
		highlight.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
		highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview:highlight];
		
		void (^applyButtonStyle)(UIButton *) = ^(UIButton *button) {
			button.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
			button.titleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
			button.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
			[button setTitleColor:[UIColor fsp_mediumBlueColor] forState:UIControlStateNormal];
			button.titleEdgeInsets = UIEdgeInsetsMake(8, 10, 2, 5);
			button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			UIImage *bkg = [[UIImage imageNamed:@"seg_control_sub_div"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 1, 18, 1)];
			[button setBackgroundImage:bkg forState:UIControlStateNormal];
			button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		};
		
		self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.leftButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
		applyButtonStyle(self.leftButton);
		[self.contentView addSubview:self.leftButton];

		self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.rightButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
		applyButtonStyle(self.rightButton);
		[self.contentView addSubview:self.rightButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
	self.conferences = nil;

	[self.leftButton setTitle:nil forState:UIControlStateNormal];
	[self.rightButton setTitle:nil forState:UIControlStateNormal];
}

- (void)populateWithConferences:(NSArray *)conferences selected:(NSManagedObjectID *)selectedOrg
{
	self.conferences = conferences;
	if (!conferences || !conferences.count) return;
	
	FSPOrganization *left = [conferences objectAtIndex:0];
	FSPOrganization *right = (conferences.count > 1) ? [conferences objectAtIndex:1] : nil;

	CGRect leftFrame, rightFrame;
	CGFloat leftButtonWidth = (right) ? self.bounds.size.width / 2 : self.bounds.size.width;
	
	CGRectDivide(self.bounds, &leftFrame, &rightFrame, leftButtonWidth, CGRectMinXEdge);
	
	self.leftButton.frame = leftFrame;
	self.rightButton.frame = rightFrame;
	
	[self.leftButton setTitle:left.name forState:UIControlStateNormal];
	if ([[left objectID] isEqual:selectedOrg]) {
		[self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	} else {
		[self.leftButton setTitleColor:[UIColor fsp_mediumBlueColor] forState:UIControlStateNormal];
	}

	[self.rightButton setTitle:right.name forState:UIControlStateNormal];
	if ([[right objectID] isEqual:selectedOrg]) {
		[self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	} else {
		[self.rightButton setTitleColor:[UIColor fsp_mediumBlueColor] forState:UIControlStateNormal];
	}
	
	self.rightButton.hidden = (!right);
}

- (void)didTapButton:(UIButton *)button
{
	FSPOrganization *conference = nil;
	
	if ([button isEqual:self.leftButton]) {
		conference = [self.conferences objectAtIndex:0];
	} else if ([button isEqual:self.rightButton]) {
		conference = [self.conferences objectAtIndex:1];
	} else {
		NSLog(@"error. unrecognized button?");
	}
	[self.delegate cell:self didSelectConference:conference];
}

- (void)setButtonsTarget:(id)target action:(SEL)selector
{
	self.selectionTarget = target;
	self.selector = selector;
}

@end
