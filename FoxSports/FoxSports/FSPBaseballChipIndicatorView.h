//
//  FSPBaseballChipIndicatorView.h
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FSPFirstBaseRunner = 1 << 0,
    FSPSecondBaseRunner = 1 << 1,
    FSPThirdBaseRunner = 1 << 2
};
typedef NSInteger FSPBaseRunners;

@interface FSPBaseballChipIndicatorView : UIView

@property (nonatomic) BOOL selected;

/**
 A bit mask of runners
 */
@property (nonatomic) NSInteger baseRunnersMask;

/**
 The number of outs
 */
@property (nonatomic) NSUInteger outs;

/**
 A string describing the runners.
 No Runners on base, Runners on first, Runners on first and second ...
 */
- (NSString *)runnersString;

@end
