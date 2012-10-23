//
//  FSPSoccerMatchupHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 8/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerMatchupHeaderView.h"
#import "FSPGameDetailTeamHeader.h"

@interface FSPSoccerMatchupHeaderView()

@end

@implementation FSPSoccerMatchupHeaderView

- (id)initWithFrame:(CGRect)frame
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPSoccerMatchupHeaderView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    return self;
}

@end
