//
//  FSPMLBHitterVsPitcherMatchupView.m
//  FoxSports
//
//  Created by greay on 6/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBHitterVsPitcherMatchupView.h"
#import "FSPGameTopPlayerView.h"
#import "FSPMLBGameStateIndicatorView.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

#import "FSPGame.h"
#import "FSPBaseballGame.h"
#import "FSPBaseballPlayer.h"
#import "FSPGamePlayByPlayItem.h"

@interface FSPMLBHitterVsPitcherMatchupView (){
    CGFloat fontSize;
}

@property(nonatomic, weak) FSPGameTopPlayerView *leftPlayerView;
@property(nonatomic, weak) FSPGameTopPlayerView *rightPlayerView;

@property (nonatomic, weak) IBOutlet UILabel *inningLabel;
@property (nonatomic, weak) IBOutlet FSPMLBGameStateIndicatorView *gameStateView;

@end

@implementation FSPMLBHitterVsPitcherMatchupView

@synthesize inningLabel;
@synthesize leftPlayerView, rightPlayerView;
@synthesize gameStateView;

- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPMLBHitterVsPitcherMatchupView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    return self;
}

- (void)awakeFromNib
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = 12.0f;
    } else {
        fontSize = 14.0f;
    }
    
	self.inningLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
	self.inningLabel.textColor = [UIColor whiteColor];
    
    self.leftPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    self.rightPlayerView = [[FSPGameTopPlayerView alloc] initWithDirection:FSPGamePlayerDirectionRight];
    [self addSubview:self.leftPlayerView];
    [self addSubview:self.rightPlayerView];
    
	CGRect frame, leftFrame, rightFrame;
	frame = CGRectInset(self.bounds, 0, 0);
	
	CGRectDivide(frame, &leftFrame, &frame, CGRectGetMinX(self.gameStateView.frame) - 20, CGRectMinXEdge);
	CGRectDivide(frame, &frame, &rightFrame, self.gameStateView.bounds.size.width + 20, CGRectMinXEdge);
	
    self.leftPlayerView.frame = leftFrame;
    self.rightPlayerView.frame = rightFrame;
}

- (void)updateInterfaceWithGame:(FSPGame *)game
{
    if (![game isKindOfClass:[FSPBaseballGame class]]) return;

    FSPBaseballGame *baseballGame = (FSPBaseballGame *)game;
	FSPGamePlayByPlayItem *item = [game gameStatePlayByPlayItem];
    
    [self resetPlayerLabelsFont];
	
	self.inningLabel.text = [item shortPeriodTitle];
	
    //TODO: populate the home and away pitchers views
	BOOL isTopOfInning = [item.topBottom isEqualToString:@"T"];
	
	FSPBaseballPlayer *homePlayer = item.currentPlayerHome;
	FSPBaseballPlayer *awayPlayer = item.currentPlayerAway;
	
	if (isTopOfInning) {
		[self.leftPlayerView populateWithPlayer:awayPlayer statType:@"AVG" statValue:awayPlayer.battingAverage title:@"Hitter"];
		[self.rightPlayerView populateWithPlayer:homePlayer statType:@"ERA" statValue:homePlayer.seasonERA title:@"Pitcher"];
	} else {
		[self.leftPlayerView populateWithPlayer:awayPlayer statType:@"ERA" statValue:awayPlayer.seasonERA title:@"Pitcher"];
		[self.rightPlayerView populateWithPlayer:homePlayer statType:@"AVG" statValue:homePlayer.battingAverage title:@"Hitter"];
	}
	
	[self.gameStateView populateWithGame:baseballGame];
}

- (void)resetPlayerLabelsFont
{

}

@end
