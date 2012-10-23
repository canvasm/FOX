//
//  FSPNBAInjuryReportCell.h
//  FoxSports
//
//  Created by Jason Whitford on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FSPInjuryReportCellIdentifier;

@class FSPPlayerInjury;

@interface FSPInjuryReportCell : UITableViewCell

@property(nonatomic, weak, readonly) IBOutlet UILabel *playerNameLabel;
@property(nonatomic, weak, readonly) IBOutlet UILabel *playerInjuryLabel;
@property(nonatomic, weak, readonly) IBOutlet UILabel *playerStatusLabel;

@property(nonatomic, weak, readonly) IBOutlet UILabel *playerNameLabelHome;
@property(nonatomic, weak, readonly) IBOutlet UILabel *playerInjuryLabelHome;
@property(nonatomic, weak, readonly) IBOutlet UILabel *playerStatusLabelHome;

@property (nonatomic, strong, readonly) NSArray *requiredDataLabels;

- (void)populateWithPlayerInjury:(FSPPlayerInjury *)playerInjury;
- (void)populateWithAwayPlayerInjury:(FSPPlayerInjury *)playerInjury homePlayerInjury:(FSPPlayerInjury *)homePlayerInjury;

@end
