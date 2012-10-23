//
//  FSPTveViewController.h
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/9/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPTveViewController : UIViewController
@property (nonatomic, retain) FSPTveViewController *previousViewController;

// Allows setting of custom back button title for this view.  This is actuall
// set on the previousViewController
- (void)setBackBarButtonItemTitle:(NSString *)title;
- (void)closeModal;
@end
