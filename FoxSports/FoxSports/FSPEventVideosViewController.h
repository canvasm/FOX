//
//  FSPEventVideosViewController.h
//  FoxSports
//
//  Created by Stephen Spring on 6/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"

@class FSPEvent;

@interface FSPEventVideosViewController : UIViewController <FSPExtendedEventDetailManaging>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) FSPEvent *currentEvent;

@end
