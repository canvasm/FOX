//
//  FSPGameOddsView.h
//  FoxSports
//
//  Created by Matthew Fay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventDetailSectionManaging.h"

@interface FSPGameOddsView : UIView <FSPEventDetailSectionManaging>

/**
 * Sets properties on subviews from a given game.
 */
- (void)updateInterfaceWithGame:(FSPGame *)game;

@end
