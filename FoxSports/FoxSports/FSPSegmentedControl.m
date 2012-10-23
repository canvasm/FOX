//
//  FSPSegmentedControl.m
//  FoxSports
//
//  Created by greay on 7/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSegmentedControl.h"

@interface FSPSegmentedControl ()
- (void)commonInit;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *dividers;

@property (nonatomic, strong) NSMutableDictionary *backgroundImageForStates;
@property (nonatomic, strong) NSMutableDictionary *titleTextAttributesForStates;
@end


@implementation FSPSegmentedControl
@synthesize scrollView, items, wrapTitles;
@synthesize backgroundImageForStates, titleTextAttributesForStates;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)awakeFromNib
{
	[self commonInit];
}

- (void)commonInit
{
	self.items = [NSMutableArray array];
	self.dividers = [NSMutableArray array];
	
	self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
	self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:self.backgroundView];
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	[self addSubview:self.scrollView];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.scrollEnabled = NO;
	self.scrollView.backgroundColor = [UIColor clearColor];
	
	self.backgroundImageForStates = [NSMutableDictionary dictionary];
	self.titleTextAttributesForStates = [NSMutableDictionary dictionary];
}

- (UIButton *)segmentWithTitle:(NSString *)title
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventTouchUpInside];

	for (NSNumber *key in [self.backgroundImageForStates allKeys]) {
		UIImage *image = [self.backgroundImageForStates objectForKey:key];
		UIControlState state = [key unsignedIntegerValue];
		[button setBackgroundImage:image forState:state];
	}
	for (NSNumber *key in [self.titleTextAttributesForStates allKeys]) {
		NSDictionary *attributes = [self.titleTextAttributesForStates objectForKey:key];
		UIControlState state = [key unsignedIntegerValue];
		[self setTitleTextAttributes:attributes forButton:button forState:state];
	}

	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
	
	return button;
}

- (void)updateSegmentsAnimated:(BOOL)animated
{
	if (!self.items.count) return;
	
	// clear out dividers
	for (UIButton *divider in self.dividers) {
		[divider removeFromSuperview];
	}
	[self.dividers removeAllObjects];
	
	// if <= 4 segments, set labels to 2 lines, don't scroll.
	// if > 4 segments, set labels to 1 line, scroll horizontally.
	NSUInteger numberOfLines = (self.wrapTitles && self.items.count > 4) ? 1 : 2;
    
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(7, 5, 5, 5);

	CGFloat desiredWidth = 0.0;
	for (UIButton *button in self.items) {
		button.titleLabel.numberOfLines = numberOfLines;
		[button sizeToFit];
        button.titleEdgeInsets  = titleInsets;
		button.frame = CGRectMake(desiredWidth, 0, button.frame.size.width + 10, self.bounds.size.height);

		desiredWidth += button.frame.size.width;

		if (![button isEqual:[self.items lastObject]]) {
			UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(desiredWidth, 0, 1, self.bounds.size.height)];
			divider.layer.backgroundColor = [UIColor blackColor].CGColor;
			[self.dividers addObject:divider];
			[self.scrollView addSubview:divider];
			desiredWidth++;
		}

		if (button.superview != self.scrollView) [self.scrollView addSubview:button];
	}
	
	if (desiredWidth <= self.bounds.size.width || (self.wrapTitles && self.items.count <= 4)) {
		self.scrollView.contentSize = self.bounds.size;
		self.scrollView.scrollEnabled = NO;
		
		CGFloat buttonWidth = floorf(self.bounds.size.width / self.items.count);
		for (NSUInteger i = 0; i < self.items.count; i++) {
			UIButton *button = [self.items objectAtIndex:i];
			CGRect frame = button.frame;
			frame.origin = CGPointMake(i * (buttonWidth + 1), 0);
			frame.size.width = buttonWidth;
			button.frame = frame;
			
			if (i < self.dividers.count) {
				UIView *divider = [self.dividers objectAtIndex:i];
				frame.origin.x += frame.size.width;
				frame.size.width = 1;
				divider.frame = frame;
			}
		}
	} else {
		CGRect frame = self.bounds;
		frame.size.width = desiredWidth;
		self.scrollView.contentSize = frame.size;
		self.scrollView.scrollEnabled = YES;
	}
	
	UIButton *lastButton = [self.items lastObject];
	if (CGRectGetMaxX(lastButton.frame) < self.bounds.size.width) {
		CGRect frame = lastButton.frame;
		frame.size.width = self.bounds.size.width - frame.origin.x;
		lastButton.frame = frame;
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self updateSegmentsAnimated:NO];
}


- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
	if (segment == self.items.count) {
		[self insertSegmentWithTitle:title atIndex:segment animated:YES];
		return;
	}
	UIButton *button = [self.items objectAtIndex:segment];
	[button setTitle:title forState:UIControlStateNormal];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
	UIButton *button = [self.items objectAtIndex:segment];
	return [button titleForState:UIControlStateNormal];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
	UIButton *button = [self segmentWithTitle:title];
	[self.items insertObject:button atIndex:segment];

	[self updateSegmentsAnimated:animated];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
	[[self.items objectAtIndex:segment] removeFromSuperview];
	[self.items removeObjectAtIndex:segment];
	[self updateSegmentsAnimated:animated];
}

- (void)removeAllSegments
{
	for (UIButton *button in self.items) {
		[button removeFromSuperview];
	}
	[self.items removeAllObjects];
	self.selectedSegmentIndex = -1;

	[self updateSegmentsAnimated:NO];
}

- (NSUInteger) numberOfSegments
{
	return self.items.count;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
	if (self.items.count) {
		if (_selectedSegmentIndex >= 0) {
			[[self.items objectAtIndex:_selectedSegmentIndex] setSelected:NO];
            ((UIButton*)[self.items objectAtIndex:_selectedSegmentIndex]).titleLabel.shadowOffset = CGSizeMake(0, 1);
		}
		if (selectedSegmentIndex >= 0) {
			[[self.items objectAtIndex:selectedSegmentIndex] setSelected:YES];
            ((UIButton*)[self.items objectAtIndex:selectedSegmentIndex]).titleLabel.shadowOffset = CGSizeMake(0, -1);
		}
	}
	_selectedSegmentIndex = selectedSegmentIndex;
}

#pragma mark - Touches

- (void)segmentTapped:(UIButton *)sender
{
	NSInteger index = NSNotFound;
	for (NSUInteger i = 0; i < self.items.count; i++) {
		if ([[self.items objectAtIndex:i] isEqual:sender]) {
			index = i;
			break;
		}
	}
	BOOL valueChanged = NO;
	
	if (index != NSNotFound) {
		if (index != self.selectedSegmentIndex) valueChanged = YES;
		self.selectedSegmentIndex = index;
		if (valueChanged) [self sendActionsForControlEvents:UIControlEventValueChanged];
	}
	
}

#pragma mark - Appearance

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
	// we ignore barMetrics
	for (UIButton *button in self.items) {
		[button setBackgroundImage:backgroundImage forState:state];
	}
	
	id key = @(state);
	if (backgroundImage) {
		[self.backgroundImageForStates setObject:backgroundImage forKey:key];
	} else {
		[self.backgroundImageForStates removeObjectForKey:key];
	}
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forButton:(UIButton *)button forState:(UIControlState)state
{
	if ([attributes valueForKey:UITextAttributeFont]) {
		[button.titleLabel setFont:[attributes valueForKey:UITextAttributeFont]];
	}
	[button setTitleColor:[attributes valueForKey:UITextAttributeTextColor] forState:state];
	[button setTitleShadowColor:[attributes valueForKey:UITextAttributeTextShadowColor] forState:state];
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
	for (UIButton *button in self.items) {
		[self setTitleTextAttributes:attributes forButton:button forState:state];
	}
	
	id key = @(state);
	if (attributes) {
		[self.titleTextAttributesForStates setObject:attributes forKey:key];
	} else {
		[self.titleTextAttributesForStates removeObjectForKey:key];
	}
}

@end
