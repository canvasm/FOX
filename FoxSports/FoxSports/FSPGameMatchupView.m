//
//  FSPGameMatchupView.m
//  FoxSports
//
//  Created by Matthew Fay on 6/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameMatchupView.h"

@implementation FSPGameMatchupView

@synthesize informationComplete = _informationComplete;
@synthesize matchupTitleLabels;
@synthesize matchupValueLabels;
@synthesize sectionHeader;
@synthesize awayTeamLabel;
@synthesize homeTeamLabel;

- (void)updateInterfaceWithGame:(FSPGame *)game;
{
    [NSException raise:@"FSPGameMatchupView Updated" format:@"FSPGameMatchupView's updateInterfaceWithGame: must be over written"];
}

@end
