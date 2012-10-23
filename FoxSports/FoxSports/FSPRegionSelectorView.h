//
//  FSPRegionSelectorView.h
//  FoxSports
//
//  Created by Stephen Spring on 7/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPRegionSelectorView : UIView

@property (weak, nonatomic) IBOutlet UIButton *selectRegionButton;
@property (weak, nonatomic) IBOutlet UILabel *selectedRegionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gradientImageView;

- (void)swapColor:(BOOL)selected;

@end
