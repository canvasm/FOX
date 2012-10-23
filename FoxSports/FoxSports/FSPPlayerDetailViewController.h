//
//  FSPPlayerDetailViewController.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPPlayerDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *valueLabels;
@property (weak, nonatomic) IBOutlet UIImageView *headshotImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) UINib *playerStandingsNib;

/*!
 @abstract Dismisses the view controller when presented modally.
 @param sender The button the action is assosciated with.
 */
- (IBAction)closeDetailViewController:(id)sender;

/*!
 @abstract Sets the fonts and text colors on the view's labels.
 */
- (void)styleLabels;

@end
