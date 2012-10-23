//
//  FSPNHLLeagueScheduleCell.m
//  FoxSports
//
//  Created by Matthew Fay on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLLeagueScheduleCell.h"
#import "FSPScheduleGame.h"
#import "FSPScheduleNHLGame.h"
#import "UIFont+FSPExtensions.h"

@interface FSPNHLLeagueScheduleCell ()
@property (nonatomic, weak) IBOutlet UILabel *topPerformerLabel;

@end

@implementation FSPNHLLeagueScheduleCell
@synthesize topPerformerLabel;

- (NSString *)startTimeStringFromGame:(FSPScheduleGame *)game;
{
    NSString *displayString;
    static NSString *end = @"";
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            formatter.dateFormat = @"h:mma";
            end = [NSString stringWithFormat:@" %@",[[NSTimeZone localTimeZone] abbreviation]];
        }
        else {
            formatter.dateFormat = @"h:mm a";
        }
    });
    displayString = [formatter stringFromDate:game.startDate];
    displayString = [displayString stringByAppendingString:end];
    return displayString;
}

- (void)populateWithGame:(FSPScheduleGame *)game
{
    [super populateWithGame:game];
    
    if (!self.isFuture) {
        FSPScheduleNHLGame *NHLGame = (FSPScheduleNHLGame *)game;
        self.col0Label.text = [NSString stringWithFormat:@"%@ %@ @ %@ %@", game.awayTeamName, game.awayTeamScore, game.homeTeamName, game.homeTeamScore];
        self.col2Label.hidden = YES;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
			self.col1Label.text = NHLGame.playerStatsString;
		} else {
            self.col1Label.hidden = YES;
            self.topPerformerLabel.hidden = NO;
            self.col3Label.hidden = NO;
			self.col3Label.text = NHLGame.playerStatsString;
		}
    } else {
        self.col1Label.hidden = NO;
        self.col2Label.hidden = NO;
        self.col3Label.hidden = YES;
        self.topPerformerLabel.hidden = YES;
        self.col1Label.text = [self startTimeStringFromGame:game];
        self.col2Label.text = game.channelDisplayName;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.topPerformerLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
}

+ (CGFloat) heightForEvent:(FSPScheduleEvent *)game
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 40.0;
    }
    else {
        return 52;
    }
}

- (void)updateSubviewPositions;
{
    
}
@end
