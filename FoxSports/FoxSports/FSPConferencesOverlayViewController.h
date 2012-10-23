//
//  FSPConferencesOverlayViewController.h
//  FoxSports
//
//  Created by greay on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPConferenceSelectorViewController.h"
#import "FSPConferencesOverlayContainerView.h"
#import "FSPConferencesOverlayCell.h"

@interface FSPConferencesOverlayViewController : FSPConferenceSelectorViewController <FSPConferencesOverlayCellDelegate>

@property (nonatomic, strong) UIViewController *overlayPresentingViewController;
@property (nonatomic, strong) FSPConferencesOverlayContainerView *overlay;

@end
