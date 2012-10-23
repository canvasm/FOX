//
//  FSPNASCARTrackRecordsCell.h
//  FoxSports
//
//  Created by Joshua Dubey on 7/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPRacingTrackRecords;
@interface FSPNASCARTrackRecordsCell : UITableViewCell

@property (nonatomic, weak, readonly) UILabel *raceName;
@property (nonatomic, weak, readonly) UILabel *trackRecord;

- (void)populateWithRace:(FSPRacingTrackRecords *)race;
@end
