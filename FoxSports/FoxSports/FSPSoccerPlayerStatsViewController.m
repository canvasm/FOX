//
//  FSPSoccerStatsViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBoxScoreViewController.h"
#import "FSPSoccerPlayerStatsViewController.h"
#import "FSPGameTopPlayersViewContainer.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPFootballPlayer.h"

@interface FSPSoccerPlayerStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *noStatsAvailableLabel;
@property (weak, nonatomic) IBOutlet UIView *boxScoreContainer;

@end

@implementation FSPSoccerPlayerStatsViewController

@synthesize noStatsAvailableLabel = _noStatsAvailableLabel;
@synthesize boxScoreContainer = _boxScoreContainer;
@synthesize currentEvent = _currentEvent;

- (id)init
{
	self = [super initWithNibName:@"FSPSoccerPlayerStatsViewController" bundle:nil];
	if (self) {
        
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addStatsView];
}

- (void)viewDidUnload
{
    [self setNoStatsAvailableLabel:nil];
    [self setBoxScoreContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addStatsView
{
    self.lineScoreBox.hidden = YES;
    self.lineScoreBox.frame = CGRectZero;
    self.boxScoreViewController = [[FSPBoxScoreViewController alloc] initWithGame:nil];
    self.boxScoreViewController.view.frame = self.boxScoreContainer.bounds;
    [self.boxScoreContainer addSubview:self.boxScoreViewController.view];
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    
    if ((_currentEvent != currentEvent) && ([currentEvent isKindOfClass:[FSPGame class]])) {
        _currentEvent = currentEvent;
        
        [self updateInterface];
    }
}

- (void)updateInterface
{
    self.boxScoreViewController.currentGame = (FSPGame *)self.currentEvent;
    [super updateInterface];
}

@end

