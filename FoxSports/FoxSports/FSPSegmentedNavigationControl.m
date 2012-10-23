//
//  FSPSegmentedNavigationControl.m
//  FoxSports
//
//  Created by greay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSegmentedNavigationControl.h"
#import "FSPPrimarySegmentedControl.h"
#import "FSPSecondarySegmentedControl.h"
#import "FSPEventDetailDropdownView.h"

const CGFloat FSPNavigationViewPreferredHeight = 36.0;

@interface FSPSegmentedNavigationControl ()
@property (nonatomic, strong) FSPPrimarySegmentedControl *segmentedControl;
@property (nonatomic, strong) FSPSecondarySegmentedControl *subSegmentedControl;
@property (nonatomic, strong )FSPEventDetailDropdownView *dropdown;
@property (nonatomic, strong) NSMutableArray *subSegments;
- (void)commonInit;
- (void)selectionChanged:(id)sender;
@end


@implementation FSPSegmentedNavigationControl
@synthesize segmentedControl;
@synthesize dropdown;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
	self.subSegmentedControl = [[FSPSecondarySegmentedControl alloc] initWithFrame:CGRectZero];
	[self.subSegmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];

	[self addSubview:self.subSegmentedControl];

	self.useDropDown = NO;
}

- (void)layoutSubviews
{
	CGRect topRect, bottomRect;

	if (self.subSegmentedControl.numberOfSegments > 0) {
		CGRectDivide(self.bounds, &topRect, &bottomRect, ceilf(self.bounds.size.height / 2), CGRectMinYEdge);
	} else {
		topRect = self.bounds;
		bottomRect = CGRectZero;
	}
	
	self.segmentedControl.frame = topRect;
	self.dropdown.frame = topRect;
	self.subSegmentedControl.frame = bottomRect;
	
	[super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if (self.subSegmentedControl.numberOfSegments > 0) {
		return CGSizeMake(size.width, FSPNavigationViewPreferredHeight * 2);
	} else {
		return CGSizeMake(size.width, FSPNavigationViewPreferredHeight);
	}
}

- (void)setUseDropDown:(BOOL)useDropDown
{
	_useDropDown = useDropDown;
	
	if (_useDropDown) {
		self.dropdown = [[FSPEventDetailDropdownView alloc] initWithFrame:CGRectZero];
		self.dropdown.navigationControl = self;
		[self addSubview:self.dropdown];

		[self.segmentedControl removeFromSuperview];
		self.segmentedControl = nil;
		self.subSegments = nil;
	} else {
		self.segmentedControl = [[FSPPrimarySegmentedControl alloc] initWithFrame:CGRectZero];
		[self.segmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:self.segmentedControl];

		self.subSegments = [NSMutableArray array];
		
		[self.dropdown removeFromSuperview];
		self.dropdown = nil;
	}

	[self setNeedsLayout];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index animated:(BOOL)animated
{
	if (!self.useDropDown) {
		[self.segmentedControl insertSegmentWithTitle:title atIndex:index animated:animated];
		[self.subSegments insertObject:[NSMutableArray array] atIndex:index];
	} else {
		[self.dropdown insertOptionWithTitle:title atIndex:index];
	}
}

- (void)removeSegmentAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	if (!self.useDropDown) {
		[self.segmentedControl removeSegmentAtIndex:index animated:animated];
		[self.subSegments removeObjectAtIndex:index];
	} else {
		[self.dropdown removeOptionAtIndex:index];
	}
}

- (void)removeAllSegments
{
	if (!self.useDropDown) {
		[self.segmentedControl removeAllSegments];
		[self.subSegments removeAllObjects];
	} else {
		[self.dropdown removeAllOptions];
	}
}

- (void)setSegmentTitle:(NSString *)title atIndex:(NSUInteger)index
{
	if (!self.useDropDown) {
		[self.segmentedControl setTitle:title forSegmentAtIndex:index];
	} else {
		[self.dropdown setOptionTitle:title atIndex:index];
	}
}

- (NSInteger)selectedSegmentIndex
{
	if (!self.useDropDown) {
		return [self.segmentedControl selectedSegmentIndex];
	} else {
		return self.dropdown.selectedOptionIndex;
	}
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
	if (!self.useDropDown) {
		static NSInteger oldIndex = -1;
		[self.segmentedControl setSelectedSegmentIndex:index];

		NSArray *subSegments = [self.subSegments objectAtIndex:index];
		if ((oldIndex != index) || (self.subSegmentedControl.numberOfSegments != subSegments.count)) {
			[self.subSegmentedControl removeAllSegments];
			for (NSUInteger i = 0; i < subSegments.count; i++) {
				NSString *segment = [subSegments objectAtIndex:i];
				[self.subSegmentedControl insertSegmentWithTitle:segment atIndex:i animated:NO];
			}
			[self setNeedsLayout];

			oldIndex = index;
		}
		
		if (subSegments.count > 0 && self.subSegmentedControl.selectedSegmentIndex < 0) {
			self.subSegmentedControl.selectedSegmentIndex = 0;
		}
	} else {
		self.dropdown.selectedOptionIndex = index;
		[self selectionChanged:self.dropdown];
	}
}

- (NSUInteger)numberOfSegments
{
	if (!self.useDropDown) {
		return [self.segmentedControl numberOfSegments];
	} else {
		return [self.dropdown numberOfOptions];
	}
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
	if (!self.useDropDown) {
		return [self.segmentedControl titleForSegmentAtIndex:segment];
	} else {
		return [self.dropdown titleForOptionAtIndex:segment];
	}
}


- (void)addTarget:(id)target action:(SEL)action
{
	[self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}


#pragma mark -


- (void)setSubsegmentTitles:(NSArray *)subSegments forSection:(NSInteger)index
{
	if (!self.useDropDown) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			NSLog(@"Error. Subsegments are not supported on iPad.");
			return;
		}
		if ((NSUInteger)index < [self.subSegments count]) {
			NSMutableArray *segments = [self.subSegments objectAtIndex:index];
			[segments removeAllObjects];
			[segments addObjectsFromArray:subSegments];
		}
		if (index == self.selectedSegmentIndex) {
			NSUInteger oldIndex = self.subSegmentedControl.selectedSegmentIndex;
			[self.subSegmentedControl removeAllSegments];
			for (NSUInteger i = 0; i < subSegments.count; i++) {
				NSString *segment = [subSegments objectAtIndex:i];
				[self.subSegmentedControl insertSegmentWithTitle:segment atIndex:i animated:NO];
			}
			self.subSegmentedControl.selectedSegmentIndex = oldIndex;
			[self setNeedsLayout];
		}
	} else {
		[self.dropdown setSubOptions:subSegments forSection:index];
	}
}

- (NSInteger)selectedSubsegmentIndex
{
	if (!self.useDropDown) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			NSLog(@"Error. Subsegments are not supported on iPad.");
			return NSNotFound;
		}
		
		return [self.subSegmentedControl selectedSegmentIndex];
	} else {
		return self.dropdown.selectedSuboptionIndex;
	}
}

- (void)setSelectedSubsegmentIndex:(NSInteger)index
{
	if (!self.useDropDown) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			NSLog(@"Error. Subsegments are not supported on iPad.");
			return;
		}
		
		self.subSegmentedControl.selectedSegmentIndex = index;
	} else {
		self.dropdown.selectedSuboptionIndex = index;
		[self selectionChanged:self.dropdown];
	}
}


- (void)selectionChanged:(id)sender
{
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
