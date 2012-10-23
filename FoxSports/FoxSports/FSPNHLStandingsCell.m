//
//  FSPNHLStandingsCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLStandingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

#define kConferencePlayoffThreshold 8

@interface FSPNHLStandingsCell()

@property (weak, nonatomic) IBOutlet UILabel *penaltyKillingLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerPlayAssistLabel;
@property (weak, nonatomic) IBOutlet UILabel *regulationOvertimeWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *overtimeLossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (nonatomic) FSPStandingsSegmentSelected standingsSegmentSelected;
@property (strong, nonatomic) UIView *playoffThresholdDividerView;

@end

@implementation FSPNHLStandingsCell

@synthesize penaltyKillingLabel;
@synthesize powerPlayAssistLabel;
@synthesize regulationOvertimeWinsLabel;
@synthesize pointsLabel;
@synthesize overtimeLossesLabel;
@synthesize gamesPlayedLabel;
@synthesize positionLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.pointsLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
}

- (void)populateWithTeam:(FSPTeam *)team conferenceType:(FSPStandingsSegmentSelected)standingsType
{
    [super populateWithTeam:team];
    
    self.team = team;
    self.standingsSegmentSelected = standingsType;
    self.gamesPlayedLabel.text = team.gamesPlayed ? team.gamesPlayed : @"--";
    self.overtimeLossesLabel.text = [team.overallRecord.ties stringValue] ?[team.overallRecord.ties stringValue] : @"--";
    self.pointsLabel.text = team.points ? team.points : @"--";
    self.regulationOvertimeWinsLabel.text = team.winTotal ? team.winTotal : @"--";
    self.powerPlayAssistLabel.text = team.powerPlayPercentage ? team.powerPlayPercentage : @"--";
    self.penaltyKillingLabel.text = team.penaltyKillPercentage ? team.penaltyKillPercentage : @"--";
    self.homeRecordLabel.text = [team.homeRecord winLossRecordString] ? [team.homeRecord winLossRecordString] : @"--";
    self.awayRecordLabel.text = [team.awayRecord winLossRecordString] ? [team.awayRecord winLossRecordString] : @"--";
    self.streakLabel.text = [NSString stringWithFormat:@"%@-%@-%@", [team.lastTenGamesRecord.wins stringValue], [team.lastTenGamesRecord.losses stringValue], [team.lastTenGamesRecord.ties stringValue]] ? [NSString stringWithFormat:@"%@-%@-%@", [team.lastTenGamesRecord.wins stringValue], [team.lastTenGamesRecord.losses stringValue], [team.lastTenGamesRecord.ties stringValue]] : @"--";
    
    if(!self.playoffThresholdDividerView) {
        [self addConferenceDividerView];
    }
    
    [self showConferenceRanking];
}

- (void)addConferenceDividerView
{
    CGFloat dividerHeight = 2.0;
    CGFloat etchHeight = 1.0;
    CGRect dividerFrame = CGRectMake(0.0, CGRectGetMaxY(self.frame), self.frame.size.width, dividerHeight);
    _playoffThresholdDividerView = [[UIView alloc] initWithFrame:dividerFrame];
    [self addSubview:_playoffThresholdDividerView];
    UIView *topEtch = [[UIView alloc] initWithFrame:CGRectMake(dividerFrame.origin.x, dividerFrame.origin.y, dividerFrame.size.width, 1.0)];
    topEtch.backgroundColor = [UIColor fsp_colorWithIntegralRed:191 green:191 blue:191 alpha:1.0];
    UIView *bottomEtch = [[UIView alloc] initWithFrame:CGRectMake(dividerFrame.origin.x, dividerFrame.origin.y + etchHeight, dividerFrame.size.width, etchHeight)];
    bottomEtch.backgroundColor = [UIColor whiteColor];
    [_playoffThresholdDividerView addSubview:topEtch];
    [_playoffThresholdDividerView addSubview:bottomEtch];
}

- (void)showConferenceRanking
{
    if (self.standingsSegmentSelected == FSPStandingsTypeConference && [self.team.conferenceRanking intValue] <= kConferencePlayoffThreshold) {
        self.rankLabel.text = [self.team.conferenceRanking stringValue];
    } else {
        self.rankLabel.text = @"";
    }
    
    if (self.standingsSegmentSelected == FSPStandingsTypeConference && [self.team.conferenceRanking intValue] == kConferencePlayoffThreshold - 1) {
        self.playoffThresholdDividerView.hidden = NO;
    } else {
        self.playoffThresholdDividerView.hidden = YES;
    }
}

@end
