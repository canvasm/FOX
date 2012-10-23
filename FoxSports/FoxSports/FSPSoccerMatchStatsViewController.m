//
//  FSPSoccerMatchStatsViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerMatchStatsViewController.h"
#import "FSPGame.h"
#import "FSPSoccerGame.h"
#import "FSPSoccerCard.h"
#import "FSPSoccerGoal.h"
#import "FSPSoccerSub.h"
#import "FSPSoccerMatchStatsCell.h"
#import "FSPSoccerMatchupHeaderView.h"
#import "FSPGameDetailTeamHeader.h"
#import "UIFont+FSPExtensions.h"

NSString * const FSPSoccerMatchStatsReuseIdentifier = @"FSPSoccerMatchStatsReuseIdentifier";

@interface FSPSoccerMatchStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *noStatsAvailableLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation FSPSoccerMatchStatsViewController

@synthesize noStatsAvailableLabel = _noStatsAvailableLabel;
@synthesize currentEvent = _currentEvent;

- (id)init
{
	self = [super initWithNibName:@"FSPSoccerMatchStatsViewController" bundle:nil];
	if (self) {
        
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [self setNoStatsAvailableLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    
    if ((_currentEvent != currentEvent) && ([currentEvent isKindOfClass:[FSPSoccerGame class]])) {
        _currentEvent = currentEvent;
        
        [self updateInterface];
    }
}

- (void)updateInterface
{
    [super updateInterface];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger coverageLevel = [[(FSPSoccerGame *)self.currentEvent coverageLevel] integerValue];
	if (coverageLevel == 2 || coverageLevel == 3) {
		return 3;
	} else {
		return 4;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FSPSoccerMatchStatsCell heightForSoccerGame:(FSPSoccerGame *)self.currentEvent atIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPSoccerMatchStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPSoccerMatchStatsReuseIdentifier];
    if (!cell) {
        cell = [[FSPSoccerMatchStatsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FSPSoccerMatchStatsReuseIdentifier];
    }
    [cell populateCellWithIndex:indexPath.row forSoccerGame:(FSPSoccerGame *)self.currentEvent];
	return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FSPSoccerMatchupHeaderView *header = [[FSPSoccerMatchupHeaderView alloc] init];
    FSPGame *game = (FSPGame *)self.currentEvent;
    [header.teamHeaderAway setTeam:game.awayTeam teamColor:game.awayTeamColor];
    [header.teamHeaderHome setTeam:game.homeTeam teamColor:game.homeTeamColor];
    header.teamHeaderAway.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0f];
    header.teamHeaderAway.teamNameLabel.textColor = [UIColor whiteColor];
    header.teamHeaderHome.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0f];
    header.teamHeaderHome.teamNameLabel.textColor = [UIColor whiteColor];
	return header;
}



@end

