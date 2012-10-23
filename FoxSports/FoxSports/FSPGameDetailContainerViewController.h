//
//  FSPGameDetailContainerViewController.h
//  FoxSports
//
//  Created by Joshua Dubey on 7/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPrimarySegmentedControl.h"
#import "FSPExtendedEventDetailManaging.h"

@class FSPEvent;
@interface FSPGameDetailContainerViewController : UIViewController <FSPExtendedEventDetailManaging>

@property (nonatomic,strong) IBOutlet FSPSegmentedControl *segmentedControl;

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)segmentedControlUpdate:(id)sender;
- (void)selectGameDetailViewAtIndex:(NSUInteger)index;

@end
