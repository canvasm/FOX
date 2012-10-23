//
//  UIView+UIVIew_DCIntrospectExtensions.m
//  DCIntrospectDemo
//
//  Created by Adam McLain on 4/24/12.
//

#import "UIView+UIVIew_DCIntrospectExtensions.h"

@implementation UIView (UIVIew_DCIntrospectExtensions)

- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end
