//
//  FSPStandingsCell.m
//  FoxSports
//
//  Created by Laura Savino on 4/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface PlayoffIndicatorBackgroundView: UIView
@end

@interface FSPStandingsCell () {}

@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *winsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lossesLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *divisionRecordLabel;
@property (nonatomic, weak) IBOutlet UILabel *streakLabel;
@property (nonatomic, strong) UIImageView *playoffIndicatorImageView;


@end

@implementation FSPStandingsCell

@synthesize teamNameLabel = _teamNameLabel;
@synthesize winsLabel = _winsLabel;
@synthesize lossesLabel = _lossesLabel;
@synthesize percentLabel = _percentLabel;
@synthesize homeRecordLabel = _homeRecordLabel;
@synthesize awayRecordLabel = _awayRecordLabel;
@synthesize conferenceRecordLabel = _conferenceRecordLabel;
@synthesize divisionRecordLabel = _divisionRecordLabel;
@synthesize streakLabel = _streakLabel;
@synthesize rankLabel = _rankLabel;
@synthesize standingsValues = _standingsValues;
@synthesize playoffIndicatorImageView = _playoffIndicatorImageView;
@synthesize lightBlueLabels;
@synthesize darkBlueLabels;
@synthesize orangeLabels;

- (void)awakeFromNib
{
    UIFont *valuesFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    UIColor *valuesColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];
    //TODO: after all the standings have been updated to use the color collections remove color from standingsValues
    for (UILabel *label in self.standingsValues) {
        label.font = valuesFont;
        label.textColor = valuesColor;
    }
    for (UILabel *label in self.lightBlueLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];;
    }
    for (UILabel *label in self.darkBlueLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:1.0];;
    }
    for (UILabel *label in self.orangeLabels) {
        label.textColor = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];;
    }
    
    self.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.teamNameLabel.textColor = [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:1.0];
    
    CGRect viewFrame = CGRectMake(0, (self.frame.size.height - 18)/2, 18, 16);
    
    self.playoffIndicatorImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [self addSubview:self.playoffIndicatorImageView]; 
    
    self.rankLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
    self.rankLabel.textColor = [UIColor fsp_colorWithIntegralRed:115 green:115 blue:115 alpha:1.0];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *dropShadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    for (UILabel *label in self.standingsValues) {
        label.shadowColor = dropShadowColor;
    }
    self.teamNameLabel.shadowColor = dropShadowColor;
}

- (void)populateWithTeam:(FSPTeam *)team;
{
    self.teamNameLabel.text = team.shortNameDisplayString;

    // Resize width.
    CGFloat playoffIndicatorWidth = team.clinched.length ?  self.playoffIndicatorImageView.frame.size.width : 0.0;
    CGSize nameLabelConstraintSize = CGSizeMake((self.winsLabel.frame.origin.x - playoffIndicatorWidth) - self.teamNameLabel.frame.origin.x, self.teamNameLabel.frame.size.height);
    CGSize stringSize = [self.teamNameLabel.text sizeWithFont:self.teamNameLabel.font constrainedToSize:nameLabelConstraintSize lineBreakMode:UILineBreakModeTailTruncation];
    CGRect teamNameRect = self.teamNameLabel.frame;
    self.teamNameLabel.frame = CGRectMake(teamNameRect.origin.x, teamNameRect.origin.y, stringSize.width, teamNameRect.size.height);
    self.playoffIndicatorImageView.frame = CGRectOffset(self.playoffIndicatorImageView.bounds, CGRectGetMaxX(self.teamNameLabel.frame) + 2, self.teamNameLabel.frame.origin.y);
    if (team.clinched.length) {
        self.playoffIndicatorImageView.hidden = NO;
        self.playoffIndicatorImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Standings_%@",team.clinched]];
    }
    self.playoffIndicatorImageView.hidden = NO;
    self.winsLabel.text = [team.overallRecord.wins stringValue];
    self.lossesLabel.text = [team.overallRecord.losses stringValue];
    static NSNumberFormatter *winningPercentFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        winningPercentFormatter = [[NSNumberFormatter alloc] init];
        winningPercentFormatter.maximumFractionDigits = 3;
        winningPercentFormatter.minimumFractionDigits = 3;
    });
    self.percentLabel.text = team.winPercent;

    self.homeRecordLabel.text = team.homeRecord.winLossRecordString;
    self.awayRecordLabel.text = team.awayRecord.winLossRecordString;
    self.conferenceRecordLabel.text = team.conferenceRecord.winLossRecordString;
    self.divisionRecordLabel.text = team.divisionRecord.winLossRecordString;
    self.streakLabel.text = [team streakDisplayString];
}

- (void)prepareForReuse
{
    self.playoffIndicatorImageView.hidden = YES;
    self.playoffIndicatorImageView.image = nil;
    self.rankLabel.text = nil;
}
@end
