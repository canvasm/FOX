//
//  FSPEventDetailNavigationView.h
//  FoxSports
//
//  Created by greay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPEventDetailNavigationControl : UIControl

@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, assign) NSInteger selectedSubsegmentIndex;

/**
 inserts a segment into the segmented controller at the specified index
 */
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 removes a segment from the segmented controller at the specified index
 */
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;

/**
 removes all segments of the segmented controller
 */
- (void)removeAllSegments;

/**
 Sets the title on a segment at the specified index
 */
- (void)setSegmentTitle:(NSString *)title atIndex:(NSUInteger)index;

/**
 sets an action that will be done on a target when 
 the segmented control changes values
 */
- (void)addTarget:(id)target action:(SEL)action;

- (NSUInteger)numberOfSegments;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setSubsegmentTitles:(NSArray *)subSegments forSection:(NSUInteger)index;

@end
