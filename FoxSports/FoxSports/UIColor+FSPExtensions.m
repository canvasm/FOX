//
//  UIColor+FSPExtensions.m
//  FoxSports
//
//  Created by Laura Savino on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "UIColor+FSPExtensions.h"

@implementation UIColor (FSPExtensions)

+ (UIColor *) fsp_colorWithIntegralRed:(NSInteger)red green:(NSInteger)green
  blue:(NSInteger)blue alpha:(CGFloat)alpha;
{
    CGFloat redFloat = (float)red / 255;
    CGFloat greenFloat = (float)green / 255;
    CGFloat blueFloat = (float)blue / 255;
    return [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:alpha];
}

+ (UIColor *) fsp_colorWithHexString:(NSString *)hexString;
{
    
    hexString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  
    
    if ([hexString length] == 3) {
        // Expand it
        hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2]];
    } 
    
    if ([hexString hasPrefix:@"0X"])
        hexString = [hexString substringFromIndex:2];
    
    if ([hexString length] != 6)
        return nil;
    
    
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2;  
    NSString *rString = [hexString substringWithRange:range];  
    
    range.location = 2;  
    NSString *gString = [hexString substringWithRange:range];  
    
    range.location = 4;  
    NSString *bString = [hexString substringWithRange:range];  
    
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
    
    return [UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0];
}

+ (UIColor *) fsp_randomColor;
{
    CGFloat randRed = ((arc4random() % 255) / 255.0f);
    CGFloat randGreen = ((arc4random() % 255) / 255.0f);
    CGFloat randBlue = ((arc4random() % 255) / 255.0f);
    
    return [UIColor colorWithRed:randRed green:randGreen blue:randBlue alpha:1.0f];
}

+ (UIColor *)fsp_mediumBlueColor;
{
    return [UIColor fsp_colorWithIntegralRed:128 green:180 blue:255 alpha:1.0];
}

+ (UIColor *)fsp_lightMediumBlueColor;
{
    return [UIColor fsp_colorWithIntegralRed:146 green:197 blue:255 alpha:1.0];
}
+ (UIColor *)fsp_lightBlueColor;
{
    return [UIColor fsp_colorWithIntegralRed:197 green:244 blue:255 alpha:1.0];
}

+ (UIColor *)fsp_yellowColor;
{
    return [UIColor fsp_colorWithIntegralRed:252 green:178 blue:0 alpha:1.0];
}

+ (UIColor *)fsp_blackDropShadowColor;
{
    return [UIColor fsp_colorWithIntegralRed:0 green:0 blue:0 alpha:0.5];
}

+ (UIColor *)fsp_lightGrayColor;
{
    return [UIColor fsp_colorWithIntegralRed:221 green:221 blue:221 alpha:1.0];
}

+ (UIColor *)chipTextShadowSelectedColor;
{
    return [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:0.8];
}

+ (UIColor *)chipTextShadowUnselectedColor;
{
    return [UIColor colorWithWhite:1.0 alpha:0.8];
}

+ (UIColor *)fsp_darkBlueColor
{
    return [UIColor fsp_colorWithIntegralRed:17 green:70 blue:133 alpha:1.0];
}
+ (UIColor *)fsp_extraDarkBlueColor
{
    return [UIColor fsp_colorWithIntegralRed:4 green:31 blue:61 alpha:1.0];
}

+ (UIColor *)fsp_newsRegionSelectionColor
{
    return [UIColor fsp_colorWithIntegralRed:38 green:134 blue:255 alpha:1.0];
}

+ (UIColor *)fsp_blueCellColor
{
    return [UIColor fsp_colorWithIntegralRed:23 green:93 blue:195 alpha:1.0];
}

+ (UIColor *)fsp_topEtchColor
{
    return [UIColor fsp_colorWithIntegralRed:4 green:31 blue:61 alpha:1.0];
}

+ (UIColor *)fsp_bottomEtchColor
{
    return [UIColor fsp_colorWithIntegralRed:18 green:80 blue:152 alpha:1.0];
}

@end
