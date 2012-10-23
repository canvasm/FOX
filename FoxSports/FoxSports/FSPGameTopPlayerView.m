//
//  FSPGameTopPlayerView.m
//  FoxSports
//
//  Created by Matthew Fay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameTopPlayerView.h"
#import "FSPTeamPlayer.h"
#import "FSPTeamColorLabel.h"
#import "FSPTeam.h"
#import "FSPGame.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPImageFetcher.h"
#import "FSPOrganization.h"


@interface FSPGameTopPlayerView()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *playerImage;
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *statValueLabel;
@property (nonatomic, weak) IBOutlet FSPTeamColorLabel *teamNameLabel;

@property (nonatomic, strong) UIImage *compositedPlayerImage;

@property (nonatomic, weak) FSPTeamPlayer *currentPlayer;
@end

@implementation FSPGameTopPlayerView

@synthesize titleLabel = _titleLabel;
@synthesize playerImage = _playerImage;
@synthesize firstNameLabel = _firstNameLabel;
@synthesize lastNameLabel = _lastNameLabel;
@synthesize statTypeLabel = _statTypeLabel;
@synthesize statValueLabel = _statValueLabel;
@synthesize teamNameLabel = _teamNameLabel;
@synthesize compositedPlayerImage = _compositedPlayerImage;
@synthesize fullNameLabel = _fullNameLabel;

@synthesize currentPlayer = _currentPlayer;

- (id)initWithDirection:(FSPGamePlayerDirection)direction
{
    UINib *matchupNib;
    if (direction == FSPGamePlayerDirectionRight) {
        matchupNib = [UINib nibWithNibName:@"FSPGameTopPlayerViewRight" bundle:nil];
	} else {
        matchupNib = [UINib nibWithNibName:@"FSPGameTopPlayerViewLeft" bundle:nil];
	}
    
    NSArray *views = [matchupNib instantiateWithOwner:nil options:nil];
    self = [views lastObject];
    return self;
}

- (void)populateWithPlayer:(FSPTeamPlayer *)player statType:(NSString *)statType statValue:(NSNumber *)statValue title:(NSString *)title;
{
    if (player && (!statValue && statType))
        self.hidden = YES;
    else 
        self.hidden = NO;
    
    if (player) {
        if (title) {
            self.titleLabel.text = [title uppercaseString];
            self.titleLabel.hidden = NO;
        } else {
            self.titleLabel.hidden = YES;
        }
            
        self.firstNameLabel.hidden = NO;
        self.lastNameLabel.hidden = NO;
        self.fullNameLabel.hidden = NO;
        
        self.firstNameLabel.text = player.firstName.uppercaseString;
        self.lastNameLabel.text = player.lastName.uppercaseString;
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", player.firstName.uppercaseString, player.lastName.uppercaseString];
		} else {
			self.fullNameLabel.text = [player abbreviatedName];
		}
    
        //TODO: Is there a better way to get the team/game?
        FSPGame *game = nil;
        FSPTeam *team = nil;
        UIColor *teamColor = nil;
        if (player.homeGame) {
            game = player.homeGame;
            team = game.homeTeam;
            teamColor = game.homeTeamColor;
        } else {
            game = player.awayGame;
            team = game.awayTeam;
            teamColor = game.awayTeamColor;
        }
            
		if (team) {
			self.teamNameLabel.hidden = NO;
			self.teamNameLabel.text = team.abbreviation;
			self.teamNameLabel.teamColor = teamColor;
		} else {
			self.teamNameLabel.hidden = YES;
		}
    } else {
        self.teamNameLabel.hidden = YES;
        self.firstNameLabel.hidden = YES;
        self.lastNameLabel.hidden = YES;
        self.fullNameLabel.hidden = YES;
        self.titleLabel.hidden = YES;
    }
    
    if (statValue) {
		NSString *statString = nil;
		if ([statType isEqualToString:@"AVG"]) {
			statString = [[NSString stringWithFormat:@"%.3f", [statValue floatValue]] substringFromIndex:1];
		} else {
			statString = [statValue stringValue];
		}
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.statTypeLabel.text = statType;
			self.statValueLabel.text = statString;
			self.statTypeLabel.hidden = NO;
			self.statValueLabel.hidden = NO;
		} else {
			self.statValueLabel.text = [NSString stringWithFormat:@"%@ %@", statType, statString];
			self.statTypeLabel.hidden = YES;
			self.statValueLabel.hidden = NO;
		}
    } else {
        self.statTypeLabel.hidden = YES;
        self.statValueLabel.hidden = YES;
    }
    
    if (self.currentPlayer != player) {
        // Player is changing
        self.playerImage.image = nil;
        self.compositedPlayerImage = nil;
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:player.photoURL]
                                           withCallback:^(UIImage *image) {
                                               if (image) {
                                                   self.playerImage.image = image;
                                               }
                                               else {
                                                   FSPViewType viewType;
                                                   if (player.homeGame)
                                                       viewType = player.homeGame.viewType;
                                                   else
                                                       viewType = player.awayGame.viewType;
                                                   
                                                   NSString *imageSuffix = nil;
                                                   switch (viewType) {
                                                        case FSPNCAABViewType:
                                                        case FSPNCAAWBViewType:
                                                        case FSPBasketballViewType: {
                                                           imageSuffix = @"NBA";
                                                           break;
                                                        }
                                                        case FSPBaseballViewType: {
                                                            imageSuffix = @"MLB";
                                                            break;
                                                        }
                                                        case FSPNFLViewType:
                                                        case FSPNCAAFViewType: {
                                                            imageSuffix = @"NFL";
                                                            break;
                                                        }
                                                        case FSPHockeyViewType: {
                                                            imageSuffix = @"NHL";
                                                            break;
                                                        }
                                                       default:
                                                           break;
                                                    }
                                                   NSString *imageName = [NSString stringWithFormat:@"Default_Headshot_%@", imageSuffix];
                                                   self.playerImage.image = [UIImage imageNamed:imageName];
                                               }
        }];
    }
    self.currentPlayer = player;
}

- (void)awakeFromNib;
{
    //Set custom fonts

    self.fullNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
    self.fullNameLabel.textColor = [UIColor whiteColor];

    self.firstNameLabel.font = [UIFont fontWithName:FSPUScoreRGHFontName size:16.0];
	self.lastNameLabel.font = [UIFont fontWithName:FSPUScoreRGHFontName size:21.0];
    
    self.teamNameLabel.font = [UIFont fontWithName:FSPUScoreRGHFontName size:15.0];

    self.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:11.0];
    self.titleLabel.textColor = [UIColor fsp_lightMediumBlueColor];
	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.statTypeLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
		self.statValueLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:17.0];
    } else {
		self.statTypeLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12.0];
		self.statValueLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];

		self.statTypeLabel.textColor = [UIColor fsp_mediumBlueColor];
		self.statValueLabel.textColor = [UIColor fsp_mediumBlueColor];
	}
    
}

@end
