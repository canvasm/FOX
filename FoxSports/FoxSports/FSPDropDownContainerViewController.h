//
//  FSPDropDownContainerViewController.h
//  FoxSports
//
//  Created by Steven Stout on 7/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPDropDownMenu.h"

extern NSString * const FSPDropDownToggleHideLabel;
extern NSString * const FSPDropDownToggleShowLabel;
extern NSString * const FSPDropDownExtendedKey;

@protocol FSPDropDownContainerViewControllerDelegate;

@interface FSPDropDownContainerViewController : UIViewController <FSPDropDownMenuDelegate>


/**
 * The delegate that responds to changes in the drop down menu state.
 */
@property (nonatomic, weak) id <FSPDropDownContainerViewControllerDelegate> dropDownContainerDelegate;

@property (nonatomic, strong) UIViewController *subViewController;
@property (nonatomic, strong) FSPDropDownMenu *dropDownMenu;
@property (nonatomic, readonly) BOOL isDropDownMenuExtended;


- (void)setDropDownMenuExtended:(BOOL)extended animated:(BOOL)animated;

/**
 * Subclasses should return an NSArray of FSPDropDownMenuItems.
 */
- (NSArray *)dropDownSections;

/**
 * Subclasses should return an NSArray of FSPDropDownMenuItems.
 */
- (NSArray *)dropDownSegments;

- (void)setupDropdown;

@end


@protocol FSPDropDownContainerViewControllerDelegate <NSObject>

- (void)dropDownContainerViewController:(FSPDropDownContainerViewController *)viewController didChangeDropDownMenuState:(BOOL)showMenu;

@end
