//
//  FSPNBATeamScheduleCell.m
//  FoxSports
//
//  Created by Laura Savino on 2/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBATeamScheduleCell.h"
#import "FSPScheduleNBAGame.h"
#import "NSDate+FSPExtensions.h"
#import "FSPTeam.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

static CGFloat const FSPTimeOriginX = 274.0;
static CGFloat const FSPChannelOriginX = 375.0;
static CGFloat const FSPResultOriginX = 322.0; 
static CGFloat const FSPTopScorerOriginX = 434.0;

@interface FSPNBATeamScheduleCell ()
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel * teamLabel;
@property (nonatomic, weak) IBOutlet UILabel * resultLabel;
@property (nonatomic, weak) IBOutlet UILabel * channelTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel * channelLabel;
@property (nonatomic, weak) IBOutlet UILabel * timeLabel;
@property (nonatomic, weak) IBOutlet UILabel * topPerformer;
@property (nonatomic, assign) BOOL isHomeGame;
@end

@implementation FSPNBATeamScheduleCell
@synthesize dateLabel;
@synthesize teamLabel;
@synthesize resultLabel;
@synthesize channelTimeLabel;
@synthesize channelLabel;
@synthesize timeLabel;
@synthesize topPerformer;
@synthesize isHomeGame = _isHomeGame;

+ (CGFloat) heightForEvent:(FSPScheduleNBAGame *)game
{
    BOOL future;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([game.normalizedStartDate fsp_isToday]) {
            future = YES;
        } else {
            NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:game.normalizedStartDate];
            future = (comparisonResult == NSOrderedAscending);
        }
        
        if (future)
            return 48;
    }
    return 30;
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNBATeamScheduleCell" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.teamLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (NSString *)startDateStringFromGame:(FSPScheduleGame *)game;
{
    NSString *displayString;
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"h:mm a";
    });
    displayString = [formatter stringFromDate:game.startDate];
    
    return displayString;
}

- (void)populateWithGame:(FSPScheduleNBAGame *)game;
{
	[super populateWithGame:game];
    
    NSString *opponentDisplayString;
    NSString *winLose;
    if([self.team.name isEqualToString:game.awayTeamName] || [self.team.nickname isEqualToString:game.awayTeamName]) {
        opponentDisplayString = [NSString stringWithFormat:@"@ %@", game.homeTeamName];
        winLose = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? @"W" : @"L";
        self.isHomeGame = NO;
    } else {
        opponentDisplayString = game.awayTeamName;
        winLose = [game.homeTeamScore intValue] > [game.awayTeamScore intValue] ? @"W" : @"L";
        self.isHomeGame = YES;
    }
    
    self.dateLabel.text = [game.startDate fsp_weekdayMonthSlashDay];
    self.teamLabel.text = opponentDisplayString;
    
	if (!self.isFuture) {
        self.topPerformer.hidden = NO;
        self.channelTimeLabel.hidden = YES;
        self.resultLabel.hidden = NO;
        self.channelLabel.hidden = YES;
        self.timeLabel.hidden = YES;
        self.resultLabel.text = [NSString stringWithFormat:@"%@ %@–%@", winLose, game.homeTeamScore, game.awayTeamScore];
        
        NSString *highPointsName = self.isHomeGame ? game.highPointsHomePlayerName : game.highPointsAwayPlayerName;
        NSNumber *highPoints = self.isHomeGame ? game.highPointsHomePlayerPoints : game.highPointsAwayPlayerPoints;
        self.topPerformer.text = [NSString stringWithFormat:@"%@ %@ pts", highPointsName, highPoints];
    }
    else {
        self.topPerformer.hidden = YES;
        self.resultLabel.hidden = YES;
        self.channelTimeLabel.hidden = NO;
        self.channelLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        self.channelTimeLabel.text = [NSString stringWithFormat:@"%@%@%@",[self startDateStringFromGame:game], game.channelDisplayName ? @", " : @"", game.channelDisplayName ? : @""];
        self.channelLabel.text = game.channelDisplayName ? : @"";
        self.timeLabel.text = [self startDateStringFromGame:game];

    }
    
}

- (void)updateSubviewPositions
{
    // Don't call super, don't do anything.
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *label;
    if (self.isFuture) {
        label = [NSString stringWithFormat:@"%@, on %@, at %@", self.col0Label.text, self.col1Label.text, self.col2Label.text];
    } else {
        label = [NSString stringWithFormat:@"%@, winning team high scorer %@, losing team high scorer %@", self.col0Label.text, self.col1Label.text, self.col2Label.text];
    }
    return label;
}


@end
