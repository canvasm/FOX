//
//  FSPEventDetailDropdownView.h
//  FoxSports
//
//  Created by greay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPDropDownView.h"

@class FSPSegmentedNavigationControl;

@interface FSPEventDetailDropdownView : FSPDropDownView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) FSPSegmentedNavigationControl *navigationControl;
@property (nonatomic, assign) NSUInteger selectedOptionIndex;
@property (nonatomic, assign) NSUInteger selectedSuboptionIndex;

- (void)insertOptionWithTitle:(NSString *)title atIndex:(NSUInteger)index;
- (void)removeOptionAtIndex:(NSUInteger)option;
- (void)removeAllOptions;
- (void)setOptionTitle:(NSString *)title atIndex:(NSUInteger)index;

- (NSUInteger)numberOfOptions;
- (NSString *)titleForOptionAtIndex:(NSUInteger)segment;

- (void)setSubOptions:(NSArray *)subOptions forSection:(NSUInteger)section;

@end
