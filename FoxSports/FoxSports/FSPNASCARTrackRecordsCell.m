//
//  FSPNASCARTrackRecordsCell.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARTrackRecordsCell.h"
#import "FSPRacingTrackRecords.h"
#import "FSPRacingEvent.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPNASCARTrackRecordsCell ()
@property (nonatomic, weak, readwrite) IBOutlet UILabel *raceName;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *trackRecord;
@end
@implementation FSPNASCARTrackRecordsCell

@synthesize raceName = _raceName;
@synthesize trackRecord = _trackRecord;

- (void)awakeFromNib
{
    self.raceName.textColor = [UIColor fsp_lightBlueColor];
    self.raceName.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    
    self.trackRecord.textColor = [UIColor fsp_lightBlueColor];
    self.trackRecord.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
}
- (void)populateWithRace:(FSPRacingTrackRecords *)trackRecord
{
    self.raceName.text = [NSString stringWithFormat:@"%@:",trackRecord.recordName];
    self.trackRecord.text = [NSString stringWithFormat:@"%@ by %@, %@",trackRecord.recordValue, trackRecord.recordHolder, trackRecord.recordAchievedDate];
}

@end
