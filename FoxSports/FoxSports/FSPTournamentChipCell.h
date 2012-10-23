//
//  FSPTournamentChip.h
//  FoxSports
//
//  Created by Laura Savino on 1/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventChipCell.h"

@class FSPLabel;

@interface FSPTournamentChipCell : FSPEventChipCell

@property (weak, nonatomic, readonly) FSPLabel *tournamentTitleLabel;
@property (weak, nonatomic, readonly) FSPLabel *tournamentSubtitleLabel;
@property (weak, nonatomic, readonly) FSPLabel *locationLabel;

@end
