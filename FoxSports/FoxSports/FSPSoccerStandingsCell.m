//
//  FSPSoccerStandingsCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerStandingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPSoccerStandingsRule.h"

typedef enum {
    StandingsColorLevel1 = 0,
    StandingsColorLevel2,
    StandingsColorLevel3,
    StandingsColorLevel4,
    StandingsColorLevel5,
    StandingsColorLevelDefault
} StandingsColorLevel;

@interface FSPSoccerStandingsCell()

@property (strong, nonatomic) FSPTeam *team;
@property (strong, nonatomic) FSPOrganization *organization;
@property (nonatomic) NSInteger rank;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *drawsLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalsFieldedLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalDifferentialLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalsAllowedLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UIView *standingsColorView;

@end

@implementation FSPSoccerStandingsCell

@synthesize team = _team;
@synthesize organization = _organization;
@synthesize pointsLabel;
@synthesize drawsLabel;
@synthesize goalsFieldedLabel;
@synthesize lossesLabel;
@synthesize goalDifferentialLabel;
@synthesize goalsAllowedLabel;
@synthesize gamesPlayedLabel;
@synthesize winsLabel;
@synthesize standingsColorView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pointsLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
    self.pointsLabel.textColor = [UIColor fsp_darkBlueColor];
    [[UILabel appearanceWhenContainedIn:[FSPSoccerStandingsCell class], nil] setShadowColor:[UIColor clearColor]];
}

- (void)populateWithTeam:(FSPTeam *)team organization:(FSPOrganization *)organization rank:(NSInteger)rank
{
    self.team = team;
    self.organization = organization;
    self.rank = rank;
    self.rankLabel.text = [[NSNumber numberWithInteger:rank] stringValue];
    self.teamNameLabel.text = team.longNameDisplayString;
    self.pointsLabel.text = team.points;
    self.drawsLabel.text = [team.overallRecord.ties stringValue];
    self.goalsFieldedLabel.text = team.goals;
    self.lossesLabel.text = [team.overallRecord.losses stringValue];
    self.goalDifferentialLabel.text = team.goalDifferential;
    self.goalsAllowedLabel.text = team.goalsAgainst;
    self.gamesPlayedLabel.text = team.gamesPlayed;
    self.winsLabel.text = [team.overallRecord.wins stringValue];
    
    [self setStandingsColor];
}

- (void)setStandingsColor
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startPosition" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *standingsRules = [self.organization.soccerStandingsRules sortedArrayUsingDescriptors:sortDescriptors];
    for (FSPSoccerStandingsRule *rule in standingsRules) {
        StandingsColorLevel level = [standingsRules indexOfObject:rule];
        if (rule.isRelegation.boolValue == YES && (self.rank >= [rule.startPosition intValue] && self.rank <= [rule.endPosition intValue])) {
            self.standingsColorView.backgroundColor = [UIColor colorWithRed:0.74f green:0.76f blue:0.77f alpha:1.00f];
            return;
        }
        else if (self.rank >= [rule.startPosition intValue] && self.rank <= [rule.endPosition intValue]) {
            self.standingsColorView.backgroundColor = [self colorForRuleLevel:level];
            return;
        }
    }
    self.standingsColorView.backgroundColor = [UIColor clearColor];
}

- (UIColor *)colorForRuleLevel:(StandingsColorLevel)level
{
    switch (level) {
        case StandingsColorLevelDefault:
            return [UIColor clearColor];
        case StandingsColorLevel1:
            return [UIColor colorWithRed:0.97f green:0.80f blue:0.51f alpha:1.00f];
        case StandingsColorLevel2:
            return [UIColor colorWithRed:0.98f green:0.84f blue:0.61f alpha:1.00f];
        case StandingsColorLevel3:
            return [UIColor colorWithRed:0.98f green:0.88f blue:0.71f alpha:1.00f];
        case StandingsColorLevel4:
            return [UIColor colorWithRed:0.99f green:0.92f blue:0.81f alpha:1.00f];
        case StandingsColorLevel5:
            return [UIColor colorWithRed:0.99f green:0.96f blue:0.91f alpha:1.00f];
        default:
            return [UIColor clearColor];
    }
}

@end
