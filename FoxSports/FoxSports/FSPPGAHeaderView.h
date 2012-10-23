//
//  FSPPGAHeaderView.h
//  FoxSports
//
//  Created by Chase Latta on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPPGAEvent;

@interface FSPPGAHeaderView : UIView

/**
 Setting the PGAEvent will set all of the labels on the header.
 */
@property (nonatomic, strong) FSPPGAEvent *event;

/**
 Refreshing the event will cause the event to update itself and
 reset all of the header's labels.
 */
- (void)refreshEvent;

@end
