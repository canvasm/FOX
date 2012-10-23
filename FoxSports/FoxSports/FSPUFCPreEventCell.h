//
//  FSPUFCPreEventCell.h
//  FoxSports
//
//  Created by Rowan Christmas on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPUFCPreEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *fightProgress;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneName;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoName;

@property (weak, nonatomic) IBOutlet UIImageView *fighterOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *fighterTwoImage;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneNick;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoNick;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneWLD;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoWLD;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneHeight;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoHeight;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneWeight;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoWeight;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneReach;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoReach;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneAge;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoAge;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneHometown;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoHometown;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneFightsOutOf;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoFightsOutOf;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneStrikesLandedPerMinute;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoStrikesLandedPerMinute;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneStrikingAccuracy;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoStrikingAccuracy;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneStrikesAbsorbedPerMinute;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoStrikesAbsorbedPerMinute;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneStrikeDefense;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoStrikeDefense;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneTakedownAverage;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoTakedownAverage;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneTakedownAccuracy;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoTakedownAccuracy;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneTakedownDefense;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoTakedownDefense;

@property (weak, nonatomic) IBOutlet UILabel *fighterOneSubmissionAverage;
@property (weak, nonatomic) IBOutlet UILabel *fighterTwoSubmissionAverage;

@end
