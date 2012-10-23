//
//  FSPScheduleViewController.h
//  FoxSports
//
//  Created by greay on 4/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPOrganization.h"

@class FSPScheduleHeaderView;

@interface FSPScheduleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) FSPOrganization *organization;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

//consider locking in the future
//this is shared by both the UI and a processing operation
@property (nonatomic, strong) NSArray *scheduleArray;
@property (nonatomic, strong) NSMutableArray *reorderedScheduleArray;

@property (assign) BOOL hasScrolledToToday;
- (void)scrollToToday;

+ (id)scheduleViewControllerWithOrganization:(FSPOrganization *)org managedObjectContext:(NSManagedObjectContext *)context;
+ (FSPViewType)viewTypeForOrganization:(FSPOrganization *)org;
- (id)initWithOrganization:(FSPOrganization *)org managedObjectContext:(NSManagedObjectContext *)context;
- (void)updateSchedule;

- (FSPScheduleHeaderView *)dequeueHeader;
- (void)enqueueHeader:(FSPScheduleHeaderView *)header;

@end
