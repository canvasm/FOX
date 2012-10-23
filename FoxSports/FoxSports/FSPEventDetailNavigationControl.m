//
//  FSPEventDetailNavigationView.m
//  FoxSports
//
//  Created by greay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventDetailNavigationControl.h"
#import "FSPPrimarySegmentedControl.h"
#import "FSPEventDetailDropdownView.h"


@interface FSPEventDetailNavigationControl ()
@property (nonatomic, strong) FSPPrimarySegmentedControl *segmentedControl;
@property (nonatomic, strong )FSPEventDetailDropdownView *dropdown;
- (void)commonInit;
@end


@implementation FSPEventDetailNavigationControl
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
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.segmentedControl = [[FSPPrimarySegmentedControl alloc] initWithFrame:self.bounds];
//		self.segmentedControl.navigationControl = self;
		[self addSubview:self.segmentedControl];
	} else {
		self.dropdown = [[FSPEventDetailDropdownView alloc] initWithFrame:self.bounds];
//		self.dropdown.navigationControl = self;
		[self addSubview:self.dropdown];
	}
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index animated:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.segmentedControl insertSegmentWithTitle:title atIndex:index animated:animated];
	} else {
		[self.dropdown insertOptionWithTitle:title atIndex:index];
	}
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.segmentedControl removeSegmentAtIndex:segment animated:animated];
	} else {
		[self.dropdown removeOptionAtIndex:segment];
	}
}

- (void)removeAllSegments
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.segmentedControl removeAllSegments];
	} else {
		[self.dropdown removeAllOptions];
	}
}

- (void)setSegmentTitle:(NSString *)title atIndex:(NSUInteger)index
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.segmentedControl setTitle:title forSegmentAtIndex:index];
	} else {
		[self.dropdown setOptionTitle:title atIndex:index];
	}
}

- (NSInteger)selectedSegmentIndex
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return [self.segmentedControl selectedSegmentIndex];
	} else {
		return self.dropdown.selectedOptionIndex;
	}
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.segmentedControl setSelectedSegmentIndex:index];
	} else {
		self.dropdown.selectedOptionIndex = index;
	}
}

- (NSUInteger)numberOfSegments
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return [self.segmentedControl numberOfSegments];
	} else {
		return [self.dropdown numberOfOptions];
	}
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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


- (void)setSubsegmentTitles:(NSArray *)subSegments forSection:(NSUInteger)index
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		NSLog(@"Error. Subsegments are not supported on iPad.");
	} else {
		[self.dropdown setSubOptions:subSegments forSection:index];
	}
}

- (NSInteger)selectedSubsegmentIndex
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		NSLog(@"Error. Subsegments are not supported on iPad.");
		return NSNotFound;
	} else {
		return self.dropdown.selectedSuboptionIndex;
	}
}

- (void)setSelectedSubsegmentIndex:(NSInteger)index
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		NSLog(@"Error. Subsegments are not supported on iPad.");
	} else {
		self.dropdown.selectedSuboptionIndex = index;
	}
}


@end
