//
//  UILabel+FSPExtensions.h
//  FoxSports
//
//  Created by Laura Savino on 4/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FSPExtensions)

/**
 * If the label's text is nil or the empty string, sets the label text to @"--".
 */
- (void)fsp_indicateNoData;

@end
