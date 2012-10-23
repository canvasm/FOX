//
//  FSPEventChip.h
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPEvent;
@class FSPEventChipHeader;

// An abstract superclass for all event chips
@interface FSPEventChipCell : UITableViewCell

@property (nonatomic, weak, readonly) FSPEventChipHeader *header;

@property (nonatomic, readonly) BOOL isStreamable;
@property (nonatomic, readonly) BOOL isInProgress;

// TODO: remove these temp ad properties
@property (nonatomic) BOOL isAdView;
@property (nonatomic, weak) IBOutlet UIView *adView;


// Subclasses must implement this method
+ (void)registerSelfWithTableView:(UITableView *)tableView forReuseIdentifier:(NSString *)reuseIdentifier;

- (void)populateCellWithEvent:(FSPEvent *)event;

- (NSString *)inProgressAccessibilityLabel;
- (NSString *)notInProgressAccessibilityLabel;

@end
