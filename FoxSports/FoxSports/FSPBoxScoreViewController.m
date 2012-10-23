//
//  FSPBoxScoreViewController.m
//  FoxSports
//
//  Created by Laura Savino on 5/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBoxScoreViewController.h"
#import "FSPTeam.h"
#import "FSPGame.h"
#import "FSPNBAStatRowCell.h"
#import "FSPMLBBattingStatRowCell.h"
#import "FSPMLBPitchingStatRowCell.h"
#import "FSPBaseballPlayer.h"
#import "FSPNFLPassingStatRowCell.h"
#import "FSPNFLReceivingStatRowCell.h"
#import "FSPNFLRushingStatRowCell.h"
#import "FSPNFLKickingStatRowCell.h"
#import "FSPNFLTeamLeadersCell.h"
#import "FSPNFLDefensiveStatRowCell.h"
#import "FSPSoccerPlayerStatRowCell.h"
#import "FSPSoccerPlayer.h"
#import "FSPSoccerGame.h"
#import "FSPFootballGame.h"
#import "FSPFootballPlayer.h"
#import "FSPBasketballGame.h"
#import "FSPBasketballPlayer.h"
#import "FSPGameStatsSectionHeaderView.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailSectionDrawing.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+FSPExtensions.h"
#import "FSPHockeyPlayer.h"
#import "FSPHockeyGameStatCell.h"
#import "FSPTeamPlayer.h"

typedef enum {
    FSPStatsAwayTeamSection = 0,
    FSPStatsHomeTeamSection = 1
} FSPStatsTeamIndex;

enum {
    FSPGameTopSection = 0,
    FSPGameBottomSection = 1,
    FSPGameStatsSectionsCount = 2
};

typedef enum {
    FSPNFLTopPerformersSection = 0,
    FSPNFLPassingSection,
    FSPNFLRushingSection,
    FSPNFLReceivingSection,
    FSPNFLKickingSection,
	FSPNFLDefensiveSection,
    FSPNFLSectionCount
} FSPNFLSection;

typedef enum {
    FSPForwardPosition = 0,
    FSPCenterPosition = 1,
    FSPGuardPosition = 2
}FSPPositionNumber;

typedef enum {
    FSPGoalkeeperPosition = 0,
    FSPDefenderPosition = 1,
    FSPMidfieldPosition = 2,
    FSPSoccerForwardPosition = 3
} FSPSoccerSoccerPosition;

typedef enum {
    FSPChevronDirectionLeft = 0,
    FSPChevronDirectionRight
} FSPChevronDirection;

@interface FSPBoxScoreViewController (Drawing)

- (UIImage *)arrowBackgroundForDirection:(FSPChevronDirection)chevronDirection frame:(CGRect)frame fillColor:(UIColor *)fillColor;

@end

@interface FSPBoxScoreViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

/**
 * The team currently displayed in the box score
 */
@property (nonatomic, strong) FSPTeam *currentBoxScoreTeam;

@property (nonatomic, copy) NSArray *homeTeamTopPlayers;
@property (nonatomic, copy) NSArray *homeTeamBottomPlayers;
@property (nonatomic, copy) NSArray *awayTeamTopPlayers;
@property (nonatomic, copy) NSArray *awayTeamBottomPlayers;

@property (nonatomic, copy) NSArray *homeTeamPassingPlayers;
@property (nonatomic, copy) NSArray *awayTeamPassingPlayers;
@property (nonatomic, copy) NSArray *homeTeamRushingPlayers;
@property (nonatomic, copy) NSArray *awayTeamRushingPlayers;
@property (nonatomic, copy) NSArray *homeTeamReceivingPlayers;
@property (nonatomic, copy) NSArray *awayTeamReceivingPlayers;
@property (nonatomic, copy) NSArray *homeTeamKickingPlayers;
@property (nonatomic, copy) NSArray *awayTeamKickingPlayers;
@property (nonatomic, copy) NSArray *homeTeamDefensivePlayers;
@property (nonatomic, copy) NSArray *awayTeamDefensivePlayers;


@property (weak, nonatomic) IBOutlet UIImageView *homeBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *awayBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *chevronBackgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamLabel;
@property (weak, nonatomic) IBOutlet UITableView *homeTeamStatsTableView;
@property (weak, nonatomic) IBOutlet UITableView *awayTeamStatsTableView;

- (void)switchToHomeTeam:(BOOL)homeTeamActive animated:(BOOL)animated;
- (int)positionNumberFromPosition:(NSString *)position;

@end

@implementation FSPBoxScoreViewController

@synthesize currentGame = _currentGame;
@synthesize homeTeamTopPlayers = _homeTeamTopPlayers;
@synthesize homeTeamBottomPlayers = _homeTeamBottomPlayers;
@synthesize awayTeamTopPlayers = _awayTeamTopPlayers;
@synthesize awayTeamBottomPlayers = _awayTeamBottomPlayers;
@synthesize homeTeamPassingPlayers = _homeTeamPassingPlayers;
@synthesize awayTeamPassingPlayers = _awayTeamPassingPlayers;
@synthesize homeTeamRushingPlayers = _homeTeamRushingPlayers;
@synthesize awayTeamRushingPlayers = _awayTeamRushingPlayers;
@synthesize homeTeamReceivingPlayers = _homeTeamReceivingPlayers;
@synthesize awayTeamReceivingPlayers = _awayTeamReceivingPlayers;
@synthesize homeTeamKickingPlayers = _homeTeamKickingPlayers;
@synthesize awayTeamKickingPlayers = _awayTeamKickingPlayers;
@synthesize homeTeamLabel = _homeTeamLabel;
@synthesize awayTeamLabel = _awayTeamLabel;

@synthesize homeTeamStatsTableView = _homeTeamStatsTableView;
@synthesize awayTeamStatsTableView = _awayTeamStatsTableView;
@synthesize currentBoxScoreTeam = _currentBoxScoreTeam;
@synthesize informationComplete = _informationComplete;

@synthesize homeBackgroundImageView = _homeBackgroundImageView;
@synthesize awayBackgroundImageView = _awayBackgroundImageView;
@synthesize chevronBackgroundImageView = _chevronBackgroundImageView;

#pragma mark - Lifecycle & Memory Management

- (id)initWithGame:(FSPGame *)game
{
    self = [super init];
    if (!self) return nil;

    self.currentGame = game;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapVisibleTeam:)];
    [self.homeBackgroundImageView addGestureRecognizer:tapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapVisibleTeam:)];
    self.view.userInteractionEnabled = YES;
    swipeGestureRecognizerRight.delegate = self;
    swipeGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapVisibleTeam:)];
    swipeGestureRecognizerLeft.delegate = self;
    swipeGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;

    [self.view addGestureRecognizer:swipeGestureRecognizerRight];
    [self.view addGestureRecognizer:swipeGestureRecognizerLeft];
    
    UIImage *bezel = [[UIImage imageNamed:@"team_header_bezel"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    self.homeBackgroundImageView.image = bezel;
    self.awayBackgroundImageView.image = bezel;

    self.homeBackgroundImageView.backgroundColor = self.currentGame.homeTeamColor;
    self.awayBackgroundImageView.backgroundColor = self.currentGame.awayTeamColor;

    self.chevronBackgroundImageView.backgroundColor = [UIColor clearColor];
    
    self.homeTeamLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0f];
    self.awayTeamLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0f];    
    
    self.currentBoxScoreTeam = self.currentGame.awayTeam;
    self.homeTeamStatsTableView.delegate = self;
    self.awayTeamStatsTableView.delegate = self;
    self.homeTeamStatsTableView.dataSource = self;
    self.awayTeamStatsTableView.dataSource = self;
    
    [self switchToHomeTeam:YES animated:NO];
}

#pragma mark - Custom getters & setters

- (void)setCurrentGame:(FSPGame *)currentGame
{
    if (_currentGame != currentGame) {
        _currentGame = currentGame;
        
		FSPViewType viewType = currentGame.viewType;
		switch (viewType) {
			case FSPBaseballViewType:
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPMLBBattingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPMLBBattingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPMLBBattingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPMLBBattingStatRowCellReuseIdentifier];
				
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPMLBPitchingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPMLBPitchingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPMLBPitchingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPMLBPitchingStatRowCellReuseIdentifier];
				break;
			case FSPBasketballViewType:
            case FSPNCAABViewType:
            case FSPNCAAWBViewType:
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNBAStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNBAStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNBAStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNBAStatRowCellReuseIdentifier];
				break;
			case FSPNFLViewType:
			case FSPNCAAFViewType:
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLPassingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLPassingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLPassingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLPassingStatRowCellReuseIdentifier];
				
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLReceivingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLReceivingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLReceivingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLReceivingStatRowCellReuseIdentifier];
				
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLRushingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLRushingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLRushingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLRushingStatRowCellReuseIdentifier];
				
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLKickingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLKickingStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLKickingStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLKickingStatRowCellReuseIdentifier];
				
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLTeamLeadersRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLTeamLeadersRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLTeamLeadersRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLTeamLeadersRowCellReuseIdentifier];
				break;
				[self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLDefensiveStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLDefensiveStatRowCellReuseIdentifier];
				[self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPNFLDefensiveStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPNFLDefensiveStatRowCellReuseIdentifier];
            case FSPSoccerViewType:
                [self.homeTeamStatsTableView registerNib:[UINib nibWithNibName:FSPSoccerPlayerStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPSoccerPlayerStatRowCellReuseIdentifier];
                [self.awayTeamStatsTableView registerNib:[UINib nibWithNibName:FSPSoccerPlayerStatRowCellNibName bundle:nil] forCellReuseIdentifier:FSPSoccerPlayerStatRowCellReuseIdentifier];
                break;
			default:
				break;
		}
        
        [self updatePlayers];
        
        if (self.isViewLoaded) {
            self.currentBoxScoreTeam = nil;
                        
            self.homeBackgroundImageView.backgroundColor = self.currentGame.homeTeamColor;
            self.awayBackgroundImageView.backgroundColor = self.currentGame.awayTeamColor;

            [self switchToHomeTeam:NO animated:NO];
        }
    }

}

- (void)swapVisibleTeam:(id)sender;
{
	[self switchToHomeTeam:(self.currentBoxScoreTeam == self.currentGame.awayTeam) animated:YES];
}

#define INACTIVE_LABEL_OFFSET (10) 
#define CHEVRON_WIDTH (12)

- (void)switchToHomeTeam:(BOOL)homeTeamActive animated:(BOOL)animated;
{
    CGRect frame = self.view.frame;
    CGFloat activeLabelWidth;
    CGFloat activeX;
    CGFloat inactiveLabelWidth = 40.0f;
    
    BOOL isPhone = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        isPhone = YES;
        frame.size.width = 320.0f;
        inactiveLabelWidth = 30.0f;
    }

    CGRect homeLabelFrame = self.homeTeamLabel.frame;
    CGRect awayLabelFrame = self.awayTeamLabel.frame;
    
    CGRect awayBackgroundFrame = self.awayBackgroundImageView.frame;
    CGRect homeBackgroundFrame = self.homeBackgroundImageView.frame;
    CGRect chevronBackgroundFrame = self.chevronBackgroundImageView.frame;

    CGRect homeTeamTableViewFrameStart = self.homeTeamStatsTableView.frame;
    CGRect awayTeamTableViewFrameStart = self.awayTeamStatsTableView.frame;
    CGRect homeTeamTableViewFrameEnd = self.homeTeamStatsTableView.frame;
    CGRect awayTeamTableViewFrameEnd = self.awayTeamStatsTableView.frame;

    UIImage *chevronImage = nil;
    
    if (isPhone) {
        
        //self.chevronBackgroundImageView.hidden = YES;
        
        homeTeamTableViewFrameEnd.size.width = 320.0f;
        homeTeamTableViewFrameStart.size.width = 320.0f;
        awayTeamTableViewFrameEnd.size.width = 320.0f;
        awayTeamTableViewFrameStart.size.width = 320.0f;
        
        homeBackgroundFrame.size.width = 320.0f;
        awayBackgroundFrame.size.width = 320.0f;
        
        awayLabelFrame.origin.x = 280.0f;
        homeLabelFrame.size.width = inactiveLabelWidth;

    }
    
    if (homeTeamActive) {
        self.currentBoxScoreTeam = self.currentGame.homeTeam;

        // home label should be centered, away team on the LEFT
        CGSize size = [[self.currentGame.homeTeam.longNameDisplayString uppercaseString] sizeWithFont:self.homeTeamLabel.font];
        activeLabelWidth = size.width;
        activeX = floor(frame.size.width/2 - activeLabelWidth/2);
        
        
        // centered home label
        homeLabelFrame.origin.x = activeX;
        homeLabelFrame.size.width = activeLabelWidth;
        
        
        // left away label
        awayLabelFrame.origin.x = INACTIVE_LABEL_OFFSET;
        awayLabelFrame.size.width = inactiveLabelWidth;
        
        awayBackgroundFrame.origin.x = 0;
        awayBackgroundFrame.size.width = CHEVRON_WIDTH + CGRectGetMaxX(awayLabelFrame) + INACTIVE_LABEL_OFFSET;
        
        chevronBackgroundFrame.origin.x = CGRectGetMaxX(awayBackgroundFrame) - CHEVRON_WIDTH;        
        chevronBackgroundFrame.size.width = CHEVRON_WIDTH;
        chevronImage = [self arrowBackgroundForDirection:FSPChevronDirectionRight frame:CGRectMake(0, 0, CHEVRON_WIDTH, 30) fillColor:self.currentGame.homeTeamColor];
        
        
        // stats tables
        homeTeamTableViewFrameStart.origin.x = frame.size.width;
        awayTeamTableViewFrameStart.origin.x = 0;
        homeTeamTableViewFrameEnd.origin.x = 0;
        awayTeamTableViewFrameEnd.origin.x = -frame.size.width;
        
    } else {
        self.currentBoxScoreTeam = self.currentGame.awayTeam;
        
        // home label should be on the RIGHT, away team centered
        CGSize size = [[self.currentGame.awayTeam.longNameDisplayString uppercaseString] sizeWithFont:self.awayTeamLabel.font];
        activeLabelWidth = size.width;
        activeX = floor(frame.size.width/2 - activeLabelWidth/2);
        
        
        // right home label

        homeLabelFrame.origin.x = frame.size.width - inactiveLabelWidth - INACTIVE_LABEL_OFFSET;
        homeLabelFrame.size.width = inactiveLabelWidth;

        
        // centered away label

        awayLabelFrame.origin.x = activeX;
        awayLabelFrame.size.width = activeLabelWidth;
        
        awayBackgroundFrame.origin.x = 0;
        awayBackgroundFrame.size.width = CGRectGetMinX(homeLabelFrame) - INACTIVE_LABEL_OFFSET;
                
        chevronBackgroundFrame.origin.x = CGRectGetMinX(homeLabelFrame) - CHEVRON_WIDTH - INACTIVE_LABEL_OFFSET;
        chevronBackgroundFrame.size.width = CHEVRON_WIDTH;
        chevronImage = [self arrowBackgroundForDirection:FSPChevronDirectionLeft frame:CGRectMake(0, 0, CHEVRON_WIDTH, 30) fillColor:self.currentGame.homeTeamColor];

        
        // stats tables
        homeTeamTableViewFrameStart.origin.x = 0;
        awayTeamTableViewFrameStart.origin.x = -frame.size.width;
        homeTeamTableViewFrameEnd.origin.x = frame.size.width;
        awayTeamTableViewFrameEnd.origin.x = 0;

    }
    
    // table view starting positions
    self.homeTeamStatsTableView.frame = homeTeamTableViewFrameStart;
    self.awayTeamStatsTableView.frame = awayTeamTableViewFrameStart;
    
    

    NSTimeInterval animationDuration = animated? 0.5 : 0.0;
    [UIView animateWithDuration:animationDuration animations:^{

        self.homeTeamStatsTableView.frame = homeTeamTableViewFrameEnd;
        self.awayTeamStatsTableView.frame = awayTeamTableViewFrameEnd;
        
        self.homeTeamLabel.frame = homeLabelFrame;
        self.awayTeamLabel.frame = awayLabelFrame;

        if (homeTeamActive) {
            self.homeTeamLabel.text = [self.currentGame.homeTeam.longNameDisplayString uppercaseString];
            self.awayTeamLabel.text = self.currentGame.awayTeam.abbreviation;
        } else {
            self.homeTeamLabel.text = self.currentGame.homeTeam.abbreviation;
            self.awayTeamLabel.text = [self.currentGame.awayTeam.longNameDisplayString uppercaseString];
        }
        
        self.awayBackgroundImageView.frame = awayBackgroundFrame;
//        self.chevronBackgroundImageView.image = chevronImage;
        self.chevronBackgroundImageView.frame = chevronBackgroundFrame;
        
    } completion:^(BOOL finished) {
                  
        [self.homeTeamStatsTableView reloadData];
        [self.awayTeamStatsTableView reloadData];
      
        self.chevronBackgroundImageView.image = chevronImage;
        
    }];
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipeRecognizer = (id)gestureRecognizer;
        //If swipe is going left and currently displayed team is away,
        //OR if the swipe is going right and the currently displayed team is home,
        //switch the teams
        if ((swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft && self.currentBoxScoreTeam == self.currentGame.awayTeam) ||
            (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight && self.currentBoxScoreTeam == self.currentGame.homeTeam))
            return YES;
        else
            return NO;
    }

    return YES;
}

- (void)reloadTableViews;
{
    [self updatePlayers];
    [self.homeTeamStatsTableView reloadData];
    [self.awayTeamStatsTableView reloadData];
}

#pragma mark - Table View Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if ([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) {
        return FSPNFLSectionCount;
    }
    if ([self.currentGame viewType] == FSPHockeyViewType) {
        return 2;
    }
    return FSPGameStatsSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    if ((([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType)) && ![self gameOver] && section == FSPNFLTopPerformersSection) {
        return 0;
    }
    
    if ([self.currentGame viewType] == FSPHockeyViewType) {
        return [self tableView:tableView numberOfRowsInHockeySection:section];
    }
    
    NSInteger count = 0;
    
    if([tableView isEqual:self.homeTeamStatsTableView])
    {
        if (([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType)) {
            count = [self countForNFLTeamPlayersAtSection:section isHomeTeam:YES];
        } else if (section == FSPGameTopSection) {
            count = [self.homeTeamTopPlayers count];
        } else if (section == FSPGameBottomSection) {
            count = [self.homeTeamBottomPlayers count];
        }
    }
    else if([tableView isEqual:self.awayTeamStatsTableView])
    {
        if (([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType)) {
            count = count = [self countForNFLTeamPlayersAtSection:section isHomeTeam:NO];
        } else if (section == FSPGameTopSection) {
            count = [self.awayTeamTopPlayers count];
        } else if (section == FSPGameBottomSection) {
            count = [self.awayTeamBottomPlayers count];
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSString *reuseIdentifier = nil;
    
	FSPViewType viewType = [self.currentGame viewType];
	switch (viewType) {
		case FSPBasketballViewType:
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
			reuseIdentifier = FSPNBAStatRowCellReuseIdentifier;
			break;
		case FSPBaseballViewType:
			if (indexPath.section == FSPGameTopSection) {
				reuseIdentifier = FSPMLBBattingStatRowCellReuseIdentifier;
			} else {
				reuseIdentifier = FSPMLBPitchingStatRowCellReuseIdentifier;
			}
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			reuseIdentifier = [self reuseIdentifierForNFLCellAtIndexPath:indexPath];
			break;
        case FSPSoccerViewType:
            reuseIdentifier = FSPSoccerPlayerStatRowCellReuseIdentifier;
            break;
        case FSPHockeyViewType:
            reuseIdentifier = FSPHockeyPlayerStatCellReuseIdentifier;
		default:
			break;
	}
	
    FSPGameStatCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
		switch (viewType) {
			case FSPBasketballViewType:
            case FSPNCAABViewType:
            case FSPNCAAWBViewType:
				cell = [[FSPNBAStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
				break;
			case FSPBaseballViewType:
				if (indexPath.section == FSPGameTopSection) {
					cell = [[FSPMLBBattingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
				} else {
					cell = [[FSPMLBPitchingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
				}
				break;
			case FSPNFLViewType:
			case FSPNCAAFViewType:
				cell = [self cellForNFLBoxViewAtIndexPath:indexPath reuseIdentifier:reuseIdentifier];
				break;
            case FSPSoccerViewType:
                cell = [[FSPSoccerPlayerStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                break;
            case FSPHockeyViewType:
                if ([indexPath section] == 0) {
                    cell = [[FSPHockeyGameStatCell alloc] initWithType:FSPHockeyGameStatCellTypeSkater];
                } else {
                    cell = [[FSPHockeyGameStatCell alloc] initWithType:FSPHockeyGameStatCellTypeGoaltender];
                }
			default:
				break;
		}
    }
    
    FSPTeamPlayer *player;
    if([tableView isEqual:self.homeTeamStatsTableView])
    {
        if ([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) {
            player = [self playerForNFLCell:cell atIndexPath:indexPath];
        } else if (indexPath.section == FSPGameTopSection)
            player = [self.homeTeamTopPlayers objectAtIndex:indexPath.row];
        else
            player = [self.homeTeamBottomPlayers objectAtIndex:indexPath.row];
        
        [cell populateWithPlayer:player];
        
    }
    else if([tableView isEqual:self.awayTeamStatsTableView])
    {
        if ([self.currentGame viewType] == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) {
            if (indexPath.section == FSPNFLPassingSection) {
                player = [self.awayTeamPassingPlayers objectAtIndex:indexPath.row];
            } else if (indexPath.section == FSPNFLRushingSection) {
                player = [self.awayTeamRushingPlayers objectAtIndex:indexPath.row];
            } else if (indexPath.section == FSPNFLReceivingSection) {
                player = [self.awayTeamReceivingPlayers objectAtIndex:indexPath.row];
            } else if (indexPath.section == FSPNFLKickingSection) {
                player = [self.awayTeamKickingPlayers objectAtIndex:indexPath.row];
			} else if (indexPath.section == FSPNFLDefensiveSection) {
                player = [self.awayTeamDefensivePlayers objectAtIndex:indexPath.row];
            } else if (indexPath.section == FSPNFLTopPerformersSection) {
                NSSet *players = self.currentGame.awayTeamPlayers;
                FSPNFLTeamLeadersCell *leadersCell = (FSPNFLTeamLeadersCell *)cell;
                leadersCell.players = players;
                [leadersCell populateTopPerformers];
            }
        } else if (indexPath.section == FSPGameTopSection)
            player = [self.awayTeamTopPlayers objectAtIndex:indexPath.row];
        else
            player = [self.awayTeamBottomPlayers objectAtIndex:indexPath.row];
        
        [cell populateWithPlayer:player];
    }
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if ((self.currentGame.viewType == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) && ![self gameOver] && section == FSPNFLTopPerformersSection) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (self.currentGame.viewType == FSPSoccerViewType && section == 1) {
        if ((self.homeTeamStatsTableView == tableView && [self.homeTeamBottomPlayers count] == 0) || (self.awayTeamStatsTableView == tableView && [self.awayTeamBottomPlayers count] == 0)) {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    FSPGameStatsSectionHeaderView *sectionHeaderView = [[FSPGameStatsSectionHeaderView alloc] initWithViewType:self.currentGame.viewType section:section];
    sectionHeaderView.backgroundColor = [UIColor clearColor];
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((self.currentGame.viewType == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) && ![self gameOver] && section == FSPNFLTopPerformersSection) {
        return 0.0f;
    }
    
    if (self.currentGame.viewType == FSPSoccerViewType) {
        return 44.0;
    }
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.currentGame.viewType == FSPNFLViewType || [self.currentGame viewType] == FSPNCAAFViewType) && [indexPath section] == FSPNFLTopPerformersSection) {
        // If there is no top performer data whatsoever, hide this section
        NSSet *players;
        if([tableView isEqual:self.awayTeamStatsTableView]) {
            players = self.currentGame.awayTeamPlayers;
        }
        else {
            players = self.currentGame.homeTeamPlayers;
        }
           
        if (players.count > 0) {
            NSSortDescriptor *topPassersSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsPassing" ascending:NO];
            NSArray *topPassers = [players sortedArrayUsingDescriptors:@[topPassersSortDescriptor]];
            FSPFootballPlayer *topPasser = [topPassers objectAtIndex:0];
            
            
            NSSortDescriptor *topRusherSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsRushing" ascending:NO];
            NSArray *topRushers = [players sortedArrayUsingDescriptors:@[topRusherSortDescriptor]];
            FSPFootballPlayer *topRusher = [topRushers objectAtIndex:0];
            
            NSSortDescriptor *topReceiverSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsReceiving" ascending:NO];
            NSArray *topReceivers = [players sortedArrayUsingDescriptors:@[topReceiverSortDescriptor]];
            FSPFootballPlayer *topReceiver = [topReceivers objectAtIndex:0];

            if (topPasser.foxPointsPassing.intValue > 0 || topRusher.foxPointsRushing.intValue > 0 || topReceiver.foxPointsReceiving.intValue > 0) {
                return [FSPNFLTeamLeadersCell topPerformerViewHeight];
            }
        }
        return 0.0;
    }
    return 29.0f;
}

#pragma mark - Event Detail Section Managing Delegate

- (BOOL)isInformationComplete
{
    return ([self.currentGame.eventStarted boolValue]);
}

- (CGSize)sizeForContents;
{
    CGFloat homeTableHeight = self.homeTeamStatsTableView.contentSize.height;
    CGFloat awayTableHeight = self.awayTeamStatsTableView.contentSize.height;
    CGFloat maxTableViewHeight = MAX(homeTableHeight, awayTableHeight);
    
    CGFloat height = maxTableViewHeight + CGRectGetMaxY(self.homeBackgroundImageView.frame);
  
    return CGSizeMake(self.view.frame.size.width, height);
}

#pragma mark - Helper Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInHockeySection:(NSInteger)section
{
    NSArray *topPlayers = [tableView isEqual:self.homeTeamStatsTableView] ? self.homeTeamTopPlayers : self.awayTeamTopPlayers;
    NSArray *bottomPlayers = [tableView isEqual:self.awayTeamStatsTableView] ? self.awayTeamBottomPlayers : self.homeTeamBottomPlayers;

    switch (section) {
        case 0:
            return [topPlayers count];
        case 1:
            return [bottomPlayers count];
        default:
            return 0;
    }
}

- (BOOL)gameOver
{
    return [[self.currentGame.eventState lowercaseString] isEqualToString:@"final"];
}

- (NSUInteger)countForNFLTeamPlayersAtSection:(NSUInteger)section isHomeTeam:(BOOL)isHomeTeam
{
    switch (section) {
        case FSPNFLPassingSection:
            return isHomeTeam ? [self.homeTeamPassingPlayers count] : [self.awayTeamPassingPlayers count]; 
        case FSPNFLReceivingSection:
            return isHomeTeam ? [self.homeTeamReceivingPlayers count] : [self.awayTeamReceivingPlayers count];
        case FSPNFLRushingSection:
            return isHomeTeam ? [self.homeTeamRushingPlayers count] : [self.awayTeamRushingPlayers count];
        case FSPNFLKickingSection:
            return isHomeTeam ? [self.homeTeamKickingPlayers count] : [self.awayTeamKickingPlayers count];
        case FSPNFLDefensiveSection:
            return isHomeTeam ? [self.homeTeamDefensivePlayers count] : [self.awayTeamDefensivePlayers count];
        case FSPNFLTopPerformersSection:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)reuseIdentifierForNFLCellAtIndexPath:(NSIndexPath *)indexPath
{    
    switch ([indexPath section]) {
        case FSPNFLPassingSection:
            return FSPNFLPassingStatRowCellReuseIdentifier;
        case FSPNFLRushingSection:
            return FSPNFLRushingStatRowCellReuseIdentifier;
        case FSPNFLReceivingSection:
            return FSPNFLReceivingStatRowCellReuseIdentifier;
        case FSPNFLKickingSection:
            return FSPNFLKickingStatRowCellReuseIdentifier;
        case FSPNFLDefensiveSection:
            return FSPNFLDefensiveStatRowCellReuseIdentifier;
        case FSPNFLTopPerformersSection:
            return FSPNFLTeamLeadersRowCellReuseIdentifier;
        default:
            return nil;
    }
}

- (FSPGameStatCell *)cellForNFLBoxViewAtIndexPath:(NSIndexPath *)indexPath reuseIdentifier:(NSString *)reuseIdentifier
{
    switch ([indexPath section]) {
        case FSPNFLPassingSection:
            return [[FSPNFLPassingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];  
        case FSPNFLRushingSection:
            return [[FSPNFLRushingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case FSPNFLReceivingSection:
            return  [[FSPNFLReceivingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case FSPNFLKickingSection:
            return [[FSPNFLKickingStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case FSPNFLDefensiveSection:
            return [[FSPNFLDefensiveStatRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case FSPNFLTopPerformersSection:
            return [[FSPNFLTeamLeadersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        default:
            return nil;
    }
}

- (FSPTeamPlayer *)playerForNFLCell:(FSPGameStatCell *)cell atIndexPath:(NSIndexPath *)indexPath
{ 
    NSSet *players = nil;
    
    switch ([indexPath section]) {
        case FSPNFLPassingSection:
            return [self.homeTeamPassingPlayers objectAtIndex:indexPath.row];
        case FSPNFLRushingSection:
            return [self.homeTeamRushingPlayers objectAtIndex:indexPath.row];
        case FSPNFLReceivingSection:
            return [self.homeTeamReceivingPlayers objectAtIndex:indexPath.row];
        case FSPNFLKickingSection:
            return [self.homeTeamKickingPlayers objectAtIndex:indexPath.row];
        case FSPNFLDefensiveSection:
            return [self.homeTeamDefensivePlayers objectAtIndex:indexPath.row];
        case FSPNFLTopPerformersSection:
            players = self.currentGame.homeTeamPlayers;
            FSPNFLTeamLeadersCell *leadersCell = (FSPNFLTeamLeadersCell *)cell;
            leadersCell.players = players;
            [leadersCell populateTopPerformers];
            return nil;
    }
    return nil;
}

- (void)updatePlayers
{
    NSMutableArray *homeTeamTop = [NSMutableArray array];
    NSMutableArray *homeTeamBottom = [NSMutableArray array];
    NSMutableArray *awayTeamTop = [NSMutableArray array];
    NSMutableArray *awayTeamBottom = [NSMutableArray array];
    
    NSMutableArray *homeTeamPassing = [NSMutableArray array];
    NSMutableArray *homeTeamRushing = [NSMutableArray array];
    NSMutableArray *homeTeamReceiving = [NSMutableArray array];
    NSMutableArray *homeTeamKicking = [NSMutableArray array];
	NSMutableArray *homeTeamDefensive = [NSMutableArray array];
    
    NSMutableArray *awayTeamPassing = [NSMutableArray array];
    NSMutableArray *awayTeamRushing = [NSMutableArray array];
    NSMutableArray *awayTeamReceiving = [NSMutableArray array];
    NSMutableArray *awayTeamKicking = [NSMutableArray array];
	NSMutableArray *awayTeamDefensive = [NSMutableArray array];

    NSArray *sortDescriptorsStarter;
    NSArray *sortDescriptorsBench;
    
    NSArray *sortDescriptorsPassing;
    NSArray *sortDescriptorsRushing;
    NSArray *sortDescriptorsReceiving;
    NSArray *sortDescriptorsKicking;
	NSArray *sortDescriptorsDefensive;
    
	FSPViewType viewType = self.currentGame.viewType;
	switch (viewType) {
		case FSPBasketballViewType: {
        case FSPNCAABViewType:
        case FSPNCAAWBViewType:
			for (FSPTeamPlayer *player in self.currentGame.homeTeamPlayers) {
				if ([player.starter boolValue]) {
					[homeTeamTop addObject:player];
				}
				else {
					[homeTeamBottom addObject:player];
				}
			}
			for (FSPTeamPlayer *player in self.currentGame.awayTeamPlayers) {
				if ([player.starter boolValue]) {
					[awayTeamTop addObject:player];
				}
				else {
					[awayTeamBottom addObject:player];
				}
			}
			
			NSSortDescriptor *lastNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
			NSSortDescriptor *minutesPlayedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"minutesPlayed" ascending:NO];
			NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES comparator:^NSComparisonResult(FSPBasketballPlayer* obj1, FSPBasketballPlayer* obj2) {
				NSNumber *pos1 = @([self positionNumberFromPosition:obj1.position]);
				NSNumber *pos2 = @([self positionNumberFromPosition:obj2.position]);
				return [pos1 compare:pos2];
			}];
			sortDescriptorsStarter = @[positionSortDescriptor, lastNameSortDescriptor];
			sortDescriptorsBench = @[minutesPlayedSortDescriptor];
			break;
		}
		case FSPBaseballViewType: {

			for (FSPBaseballPlayer *player in self.currentGame.homeTeamPlayers) {
				if ((player.starter.boolValue || player.subBatting.intValue != 0) && ![player.battingOrder isEqualToNumber:@0]) {
					[homeTeamTop addObject:player];
				}
				if ((player.starter.boolValue || player.subPitching.intValue != 0) && [player.position isEqualToString:@"P"]) {
					[homeTeamBottom addObject:player];
				}
			}
			
			
			for (FSPBaseballPlayer *player in self.currentGame.awayTeamPlayers) {
				if ((player.starter.boolValue || player.subBatting.intValue != 0) && ![player.battingOrder isEqualToNumber:@0]) {
					[awayTeamTop addObject:player];
				}
				if ((player.starter.boolValue || player.subPitching.intValue != 0) && [player.position isEqualToString:@"P"]) {
					[awayTeamBottom addObject:player];
				}
			}
			
			NSSortDescriptor *lastNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
			NSSortDescriptor *sequenceSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"battingOrder" ascending:YES];
			NSSortDescriptor *subBattingSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subBatting" ascending:YES];
			NSSortDescriptor *subPitchingSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subPitching" ascending:YES];
			sortDescriptorsStarter = @[sequenceSortDescriptor, subBattingSortDescriptor, lastNameSortDescriptor];
			sortDescriptorsBench = @[subPitchingSortDescriptor, lastNameSortDescriptor];
			break;
		}
		case FSPNFLViewType:
		case FSPNCAAFViewType: {
//            NSLog(@"updating football players");
//            NSLog(@"hometeam %@ : %@", self.currentGame.homeTeam.name, [self.currentGame.homeTeamPlayers valueForKey:@"lastName"]);
//            NSLog(@"awayteam %@ : %@", self.currentGame.awayTeam.name, [self.currentGame.awayTeamPlayers valueForKey:@"lastName"]);
			for (FSPFootballPlayer *player in self.currentGame.homeTeamPlayers) {
				if ([player.passingAttempts intValue] > 0) {
					[homeTeamPassing addObject:player];
				} else if ([player.rusingAttempts intValue] > 0) {
					[homeTeamRushing addObject:player];
				} else if ([player.receptions intValue] > 0) {
					[homeTeamReceiving addObject:player];
				} else if ([player.kickingExtraPointAttempts intValue] > 0 || [player.fieldGoalAttempts intValue] > 0) {
					[homeTeamKicking addObject:player];
				}
				if ([player.foxPointsDefense integerValue] > 0) {
					[homeTeamDefensive addObject:player];
				}
			}
			
			for (FSPFootballPlayer *player in self.currentGame.awayTeamPlayers) {
				if ([player.passingAttempts intValue] > 0) {
					[awayTeamPassing addObject:player];
				} else if ([player.rusingAttempts intValue] > 0) {
					[awayTeamRushing addObject:player];
				} else if ([player.receptions intValue] > 0) {
					[awayTeamReceiving addObject:player];
				} else if ([player.kickingExtraPointAttempts intValue] > 0 || [player.fieldGoalAttempts intValue] > 0) {
					[awayTeamKicking addObject:player];
				}
				if ([player.foxPointsDefense integerValue] > 0) {
					[awayTeamDefensive addObject:player];
				}
			}
			

			NSSortDescriptor *passingYardsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"passingYards" ascending:NO];
			NSSortDescriptor *rushingYardsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rushingYards" ascending:NO];
			NSSortDescriptor *receptionYardsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receptionYards" ascending:NO];
			NSSortDescriptor *fieldGoalsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fieldGoalsMade" ascending:NO];
			NSSortDescriptor *defensiveSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"foxPointsDefense" ascending:NO];
			
			sortDescriptorsPassing = @[passingYardsSortDescriptor];
			sortDescriptorsRushing = @[rushingYardsSortDescriptor];
			sortDescriptorsReceiving = @[receptionYardsSortDescriptor];
			sortDescriptorsKicking = @[fieldGoalsSortDescriptor];
			sortDescriptorsDefensive = @[defensiveSortDescriptor];
			break;
		}
        case FSPSoccerViewType: {
            for (FSPSoccerPlayer *player in self.currentGame.homeTeamPlayers) {
                if ([player.starter intValue] > 0) {
                    [homeTeamTop addObject:player];
                } else if ([player.minutesPlayed intValue] > 0){
                    [homeTeamBottom addObject:player];
                }
            }
            for (FSPSoccerPlayer *player in self.currentGame.awayTeamPlayers) {
                if ([player.starter intValue] > 0) {
                    [awayTeamTop addObject:player];
                } else if ([player.minutesPlayed intValue] > 0){
                    [awayTeamBottom addObject:player];
                }
            }
            
            NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES comparator:^NSComparisonResult(FSPSoccerPlayer* obj1, FSPSoccerPlayer* obj2) {
				NSNumber *pos1 = @([self positionNumberFromPosition:obj1.position]);
				NSNumber *pos2 = @([self positionNumberFromPosition:obj2.position]);
				return [pos1 compare:pos2];
			}];
            NSSortDescriptor *lastNameSortDescript = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
			NSSortDescriptor *subSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sub" ascending:YES];
			sortDescriptorsStarter = @[positionSortDescriptor, lastNameSortDescript];
			sortDescriptorsBench = @[positionSortDescriptor, lastNameSortDescript, subSortDescriptor];
            break;
        }
        case FSPHockeyViewType: {
            for (FSPHockeyPlayer *player in self.currentGame.homeTeamPlayers) {
                if ([[player.position lowercaseString] isEqualToString:@"goaltender"] && [player.timeOnIceSecs integerValue] > 0) {
                    [homeTeamBottom addObject:player];
                } else if ([player.timeOnIceSecs integerValue]) {
                    [homeTeamTop addObject:player];
                }
            }
            for (FSPHockeyPlayer *player in self.currentGame.awayTeamPlayers) {
                if ([[player.position lowercaseString] isEqualToString:@"goaltender"] && [player.timeOnIceSecs integerValue] > 0) {
                    [awayTeamBottom addObject:player];
                } else if ([player.timeOnIceSecs integerValue]) {
                    [awayTeamTop addObject:player];
                }
            }
            
            NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
			NSSortDescriptor *subSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sub" ascending:YES];
			sortDescriptorsStarter = @[positionSortDescriptor];
			sortDescriptorsBench = @[positionSortDescriptor, subSortDescriptor];
            break;
        }
		default:
			break;
    }
    
    self.homeTeamTopPlayers = [homeTeamTop sortedArrayUsingDescriptors:sortDescriptorsStarter];
    self.homeTeamBottomPlayers = [homeTeamBottom sortedArrayUsingDescriptors:sortDescriptorsBench];
    self.awayTeamTopPlayers = [awayTeamTop sortedArrayUsingDescriptors:sortDescriptorsStarter];
    self.awayTeamBottomPlayers = [awayTeamBottom sortedArrayUsingDescriptors:sortDescriptorsBench];
    
    self.homeTeamPassingPlayers = [homeTeamPassing sortedArrayUsingDescriptors:sortDescriptorsPassing];
    self.awayTeamPassingPlayers = [awayTeamPassing sortedArrayUsingDescriptors:sortDescriptorsPassing];
    self.homeTeamRushingPlayers = [homeTeamRushing sortedArrayUsingDescriptors:sortDescriptorsRushing];
    self.awayTeamRushingPlayers = [awayTeamRushing sortedArrayUsingDescriptors:sortDescriptorsRushing];
    self.homeTeamReceivingPlayers = [homeTeamReceiving sortedArrayUsingDescriptors:sortDescriptorsReceiving];
    self.awayTeamReceivingPlayers = [awayTeamReceiving sortedArrayUsingDescriptors:sortDescriptorsReceiving];
    self.homeTeamKickingPlayers = [homeTeamKicking sortedArrayUsingDescriptors:sortDescriptorsKicking];
    self.awayTeamKickingPlayers = [awayTeamKicking sortedArrayUsingDescriptors:sortDescriptorsKicking];
    self.homeTeamDefensivePlayers = [homeTeamDefensive sortedArrayUsingDescriptors:sortDescriptorsDefensive];
    self.awayTeamDefensivePlayers = [awayTeamDefensive sortedArrayUsingDescriptors:sortDescriptorsDefensive];
}

- (int)positionNumberFromPosition:(NSString *)position
{
    int playerPos = 0;
    if ([position isEqualToString:@"F"]){
        playerPos = FSPForwardPosition;
    } else if ([position isEqualToString:@"C"]) {
        playerPos = FSPCenterPosition;
    } else if ([position isEqualToString:@"G"]) {
        playerPos = FSPGuardPosition;
    } else if ([position isEqualToString:@"GK"] || [position isEqualToString:@"Goalkeeper"]) {
        playerPos = FSPGoalkeeperPosition;
    } else if ([position isEqualToString:@"D"] || [position isEqualToString:@"Defender"]) {
        playerPos = FSPDefenderPosition;
    } else if ([position isEqualToString:@"M"] || [position isEqualToString:@"Midfielder"]) {
        playerPos = FSPMidfieldPosition;
    } else if ([position isEqualToString:@"F"] || [position isEqualToString:@"Forward"]) {
        playerPos = FSPSoccerForwardPosition;
    }
    return playerPos;
}

@end

@implementation FSPBoxScoreViewController (Drawing)

static void drawBlackLine(CGContextRef context, CGPoint segment[2])
{
    CGContextSaveGState(context);
    [[UIColor colorWithWhite:0.0f alpha:0.0f] set];
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetLineWidth(context, 10.0);
    CGContextStrokeLineSegments(context, segment, 1);
    CGContextRestoreGState(context);
}

- (UIImage *)arrowBackgroundForDirection:(FSPChevronDirection)chevronDirection frame:(CGRect)frame fillColor:(UIColor *)fillColor;
{
    CGFloat chevronWidth = frame.size.width;
    CGFloat chevronHeight = frame.size.height;
    CGFloat chevronMidY = floor(frame.size.height/2);
    
    CGPoint topPoint;
    CGPoint midPoint;
    CGPoint bottomPoint;
    if (chevronDirection == FSPChevronDirectionLeft) {
        topPoint = CGPointMake(chevronWidth, 0.0);
        midPoint = CGPointMake(0.0, chevronMidY);
        bottomPoint = CGPointMake(chevronWidth, chevronHeight);
    } else {
        topPoint = CGPointMake(0.0, 0.0);
        midPoint = CGPointMake(chevronWidth, chevronMidY);
        bottomPoint = CGPointMake(0.0, chevronHeight);
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, topPoint.x, 0.0);
    if (chevronDirection == FSPChevronDirectionLeft) {
        CGPathAddLineToPoint(path, NULL, midPoint.x, chevronMidY);
        CGPathAddLineToPoint(path, NULL, bottomPoint.x, chevronHeight);
        CGPathAddLineToPoint(path, NULL, topPoint.x, 0.0);
    } else {
        CGPathAddLineToPoint(path, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(path, NULL, chevronWidth, chevronMidY);
        CGPathAddLineToPoint(path, NULL, 0.0, chevronHeight);
        CGPathAddLineToPoint(path, NULL, chevronWidth, chevronHeight);
        CGPathAddLineToPoint(path, NULL, chevronWidth, 0.0);
    }
    CGPathCloseSubpath(path);
    
    UIGraphicsBeginImageContext(CGSizeMake(chevronWidth, chevronHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Fill in team color
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextSetBlendMode(context,  kCGBlendModeOverlay);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetFillColorSpace(context, colorSpace);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextSaveGState(context);
    UIImage *bezel = [[UIImage imageNamed:@"team_header_bezel"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [bezel drawInRect:CGRectMake(0, -1, frame.size.width, frame.size.height+2)];
    CGContextRestoreGState(context);
    
    //Draw dark arrow outline
    [[UIColor fsp_colorWithIntegralRed:0 green:16 blue:35 alpha:1.0] setStroke];
    CGPoint arrowPointSegments[] = {topPoint, midPoint, midPoint, bottomPoint};
    CGContextStrokeLineSegments(context, arrowPointSegments, 4);
    
    UIImage *arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(colorSpace);
    CGPathRelease(path);
    return arrowImage;
}


@end
