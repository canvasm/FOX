//
//  FSPMLBLineScoreBox.h
//  FoxSports
//
//  Created by greay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLineScoreBox.h"

@interface FSPMLBLineScoreBox : FSPLineScoreBox

@property (nonatomic, strong) FSPGameSegmentView *totalRunsView;
@property (nonatomic, strong) FSPGameSegmentView *totalHitsView;
@property (nonatomic, strong) FSPGameSegmentView *totalErrorsView;


@end
