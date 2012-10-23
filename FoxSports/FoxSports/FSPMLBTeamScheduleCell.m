//
//  FSPMLBTeamScheduleCell.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBTeamScheduleCell.h"
#import "FSPScheduleMLBGame.h"
#import "FSPTeam.h"
#import "NSDate+FSPExtensions.h"

@interface FSPMLBTeamScheduleCell ()

@property (nonatomic, assign) BOOL isHomeGame;
@property (nonatomic, weak) IBOutlet UILabel *col4Label;
@property (nonatomic, weak) IBOutlet UILabel *col5Label;
@property (nonatomic, weak) IBOutlet UILabel *dateChannelSublabel;

@end

@implementation FSPMLBTeamScheduleCell

@synthesize isHomeGame = _isHomeGame;
@synthesize col4Label = _col4Label;
@synthesize col5Label = _col5Label;
@synthesize dateChannelSublabel = _dateChannelSublabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.col0Label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
    self.col0Label.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];
}

- (NSString *)startTimeStringFromGame:(FSPScheduleGame *)game;
{
    NSString *displayString;
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            formatter.dateFormat = @"h:mma";
        }
        else {
            formatter.dateFormat = @"h:mm a";
        }
    });
    displayString = [formatter stringFromDate:game.startDate];
    
    return displayString;
}

- (void)updateSubviewPositions
{
    
}

- (void)populateWithGame:(FSPScheduleMLBGame *)game;
{
	[super populateWithGame:game];
    
    NSString *opponentDisplayString; 
    if([self.team.name isEqualToString:game.awayTeamName] || [self.team.nickname isEqualToString:game.awayTeamName])
    {
        opponentDisplayString = [NSString stringWithFormat:@"@ %@", game.homeTeamName];
        self.isHomeGame = NO;
    }
    else
    {
        opponentDisplayString = game.awayTeamName;
        self.isHomeGame = YES;
    }
    
    self.col0Label.text = [game.startDate fsp_weekdayMonthSlashDay];
    self.col1Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
    self.col3Label.hidden = NO;
    
    self.col1Label.text = opponentDisplayString;
	if (!self.isFuture) {
        self.col5Label.hidden = NO;
        self.col4Label.hidden = NO;
        NSString *winLose = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? @"L" : @"W";
        self.col2Label.text = [NSString stringWithFormat:@"%@ %@–%@", winLose, game.homeTeamScore, game.awayTeamScore];
        self.col3Label.text = [self lastNameFromFullName:game.winningPlayer];
        self.col4Label.text = [self lastNameFromFullName:game.losingPlayer];
        self.col5Label.text = [self lastNameFromFullName:game.savingPlayer];
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.col2Label.text = nil; // Calendar will go here. [[NSTimeZone localTimeZone] abbreviation]
            self.col1Label.hidden = NO;
            // Make AM/PM lowercase, append abbreviated time zone.
            NSString *startDate = [[self startTimeStringFromGame:game] lowercaseString];
            startDate = [NSString stringWithFormat:@"%@ %@",startDate, [[NSTimeZone localTimeZone] abbreviation]];
            
            self.dateChannelSublabel.text = [NSString stringWithFormat:@"%@, %@", startDate, game.channelDisplayName];
        }
        else {
            self.col2Label.text = [self startDateStringFromEvent:game];
            self.col3Label.text = game.channelDisplayName;
        }
        self.col4Label.hidden = YES;
        self.col5Label.hidden = YES;//TODO: remove when calendar available
        
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.col4Label.text = nil;
    self.col5Label.text = nil;
    self.dateChannelSublabel.text = nil;
}

@end
