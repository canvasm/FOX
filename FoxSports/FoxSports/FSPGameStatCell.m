//
//  FSPGameStatCell.m
//  FoxSports
//
//  Created by Matthew Fay on 6/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameStatCell.h"
#import "FSPPlayer.h"

@implementation FSPGameStatCell

@synthesize requiredLabels = _requiredLabels;


- (void)populateWithPlayer:(FSPTeamPlayer *)player
{
    //MUST OVERWRITE
}

- (void)populateWithTeam:(FSPTeam *)team
{
    //NOT IN USE
}

@end
