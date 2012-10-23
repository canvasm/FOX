//
//  FSPDarkBlueSegmentedControl.h
//  FoxSports
//
//  Created by Laura Savino on 5/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSegmentedControl.h"
#import "FSPExtendedEventDetailManaging.h"

@interface FSPSecondarySegmentedControl : FSPSegmentedControl
@property (nonatomic, assign) IBOutlet id <FSPExtendedEventDetailManaging> parentDetailView;

@end

/*
@interface FSPSecondarySegmentedControl : UISegmentedControl

@property (nonatomic, assign) IBOutlet id <FSPExtendedEventDetailManaging> parentDetailView;

- (void)showSelectedSegmentAtIndex:(NSInteger)index;

@end
*/