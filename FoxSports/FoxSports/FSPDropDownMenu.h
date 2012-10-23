//
//  FSPDropDownMenu.h
//  FoxSports
//
//  Created by Chase Latta on 3/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSPDropDownMenuDelegate;

@interface FSPDropDownMenu : UIView <UITableViewDelegate,  UITableViewDataSource>
@property (nonatomic, weak) id <FSPDropDownMenuDelegate> delegate;
@property (nonatomic, copy) NSArray *segments;

/**
 Returns the height of the sections.
 */
@property (nonatomic, readonly) CGFloat sectionsHeight;

+ (id)dropDownMenuWithSections:(NSArray *)sectionItems segments:(NSArray *)segmentItems;

/**
 Initialize the menu with a list of sections to display and a list of names to show in
 the segmented control.
 */
- (id)initWithSections:(NSArray *)sectionItems segments:(NSArray *)segmentItems;

/**
 changes the title of the specified index
 */
- (void)updateSectionName:(NSString *)sectionName atIndex:(NSInteger)index;

/**
 Reloads the specified section.
 */
- (void)reloadSectionAtIndex:(NSInteger)index;

/**
 changes the segment items.
 */
- (void)updateSegments:(NSArray *)segmentItems;

/**
 Sets the currently selected segment on the segmented control.
 */
- (void)setSelectedSegmentIndex:(NSInteger)index;

@end


@protocol FSPDropDownMenuDelegate <NSObject>

/**
 Notifies the delegate that a section was selected.
 */
@optional
- (void)dropDownMenu:(FSPDropDownMenu *)menu didSelectSectionAtIndex:(NSInteger)index;

/**
 Notifies the delegate that the segment did change.
 */
@optional
- (void)dropDownMenu:(FSPDropDownMenu *)menu didSelectSegmentAtIndex:(NSInteger)index;

@optional
- (UIImage *)dropDownMenu:(FSPDropDownMenu *)menu iconForSectionAtIndex:(NSInteger)index;

@end
