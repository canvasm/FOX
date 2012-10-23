//
//  FSPChipsContainerViewController.h
//  FoxSports
//
//  Created by Steven Stout on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPDropDownContainerViewController.h"


@protocol FSPChipsContainerViewControllerDelegate;

@interface FSPChipsContainerViewController : FSPDropDownContainerViewController

/**
 * The delegate that responds to changes in the visibility of the chips.
 */
@property (nonatomic, weak) id <FSPChipsContainerViewControllerDelegate> chipsContainerDelegate;

/**
 * Whether the chips are offscreen. This currently applies to the iPhone only.
 */
@property (nonatomic, getter = isHidden, assign) BOOL hidden;

@end


@protocol FSPChipsContainerViewControllerDelegate <NSObject>

- (void)chipsContainerViewController:(FSPChipsContainerViewController *)viewController didPanWithGesture:(UIPanGestureRecognizer *)gesture;

/**
 * Shows or hides the chips container view controller.
 */
- (void)chipsContainerViewControllerToggleHidden:(FSPChipsContainerViewController *)viewController;

@end
