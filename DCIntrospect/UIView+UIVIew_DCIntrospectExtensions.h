//
//  UIView+UIVIew_DCIntrospectExtensions.h
//  DCIntrospectDemo
//
//  Created by Adam McLain on 4/24/12.
//

#import <UIKit/UIKit.h>

@interface UIView (UIVIew_DCIntrospectExtensions)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
@end
