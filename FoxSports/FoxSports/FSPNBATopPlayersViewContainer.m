//
//  FSPNBATopPlayersView.m
//  FoxSports
//
//  Created by Laura Savino on 3/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBATopPlayersViewContainer.h"
#import "FSPGameTopPlayerView.h"
#import "FSPBasketballPlayer.h"
#import "FSPTeam.h"
#import "FSPTeamColorLabel.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import <QuartzCore/QuartzCore.h>

@interface FSPNBATopPlayersViewContainer ()

@end

@implementation FSPNBATopPlayersViewContainer

@synthesize topPointsPlayer = _topPointsPlayer;
@synthesize topReboundsPlayer = _topReboundsPlayer;
@synthesize topAssistsPlayer = _topAssistsPlayer;

@synthesize topPointsPlayerView = _topPointsPlayerView;
@synthesize topReboundsPlayerView = _topReboundsPlayerView;
@synthesize topAssistsPlayerView = _topAssistsPlayerView;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.topPointsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        self.topReboundsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        self.topAssistsPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
        
        [self addSubview:self.topPointsPlayerView];
        [self addSubview:self.topReboundsPlayerView];
        [self addSubview:self.topAssistsPlayerView];
    }
    
    return self;
}

- (void)updateContainer
{
    //TODO: make all the top player views accessed from here
//    self.topPerformersTitleLabel.text = @"Top Performers";
//    
//    self.topPointsPlayerView.frame = CGRectMake(0, 35, self.topPointsPlayerView.bounds.size.width, self.topPointsPlayerView.bounds.size.height);
//    self.topReboundsPlayerView.frame = CGRectMake(self.topReboundsPlayerView.bounds.size.width, 35, self.topReboundsPlayerView.bounds.size.width, self.topReboundsPlayerView.bounds.size.height);
//    self.topAssistsPlayerView.frame = CGRectMake(self.topAssistsPlayerView.bounds.size.width * 2, 35, self.topAssistsPlayerView.bounds.size.width, self.topAssistsPlayerView.bounds.size.height);
//    
//    [self.topPointsPlayerView populateWithPlayer:self.topPointsPlayer statString:[NSString stringWithFormat:@"%@ Pts", self.topPointsPlayer.points] title:@"Points"];
//
//    [self.topReboundsPlayerView populateWithPlayer:self.topReboundsPlayer statString:[NSString stringWithFormat:@"%@ Rebs", self.topReboundsPlayer.rebounds] title:@"Rebounds"];
//    
//    [self.topAssistsPlayerView populateWithPlayer:self.topAssistsPlayer statString:[NSString stringWithFormat:@"%@ Ast", self.topAssistsPlayer.assists] title:@"Assists"];

}

@end
