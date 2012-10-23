//
//  FSPNASCARDriverDetailViewController.h
//  FoxSports
//
//  Created by Stephen Spring on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPPlayerDetailViewController.h"

@class FSPRacingPlayer;

@interface FSPNASCARDriverDetailViewController : FSPPlayerDetailViewController

/*!
 @abstract The driver to display in the driver detail view.
 @param driver The driver to display in the driver detail view.
 */
@property (strong, nonatomic) FSPRacingPlayer *driver;

@end
