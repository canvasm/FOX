//
//  FSPGameChip.h
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventChipCell.h"
#import "FSPLabel.h"

enum {
    FSPHomeTeamPossession = 0,
    FSPAwayTeamPossession,
    FSPNoTeamPossession
};
typedef NSInteger FSPPossessionIndication;



@interface FSPGameChipCell : FSPEventChipCell

/**
 Indicates which team currently has possession.
 */
@property (nonatomic) FSPPossessionIndication teamPossession;

// Home Team
@property (nonatomic, weak, readonly) FSPLabel *homeTeamLabel;
@property (nonatomic, weak, readonly) FSPLabel *homeTeamScoreLabel;

// Away Team
@property (nonatomic, weak, readonly) FSPLabel *awayTeamLabel;
@property (nonatomic, weak, readonly) FSPLabel *awayTeamScoreLabel;




@end
