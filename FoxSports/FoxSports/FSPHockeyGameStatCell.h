//
//  FSPHockeyGameStatCell.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameStatCell.h"

extern NSString * const FSPHockeyPlayerStatCellReuseIdentifier;

typedef enum {
    FSPHockeyGameStatCellTypeSkater = 0,
    FSPHockeyGameStatCellTypeGoaltender
} FSPHockeyGameStatCellType;

@interface FSPHockeyGameStatCell : FSPGameStatCell

/*!
 @abstract Initializes an instance to display proper stats for type of hockey player.
 @param type The type of cell to create.
 */
- (id)initWithType:(FSPHockeyGameStatCellType)type;

@end
