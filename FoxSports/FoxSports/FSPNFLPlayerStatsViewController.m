//
//  FSPNFLPlayerStatsViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBoxScoreViewController.h"
#import "FSPNFLPlayerStatsViewController.h"
#import "FSPGameTopPlayersViewContainer.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPFootballPlayer.h"

@interface FSPNFLPlayerStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *noStatsAvailableLabel;
@property (weak, nonatomic) IBOutlet UIView *boxScoreContainer;

@end

@implementation FSPNFLPlayerStatsViewController

@synthesize noStatsAvailableLabel = _noStatsAvailableLabel;
@synthesize boxScoreContainer = _boxScoreContainer;
@synthesize currentEvent = _currentEvent;

- (id)init
{
	self = [super initWithNibName:@"FSPNFLPlayerStatsViewController" bundle:nil];
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
    self.boxScoreViewController = [[FSPBoxScoreViewController alloc] initWithGame:nil];
    [self.boxScoreContainer addSubview:self.boxScoreViewController.view];
    self.boxScoreViewController.view.frame = self.boxScoreContainer.bounds;
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
