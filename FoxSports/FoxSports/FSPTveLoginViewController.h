//
//  FSPTveLoginViewController.h
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/3/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPTveAuthManager.h"
#import "FSPTveViewController.h"

@interface FSPTveLoginViewController : FSPTveViewController <FSPTveAuthManagerDelegate>

@property (nonatomic, strong) NSArray *providers;

@end
