//
//  FSPEventDetailContainerViewController.h
//  FoxSports
//
//  Created by Steven Stout on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownContainerViewController.h"
#import "FSPEvent.h"

@interface FSPEventDetailContainerViewController : FSPDropDownContainerViewController

@property (nonatomic, strong) FSPEvent *event;

@end