//
//  UIColor+FSPExtensions.h
//  FoxSports
//
//  Created by Laura Savino on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (FSPExtensions)

/**
 * Returns a UIColor based on 255-255-255 RGB scale
 */
+ (UIColor *) fsp_colorWithIntegralRed:(NSInteger)red green:(NSInteger)green
  blue:(NSInteger)blue alpha:(CGFloat)alpha;

+ (UIColor *) fsp_colorWithHexString:(NSString *)hexString;

+ (UIColor *) fsp_randomColor;

/**
 * RGB 128, 180, 255
 */
+ (UIColor *)fsp_mediumBlueColor;

/**
 * RGB 146, 197, 255
 */
+ (UIColor *)fsp_lightMediumBlueColor;

/**
 * RGB 197, 244, 255
 */
+ (UIColor *)fsp_lightBlueColor;

/**
 * RGB 252, 178, 0
 */
+ (UIColor *)fsp_yellowColor;

/**
 * RGB 0, 0, 0, alpha 0.5
 */
+ (UIColor *)fsp_blackDropShadowColor;

/**
 * RGB 52, 127, 197
 */
+ (UIColor *)fsp_lightGrayColor;

// rgb(46, 83, 122, 0.8)
+ (UIColor *)chipTextShadowSelectedColor;

// (1, 0.8)
+ (UIColor *)chipTextShadowUnselectedColor;


// RGB 17, 70, 133
+ (UIColor *)fsp_darkBlueColor;

// RGB 38, 134, 225
+ (UIColor *)fsp_newsRegionSelectionColor;

// RGB 23, 93, 195
+ (UIColor *)fsp_blueCellColor;

// RGB 4, 31, 61
+ (UIColor *)fsp_topEtchColor;

// RGB 18, 80, 152
+ (UIColor *)fsp_bottomEtchColor;


@end
