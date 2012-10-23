//
//  FSPMLBPlayByPlayGameStateView.h
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FSPFirstBaseRunner = 1 << 0,
    FSPSecondBaseRunner = 1 << 1,
    FSPThirdBaseRunner = 1 << 2
};
typedef NSInteger FSPBaseRunners;


@interface FSPMLBPlayByPlayGameStateView : UIView

/**
 A bit mask of runners
 */
@property (nonatomic) NSInteger baseRunnersMask;

/**
 The number of outs
 */
@property (nonatomic) NSUInteger outs;


@end
