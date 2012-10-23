//
//  FSPGameMatchupView.h
//  FoxSports
//
//  Created by Matthew Fay on 6/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventDetailSectionManaging.h"

@class FSPGameDetailSectionHeader;

/**
 * This view is just a placeholder, it is NOT to be instantiated
 */
@interface FSPGameMatchupView : UIView <FSPEventDetailSectionManaging>

@property (weak, nonatomic) IBOutlet UILabel *awayTeamLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic, weak) IBOutlet FSPGameDetailSectionHeader *sectionHeader;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *matchupTitleLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *matchupValueLabels;

/**
 * Sets properties on subviews from a given game.
 */
- (void)updateInterfaceWithGame:(FSPGame *)game;

@end
