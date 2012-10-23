//
//  FSPLeaderboardSectionHeaderView.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPLeaderboardSectionHeaderView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *headerLabels;

/*!
 @abstract Adds the top dark blue section and title label to the header view.
 */
- (void)addTopView;

/*!
 @abstract Adds top and bottom etches to top blue section of header view along with setting the font and text color for the colum labels.
 */
- (void)styleHeader;

@end
