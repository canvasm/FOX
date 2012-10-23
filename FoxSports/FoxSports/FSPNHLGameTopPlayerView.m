//
//  FSPNHLGameTopPlayerView.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLGameTopPlayerView.h"
#import "FSPHockeyPlayer.h"
#import "FSPImageFetcher.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPTeamColorLabel.h"
#import "FSPTeam.h"
#import "FSPGame.h"

@interface FSPNHLGameTopPlayerView()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *statValueLabel;
@property (nonatomic, weak) IBOutlet FSPTeamColorLabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *playerImage;
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, strong) FSPHockeyPlayer *currentPlayer;

@end

@implementation FSPNHLGameTopPlayerView

@synthesize numberLabel = _numberLabel;


- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPNHLGameTopPlayerView" bundle:nil];
    NSArray *views = [matchupNib instantiateWithOwner:nil options:nil];
    self = [views lastObject];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.numberLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:21.0];
    self.numberLabel.textColor = [UIColor whiteColor];
    self.statValueLabel.font = [UIFont fontWithName:FSPClearViewMediumFontName size:14.0];
    self.statValueLabel.textColor = [UIColor fsp_mediumBlueColor];
}

- (void)populateWithPlayer:(FSPHockeyPlayer *)player
{
    self.currentPlayer = player;
    
    NSString *noValue = @"--";
    self.numberLabel.text = [player.star stringValue] ? [player.star stringValue] :noValue;
    self.firstNameLabel.text = player.firstName ? player.firstName : noValue;
    self.lastNameLabel.text = player.lastName ? player.lastName : noValue;
    self.statValueLabel.text = [self statValueForPlayer] ? [self statValueForPlayer] : noValue;
    self.teamNameLabel.teamColor = [self playerTeam].teamColor ? [self playerTeam].teamColor : [UIColor clearColor];
    self.teamNameLabel.text = [self playerTeam].abbreviation ? [self playerTeam].abbreviation : noValue;
    
    [[FSPImageFetcher sharedFetcher] fetchImageForURL:[NSURL URLWithString:player.photoURL] withCallback:^(UIImage *image) {
        if (image) {
            self.playerImage.image = image;
        } else {
            self.playerImage.image = [UIImage imageNamed:@"Default_Headshot_NHL"];
        }
    }];
    
    if ([player.star intValue] == 3 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.statValueLabel.frame = CGRectMake(self.statValueLabel.frame.origin.x, self.statValueLabel.frame.origin.y, self.statValueLabel.frame.size.width, 36.0);
    }
}

- (FSPTeam *)playerTeam
{
    FSPTeam *team = nil;
    if(self.currentPlayer.homeGame)
        team = self.currentPlayer.homeGame.homeTeam;
    else if(self.currentPlayer.awayGame)
        team = self.currentPlayer.awayGame.awayTeam;
    return team;
}

- (NSString *)statValueForPlayer
{
    if(!self.currentPlayer.star) {
        return nil;
    }
    
    NSString *statValue = nil;
    if ([self.currentPlayer.star intValue] == 1) {
        statValue = [NSString stringWithFormat:@"(%@ G)", self.currentPlayer.goalsScored];
    }
    else if ([self.currentPlayer.star intValue] == 2) {
        statValue = [NSString stringWithFormat:@"(%@ A, %@ SOG)", self.currentPlayer.assists, self.currentPlayer.shotsOnGoal];
    }
    else {
        statValue = [NSString stringWithFormat:@"(%@ SV, %@ SV%%, %@ GA)", [self.currentPlayer.saves stringValue], [self.currentPlayer.savePercentage stringValue], [self.currentPlayer.goalsAllowed stringValue]];
    }
    return statValue;
}

@end
