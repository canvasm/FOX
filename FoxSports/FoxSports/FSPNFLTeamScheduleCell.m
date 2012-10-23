//
//  FSPNFLTeamScheduleCell.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamScheduleCell.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"
#import "FSPScheduleNFLGame.h"
#import "FSPTeam.h"

@interface FSPNFLTeamScheduleCell ()

@property (nonatomic, assign) BOOL isHomeGame;
@property (nonatomic, weak) IBOutlet UILabel *col4Label;
@property (nonatomic, weak) IBOutlet UILabel *col5Label;
@property (nonatomic, weak) IBOutlet UILabel *col6Label;
@property (nonatomic, weak) IBOutlet UILabel *byeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateChannelSublabel;


@end

@implementation FSPNFLTeamScheduleCell

@synthesize isHomeGame = _isHomeGame;
@synthesize col4Label;
@synthesize col5Label;
@synthesize col6Label;
@synthesize byeLabel;
@synthesize dateChannelSublabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.byeLabel.backgroundColor = [UIColor clearColor];
    self.byeLabel.text = @"Bye Week";
    self.byeLabel.hidden = YES;
    self.byeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (void)populateWithGame:(FSPScheduleNFLGame *)game;
{
    // Use this to test whether it is a bye week
    if (game.homeTeamName != nil) {
        [super populateWithGame:game];
        
        NSString *opponentDisplayString;
        
        if ([game.awayTeamName isEqualToString:self.team.name] || [game.awayTeamName isEqualToString:self.team.nickname]) {
            opponentDisplayString = [NSString stringWithFormat:@"@ %@", game.homeTeamName];
            self.isHomeGame = NO;
        } else {
            opponentDisplayString = game.awayTeamName;
            self.isHomeGame = YES;
        }

        if (![game.seasonType isEqualToString:@"EXHIBITION"])
            self.col0Label.text = [NSString stringWithFormat:@"%d", game.weekNumber];
        else 
            self.col0Label.text = @"";
        self.col1Label.text = [game.startDate fsp_weekdayMonthSlashDay];
        self.col2Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
        self.col2Label.text = opponentDisplayString;
        NSString *winLose;
        if (self.isHomeGame) {
            winLose = [game.homeTeamScore intValue] > [game.awayTeamScore intValue] ? @"W" : @"L";
        } else {
            winLose = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? @"W" : @"L";
        }
        self.col3Label.text = [NSString stringWithFormat:@"%@ %@–%@", winLose, game.homeTeamScore, game.awayTeamScore];
        self.col3Label.hidden = NO;
        
        if (!self.isFuture) {
            
            self.col4Label.hidden = NO;
            self.col4Label.text = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? game.awayTeamPasserStats : game.homeTeamPasserStats;

            self.col5Label.hidden = NO;
            self.col5Label.text = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? game.awayTeamRusherStats : game.homeTeamRusherStats;

            self.col6Label.hidden = NO;
            self.col6Label.text = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? game.awayTeamReceiverStats : game.homeTeamReceiverStats;

        }
        else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.col1Label.hidden = NO; 
                self.col3Label.hidden = YES;
                // Make AM/PM lowercase, append abbreviated time zone.
                NSString *starttime = [game.startDate fsp_lowercaseMeridianTimeString];
                starttime = [NSString stringWithFormat:@"%@ %@",starttime, [[NSTimeZone localTimeZone] abbreviation]];
                self.dateChannelSublabel.text = [NSString stringWithFormat:@"%@, %@", starttime, game.channelDisplayName ? : @""];
            }
            else {
                // TODO: Show if game is LIVE
                self.col3Label.text = [game.startDate fsp_lowercaseMeridianTimeString];
                self.col4Label.text = game.channelDisplayName  ? : @"";
                CGRect col4Frame = self.col4Label.frame;
                col4Frame.origin.x = 355.0;
                self.col4Label.frame = col4Frame;

            }
            self.col5Label.hidden = YES; // Unhide when Calendar is available.
            self.col6Label.hidden = YES;
        }
    }
    else {
        self.col0Label.text = [NSString stringWithFormat:@"%d", game.weekNumber];
        self.col1Label.hidden = YES;
        self.col2Label.hidden = YES;
        self.col3Label.hidden = YES;
        self.col4Label.hidden = YES;
        self.col5Label.hidden = YES;
        self.col6Label.hidden = YES;
        
        self.byeLabel.hidden = NO;
    }
}

- (void)updateSubviewPositions
{
    // Do nothing
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.col0Label.hidden = NO;
    self.col1Label.hidden = NO;
    self.col2Label.hidden = NO;
    self.col3Label.hidden = NO;
    self.col4Label.hidden = NO;
    self.col5Label.hidden = NO;
    self.col6Label.hidden = NO;
    
    self.byeLabel.hidden = YES;
    self.dateChannelSublabel.text = @"";

}

@end
