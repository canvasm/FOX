//
//  FSPEventsContainerViewController.h
//  FoxSports
//
//  Created by Steven Stout on 7/3/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPChipsContainerViewController.h"

@class FSPOrganization;


@interface FSPEventsContainerViewController : FSPChipsContainerViewController

@property (nonatomic, strong) FSPOrganization *organization;

/**
 The designated initializer.
 */
- (id)initWithOrganization:(FSPOrganization *)organization;

@end


