//
//  FSPExtendedEventDetailManaging.h
//  FoxSports
//
//  Created by Chase Latta on 1/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSPEvent;
@class NSManagedObjectContext;
@class FSPSegmentedControl;

/**
 Defines interface expected of view controllers accessed via an FSPGameSegmentedControlContainer.
 */
@protocol FSPExtendedEventDetailManaging <NSObject>

@required


/**
 The event whose details are displayed by extended detail view controllers.
 */
@property (nonatomic, strong) FSPEvent *currentEvent;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@optional
- (FSPSegmentedControl *)segmentedControl;
- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event;
- (void)selectGameDetailViewAtIndex:(NSUInteger)index;

@end
