//
//  FSPSoccerMatchStatsCell.h
//  FoxSports
//
//  Created by Matthew Fay on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPSoccerGame;

@interface FSPSoccerMatchStatsCell : UITableViewCell

- (void)populateCellWithIndex:(NSUInteger)idx forSoccerGame:(FSPSoccerGame *)game;

+ (CGFloat)heightForSoccerGame:(FSPSoccerGame *)game atIndex:(NSUInteger)idx;

@end
