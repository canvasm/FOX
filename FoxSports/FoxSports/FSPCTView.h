//
//  FSPCTView.h
//  FoxSports
//
//  Created by greay on 5/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPCTView : UIView

@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign, readonly) CGSize contentSize;

@end
