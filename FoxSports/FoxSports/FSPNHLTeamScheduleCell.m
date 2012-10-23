//
//  FSPNHLTeamScheduleCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLTeamScheduleCell.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"
#import "FSPScheduleNHLGame.h"
#import "FSPTeam.h"

@interface FSPNHLTeamScheduleCell ()

@property (nonatomic, assign) BOOL isHomeGame;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *valueLabels;

@end

@implementation FSPNHLTeamScheduleCell

@synthesize isHomeGame = _isHomeGame;
@synthesize valueLabels;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)populateWithGame:(FSPScheduleNHLGame *)game;
{
    if (game.homeTeamName != nil) {
        [super populateWithGame:game];
        
        NSString *opponentDisplayString;
        if([self.team.nickname isEqualToString:game.awayTeamName] || [self.team.name isEqualToString:game.awayTeamName])
        {
            opponentDisplayString = [NSString stringWithFormat:@"@ %@", game.homeTeamName];
            self.isHomeGame = NO;
        }
        else
        {
            opponentDisplayString = game.awayTeamName;
            self.isHomeGame = YES;
        }
        
        self.col1Label.text = [game.startDate fsp_weekdayMonthSlashDay];
        self.col2Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
        self.col2Label.text = opponentDisplayString;
        
        NSString *winLose;
        if (self.isHomeGame) {
            winLose = [game.homeTeamScore intValue] > [game.awayTeamScore intValue] ? @"W" : @"L";
        } else {
            winLose = [game.awayTeamScore intValue] > [game.homeTeamScore intValue] ? @"W" : @"L";
        }
        if ([game.homeTeamScore intValue] == 0 && [game.awayTeamScore intValue] == 0) {
            winLose = @"";
        }
        
        NSString *extraPeriod = [game.segmentNumber intValue] > 3 ? @"OT" : @"";
        self.col3Label.text = [NSString stringWithFormat:@"%@ %@–%@ %@", winLose, game.homeTeamScore, game.awayTeamScore, extraPeriod];
        self.col3Label.hidden = NO;
        
        if (!self.isFuture) {
            
            self.col4Label.hidden = NO;
            self.col4Label.text = game.playerStatsString;
            
            self.col5Label.hidden = YES;
            self.col6Label.hidden = YES;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.dateChannelSublabel.hidden = YES;
            }
            
        }
        else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.col1Label.hidden = NO;
                self.col3Label.hidden = YES;
                self.dateChannelSublabel.hidden = NO;
                // Make AM/PM lowercase, append abbreviated time zone.
                NSString *starttime = [game.normalizedStartDate fsp_lowercaseMeridianTimeString];
                starttime = [NSString stringWithFormat:@"%@ %@",starttime, [[NSTimeZone localTimeZone] abbreviation]];
                if (game.channelDisplayName != nil) {
                    self.dateChannelSublabel.text = [NSString stringWithFormat:@"%@, %@", starttime, game.channelDisplayName];
                } else {
                    self.dateChannelSublabel.text = [NSString stringWithFormat:@"%@, Channel TBD", starttime];
                }
                
            }
            else {
                // TODO: Show if game is LIVE
                self.col3Label.text = [game.normalizedStartDate fsp_lowercaseMeridianTimeString];
                if (game.channelDisplayName != nil) {
                    self.col6Label.text = [NSString stringWithFormat:@"%@", game.channelDisplayName];
                } else {
                    self.col6Label.text = @"Channel TBD";
                }
                self.col5Label.hidden = NO;
                
                NSString *starttime = [game.normalizedStartDate fsp_lowercaseMeridianTimeString];
                self.col5Label.text = [NSString stringWithFormat:@"%@ %@",starttime, [[NSTimeZone localTimeZone] abbreviation]];
                
                CGRect col4Frame = self.col4Label.frame;
                col4Frame.origin.x = 355.0;
                self.col6Label.frame = col4Frame;
                
            }
            self.col3Label.hidden = YES;
            self.col4Label.hidden = YES;
        }
        
        for (UILabel *label in valueLabels) {
            if (label.text == nil) {
                label.text = @"--";
            }
        }
    }
}

- (void)updateSubviewPositions
{
    // Do nothing
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.col1Label.hidden = NO;
    self.col2Label.hidden = NO;
    self.col3Label.hidden = NO;
    self.col4Label.hidden = NO;
    self.col5Label.hidden = NO;
    self.col6Label.hidden = NO;
}

@end
