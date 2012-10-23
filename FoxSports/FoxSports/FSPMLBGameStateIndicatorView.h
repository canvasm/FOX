//
//  FSPMLBGameStateIndicatorView.h
//  FoxSports
//
//  Created by greay on 6/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    FSPFirstBaseRunner = 1 << 0,
    FSPSecondBaseRunner = 1 << 1,
    FSPThirdBaseRunner = 1 << 2
};
typedef NSInteger FSPBaseRunners;

@class FSPBaseballGame;

@interface FSPMLBGameStateIndicatorView : UIView

- (void)populateWithGame:(FSPBaseballGame *)game;

/**
 A bit mask of runners
 */
@property (nonatomic) NSInteger baseRunnersMask;

@property (nonatomic) NSUInteger outs;
@property (nonatomic) NSUInteger balls;
@property (nonatomic) NSUInteger strikes;



@end
