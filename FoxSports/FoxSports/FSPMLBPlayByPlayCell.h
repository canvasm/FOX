//
//  FSPMLBPlayByPlayCell.h
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayByPlayCell.h"

@class FSPMLBPlayByPlayGameStateView;

@interface FSPMLBPlayByPlayCell : FSPPlayByPlayCell

@property (nonatomic, weak) IBOutlet FSPMLBPlayByPlayGameStateView *gameStateView;

@end
