//
//  UIView+FSPExtensions.m
//  FoxSports
//
//  Created by Laura Savino on 3/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "UIView+FSPExtensions.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIView (FSPExtensions)

- (UIImage *)fsp_reflectionImageWithHeight:(CGFloat)reflectionHeight;
{
    CGRect imageRect = self.frame;
    //Get area of image to reflect
    CGSize reflectionSize = CGSizeMake(imageRect.size.width, imageRect.size.height);
    UIGraphicsBeginImageContextWithOptions(reflectionSize, NO, 0.0);
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(graphicsContext, 0, imageRect.size.height);
    CGContextScaleCTM(graphicsContext, 1.0, -1.0);    
    [self.layer renderInContext:graphicsContext];
    UIImage *reflectionImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef reflectionCGImage = reflectionImage.CGImage;

    UIGraphicsEndImageContext();

    CGRect imageToReflectRect = CGRectMake(0, 0, imageRect.size.width, reflectionHeight);
    CGImageRef reflectionCroppedCGImage = CGImageCreateWithImageInRect(reflectionCGImage, imageToReflectRect);
    
    //Create gradient mask for reflection
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef gradientContext = CGBitmapContextCreate(NULL, 1.0, reflectionHeight, 8, 0, colorSpace, kCGImageAlphaNone);

    CGFloat components[] = {0.0, 0.5, 0.8, 0.5};
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef reflectionGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);

    CGPoint gradientStartPoint = CGPointMake(0.0, 0.0);
    CGPoint gradientEndPoint = CGPointMake(0.0, reflectionHeight);
    CGContextDrawLinearGradient(gradientContext, reflectionGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGImageRef gradientMaskImage = CGBitmapContextCreateImage(gradientContext);

    UIGraphicsBeginImageContextWithOptions(imageToReflectRect.size, NO, 0.0);
    CGContextRef mainContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(mainContext, 0, reflectionHeight);
    CGContextScaleCTM(mainContext, 1.0, -1.0);    
    CGImageRef clippedImageRef = CGImageCreateWithMask(reflectionCroppedCGImage, gradientMaskImage);
    UIGraphicsEndImageContext();

    CGGradientRelease(reflectionGradient);
    CGContextRelease(gradientContext);
    CGImageRelease(gradientMaskImage);
    CGImageRelease(reflectionCroppedCGImage);
    
    UIImage *reflection = [UIImage imageWithCGImage:clippedImageRef];
    CGImageRelease(clippedImageRef);
    
    
    return reflection;
}

- (void)fsp_drawReflectionWithHeight:(CGFloat)height inLayer:(CALayer *)destinationLayer;
{
    destinationLayer.contents = nil;
    UIImage *reflectionImage = [self fsp_reflectionImageWithHeight:height];
    CGRect imageToReflectFrame = self.frame;
    destinationLayer.frame = CGRectMake(imageToReflectFrame.origin.x, CGRectGetMaxY(imageToReflectFrame), imageToReflectFrame.size.width, height);
    destinationLayer.contents = (id)[reflectionImage CGImage];
}


@end
