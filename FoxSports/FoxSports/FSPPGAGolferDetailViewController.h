//
//  FSPPGAGolferDetailViewController.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPPlayerDetailViewController.h"

@class FSPGolfer;

@interface FSPPGAGolferDetailViewController : FSPPlayerDetailViewController

@property (strong, nonatomic) FSPGolfer *golfer;

- (void)populateWithGolfer;

@end
