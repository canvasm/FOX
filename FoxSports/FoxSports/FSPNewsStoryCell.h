//
//  FSPNewsStoryCell.h
//  FoxSports
//
//  Created by greay on 5/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSPEventChipCell.h"

@class FSPLabel;
@class FSPNewsHeadline;
@class FSPVideo;

@interface FSPNewsStoryCell : FSPEventChipCell

@property (nonatomic, weak) IBOutlet FSPLabel *storyLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (void)populateWithHeadline:(FSPNewsHeadline *)headline;
- (void)populateWithVideo:(FSPVideo *)video;

@end
