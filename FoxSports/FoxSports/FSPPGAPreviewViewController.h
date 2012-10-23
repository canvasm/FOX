//
//  FSPPGAPreviewViewController.h
//  FoxSports
//
//  Created by Laura Savino on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@class FSPEvent;
@class FSPPGAEvent;

@interface FSPPGAPreviewViewController : UIViewController <FSPExtendedEventDetailManaging>

/**
 * Initializes the view with a PGA event model.
 *
 * This is the designated initializer for the class
 */
- (id)initWithPGAEvent:(FSPPGAEvent *)event;

@end
