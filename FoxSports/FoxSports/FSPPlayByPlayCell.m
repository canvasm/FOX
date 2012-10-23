//
//  FSPNBAPlayByPlayCell.m
//  FoxSports
//
//  Created by Jason Whitford on 2/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayByPlayCell.h"
#import "UIFont+FSPExtensions.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPTeamColorLabel.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPTeam.h"
#import "FSPGame.h"

@interface FSPPlayByPlayCell ()
@property (nonatomic, assign) CGRect scoreLabelsRect;
@end


@implementation FSPPlayByPlayCell
@synthesize timeLabel = _timeLabel;
@synthesize teamLabel = _teamLabel;
@synthesize playLabel = _playLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize homeScoreLabel = _homeScoreLabel;
@synthesize awayScoreLabel = _awayScoreLabel;
@synthesize showScore = _showScore;
@synthesize scoreLabelsRect;

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    self.timeLabel.textColor = [UIColor fsp_lightBlueColor];

    self.playLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    
    self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:13.0f];
    self.descriptionLabel.textColor = [UIColor fsp_lightBlueColor];
	
	CGRect away = self.awayScoreLabel.frame;
	CGRect home = self.homeScoreLabel.frame;
	
	self.scoreLabelsRect = CGRectMake(CGRectGetMinX(away), CGRectGetMinY(away), away.size.width + home.size.width, away.size.height + home.size.height);
}

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem;
{
    NSString *seconds;
    if (playByPlayItem.second.floatValue < 10.0f){
        seconds = [NSString stringWithFormat:@"%d%@", 0, playByPlayItem.second];
    } else {
        seconds = [NSString stringWithFormat:@"%@", playByPlayItem.second];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", playByPlayItem.minute, seconds];
    self.teamLabel.text = playByPlayItem.team.abbreviation;
    UIColor *teamColor = nil;
    if (playByPlayItem.game.homeTeam == playByPlayItem.team) {
        teamColor = playByPlayItem.game.homeTeamColor;
    } else {
        teamColor = playByPlayItem.game.awayTeamColor;
    }
    self.teamLabel.teamColor = teamColor;
    //TODO: add play summary when available
    self.playLabel.text = playByPlayItem.abbreviatedSummary;
    self.descriptionLabel.text = playByPlayItem.summaryPhrase;
    CGRect descriptionFrame = self.descriptionLabel.frame;
    CGSize descriptionSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(descriptionFrame.size.width, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    descriptionFrame.size.height = descriptionSize.height;
    self.descriptionLabel.frame = descriptionFrame;
    
    if (!playByPlayItem.team)
        self.teamLabel.hidden = YES;
    else 
        self.teamLabel.hidden = NO;
    
    if ([playByPlayItem.pointsScored integerValue] != 0)
    {
		self.showScore = YES;

        BOOL homeTeamScored;
        if ([playByPlayItem.game.branch isEqualToString:FSPMLBEventBranchType]) {
            homeTeamScored = ![playByPlayItem.topBottom isEqualToString:@"T"];
        } else {
			// CRASH: playByPlayItem.game == nil
            homeTeamScored = ([playByPlayItem.possessionIdentifier isEqualToNumber:playByPlayItem.game.homeTeamLiveEngineID]);
        }
        
        if (playByPlayItem.game && homeTeamScored) {
            self.homeScoreLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
            self.homeScoreLabel.textColor = [UIColor whiteColor];
            self.awayScoreLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
            self.awayScoreLabel.textColor = [UIColor fsp_lightBlueColor];
        } else {
            self.homeScoreLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
            self.homeScoreLabel.textColor = [UIColor fsp_lightBlueColor];
            self.awayScoreLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
            self.awayScoreLabel.textColor = [UIColor whiteColor];
        }
        
		NSString *homeScoreString = [NSString stringWithFormat:@"%@ %@", (playByPlayItem.game.homeTeam.abbreviation) ? playByPlayItem.game.homeTeam.abbreviation : @"--", playByPlayItem.homeScore];
		NSString *awayScoreString = [NSString stringWithFormat:@"%@ %@", (playByPlayItem.game.awayTeam.abbreviation) ? playByPlayItem.game.awayTeam.abbreviation : @"--", playByPlayItem.awayScore];
        self.homeScoreLabel.text = homeScoreString;
        self.awayScoreLabel.text = awayScoreString;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			CGSize homeSize, awaySize;
			homeSize = [homeScoreString sizeWithFont:self.homeScoreLabel.font];
			awaySize = [awayScoreString sizeWithFont:self.awayScoreLabel.font];

			CGRect homeScoreRect, awayScoreRect;
			if (homeSize.width > self.scoreLabelsRect.size.width / 2 || awaySize.width > self.scoreLabelsRect.size.width / 2) {
				CGRectDivide(self.scoreLabelsRect, &awayScoreRect, &homeScoreRect, self.scoreLabelsRect.size.height / 2, CGRectMinYEdge);
			} else {
				CGRectDivide(self.scoreLabelsRect, &awayScoreRect, &homeScoreRect, self.scoreLabelsRect.size.width / 2, CGRectMinXEdge);
				homeScoreRect.size.height = homeSize.height;
				awayScoreRect.size.height = awaySize.height;
			}
			
			self.homeScoreLabel.frame = homeScoreRect;
			self.awayScoreLabel.frame = awayScoreRect;
	
		}
    }
    else {
		self.showScore = NO;
    }
}

- (void)setShowScore:(BOOL)b
{
	_showScore = b;
	self.homeScoreLabel.hidden = !self.showScore;
	self.awayScoreLabel.hidden = !self.showScore;
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    return 44.0; // This is a default setting. Subclasses should override.
}

@end
