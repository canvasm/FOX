//
//  FSPUFCFightTraxViewController.h
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-05.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"
#import "FSPUFCFighterProfilePopoverView.h"
#import "FSPExtendedEventDetailManaging.h"
#import "FSPUFCFightDetailsView.h"

@interface FSPUFCFightTraxViewController : UIViewController <FSPExtendedEventDetailManaging, UIPopoverControllerDelegate>

@property (nonatomic, strong) FSPUFCFightDetailsView *fightDetailsView;

- (void)updateCurrentFighterProfiles:(FSPUFCFight *)fight;

@end