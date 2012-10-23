//
//  FSPGameStatCell.h
//  FoxSports
//
//  Created by Matthew Fay on 6/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPPlayer;
@class FSPTeamPlayer;
@class FSPTeam;

@interface FSPGameStatCell : UITableViewCell

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *requiredLabels;

- (void)populateWithPlayer:(FSPTeamPlayer *)player;

/**
 * Populates cell's subviews with information about a specific team.
 * TODO: NOT IMPLEMENTED.
 */
- (void)populateWithTeam:(FSPTeam *)team;

@end
