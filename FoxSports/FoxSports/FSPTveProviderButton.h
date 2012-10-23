//
//  FSPTveProviderButton.h
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/3/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVPD.h"

@interface FSPTveProviderButton : UIButton

@property (nonatomic, retain) MVPD *provider;
@end
