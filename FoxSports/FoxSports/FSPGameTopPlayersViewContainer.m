//
//  FSPGameTopPlayersView.m
//  FoxSports
//
//  Created by Matthew Fay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameTopPlayersViewContainer.h"
#import "FSPGameTopPlayerView.h"

CGFloat const FSPGameTopPlayerHeightOffsetIPad = 15;
CGFloat const FSPGameTopPlayerHeightOffsetIPhone = 4;


@implementation FSPGameTopPlayersViewContainer
@synthesize informationComplete = _informationComplete;

- (void)updateContainer
{
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat subviewHeight = 0;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[FSPGameTopPlayerView class]]) {
            subviewHeight = subview.frame.size.height;
            break;
        };
    }
    
    CGFloat topPlayerHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? FSPGameTopPlayerHeightOffsetIPad :FSPGameTopPlayerHeightOffsetIPhone;
    
    return CGSizeMake(size.width, subviewHeight + topPlayerHeight);
}

@end
