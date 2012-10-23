//
//  FSPFontViewController.h
//  FoxSports
//
//  Created by greay on 5/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPFontViewController;
@protocol FSPFontViewControllerDelegate <NSObject>

#define FSP_SMALL_FONT_SIZE (14)
#define FSP_MEDIUM_FONT_SIZE (16)
#define FSP_LARGE_FONT_SIZE (18)

- (void)fontViewController:(FSPFontViewController *)viewController didSelectFontSize:(CGFloat)fontSize;

@end


@interface FSPFontViewController : UIViewController

- (void)updateFontButton;

@property (nonatomic, weak) id <FSPFontViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *smallFontButton;
@property (weak, nonatomic) IBOutlet UIButton *mediumFontButton;
@property (weak, nonatomic) IBOutlet UIButton *largeFontButton;

@end
