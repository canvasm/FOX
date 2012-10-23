//
//  FSPGameTopPlayersView.h
//  FoxSports
//
//  Created by Matthew Fay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventDetailSectionManaging.h"

extern CGFloat const FSPGameTopPlayerHeightOffsetIPad;
extern CGFloat const FSPGameTopPlayerHeightOffsetIPhone;

@interface FSPGameTopPlayersViewContainer : UIView <FSPEventDetailSectionManaging>

- (void)updateContainer;
@end
