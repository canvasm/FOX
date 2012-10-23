//
//  FSPNBAPreGameViewController.h
//  FoxSports
//
//  Created by Jason Whitford on 1/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"
#import "FSPStoryViewController.h"

@class FSPEvent;

@interface FSPGamePreGameViewController : UIViewController <FSPExtendedEventDetailManaging, FSPStoryViewDelegateProtocol>

- (void)updateViewPositions;
- (void)updateStoryView;
- (void)updateForEvent;

@end
