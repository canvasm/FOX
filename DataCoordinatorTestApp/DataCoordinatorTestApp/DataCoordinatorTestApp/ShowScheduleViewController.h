//
//  ShowScheduleViewController.h
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPOrganization;

@interface ShowScheduleViewController : UITableViewController
@property (nonatomic, strong) FSPOrganization *organization;

@end
