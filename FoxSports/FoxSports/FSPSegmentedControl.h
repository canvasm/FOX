//
//  FSPSegmentedControl.h
//  FoxSports
//
//  Created by greay on 7/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPSegmentedControl : UIControl

// common initialization function shared by initWithFrame & awakeFromNib
- (void)commonInit;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;

- (void)removeAllSegments;

@property (nonatomic, readonly) NSUInteger numberOfSegments;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, assign) BOOL wrapTitles;

@property (nonatomic, strong) UIView *backgroundView;

// Appearance proxies
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

@end
