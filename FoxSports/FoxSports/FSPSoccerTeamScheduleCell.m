//
//  FSPSoccerTeamScheduleCell.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerTeamScheduleCell.h"

#import "FSPScheduleGame.h"
#import "FSPTeam.h"
#import "NSDate+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPSoccerTeamScheduleCell ()

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *pastLabels;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *futureLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *infoLabels;
@property (weak, nonatomic) IBOutlet UILabel *tvTimeLabel;

@end

@implementation FSPSoccerTeamScheduleCell
@synthesize time = _time;
@synthesize pastHomeTeam = _pastHomeTeam;
@synthesize pastAwayTeam = _pastAwayTeam;
@synthesize venue = _venue;
@synthesize result = _result;
@synthesize futureHomeTeam = _futureHomeTeam;
@synthesize futureAwayTeam = _futureAwayTeam;
@synthesize channel = _channel;
@synthesize dateLabel = _dateLabel;

@synthesize pastLabels;
@synthesize futureLabels;
@synthesize infoLabels;
@synthesize tvTimeLabel = _tvTimeLabel;


+ (CGFloat)heightForEvent:(FSPScheduleEvent *)game;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 33;
    }
    
    NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:game.startDate];
    BOOL isFuture = (comparisonResult == NSOrderedAscending);
    if (isFuture) {
        return 85;
    } else {
        return 46;
    }
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (UIView *view in pastLabels) {
            view.hidden = YES;
        }
    }
    self.pastHomeTeam.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.pastAwayTeam.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.futureAwayTeam.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.futureHomeTeam.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.tvTimeLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f];
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

- (void)drawRect:(CGRect)rect;
{
    [super drawRect:rect];
    
    self.tvTimeLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
}

- (void)updateSubviewPositions
{
    
}

- (void)populateWithGame:(FSPScheduleGame *)game;
{
	[super populateWithGame:game];
    
    NSString *teamFormat;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        teamFormat = game.awayTeamName;
    else 
        teamFormat = [NSString stringWithFormat:@"%@ @", game.awayTeamName];
    
    self.futureHomeTeam.text = game.homeTeamName;
    self.futureAwayTeam.text = teamFormat;
    
    self.pastHomeTeam.text = game.homeTeamName;
    self.pastAwayTeam.text = game.awayTeamName;
    
    self.venue.text = [game valueForKey:@"venueName"];
    self.result.text = [NSString stringWithFormat:@"%@–%@", game.homeTeamScore, game.awayTeamScore];
    self.channel.text = game.channelDisplayName;
    self.dateLabel.text = [game.startDate fsp_lowercaseMeridianDateString];
    self.time.text = [game.startDate fsp_lowercaseMeridianDateString];//[self startTimeStringFromGame:game];
	
	if (!self.isFuture) {
        
        for (UIView *view in futureLabels) {
            view.hidden = YES;
        }
        for (UIView *view in pastLabels) {
            view.hidden = NO;
        }
    } else {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.venue.text = game.channelDisplayName;
            self.result.text = @"vs";
        } 
        
        for (UIView *view in futureLabels) {
            view.hidden = NO;
        }
        for (UIView *view in pastLabels) {
            view.hidden = YES;
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UILabel *label in self.valueLabels) {
        label.text = nil;
    }
}

@end
