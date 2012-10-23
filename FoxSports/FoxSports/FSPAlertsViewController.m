//
//  FSPAlertsViewController.m
//  FoxSports
//
//  Created by greay on 5/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPAlertsViewController.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPEvent.h"

#import "NSDate+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

enum {
	kStartRow = 0,
	kFinishRow,
	kPhaseRow,
	kScoreRow,
	kUpdateRow,
	kExcitingRow
};


@interface FSPEvent (Alerts)
- (NSString *)alertEventTitle;
@end

@implementation FSPEvent (Alerts)
- (NSString *)alertEventTitle;
{
    if ([self isKindOfClass:[FSPGame class]]) {
        FSPGame *game  = (FSPGame *)self;
        return [NSString stringWithFormat:@"%@ @ %@", [game.awayTeam shortNameDisplayString], [game.homeTeam shortNameDisplayString]];
    }
    
    return [self valueForKey:@"eventTitle"];
}
@end


@interface FSPAlertsViewController ()
@property (nonatomic, strong) NSArray *rowIdentifiers;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) FSPEvent *event;
@end


@implementation FSPAlertsViewController

@synthesize teamsLabel, timeLabel;
@synthesize switchControl;
@synthesize gameStartAlerts, finalAlerts, eachScoringPlayAlerts, eachQuarterAlerts, updateAlerts, excitingAlerts;
@synthesize event;

@synthesize rowIdentifiers;
@synthesize headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		self.title = @"Game Alerts";

		UINib *nib = [UINib nibWithNibName:@"FSPAlertsViewHeader" bundle:nil];
		NSArray *nibObjects = [nib instantiateWithOwner:self options:nil];
		self.headerView = [nibObjects lastObject];
		
		self.teamsLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:16];
		self.teamsLabel.textColor = [UIColor chipTextShadowSelectedColor];
		self.teamsLabel.shadowColor = [UIColor whiteColor];
		self.timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
		self.timeLabel.textColor = [UIColor chipTextShadowSelectedColor];
		self.timeLabel.shadowColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)populateWithEvent:(FSPEvent *)anEvent
{
	self.event = anEvent;
	
	FSPGame *game = (FSPGame *)self.event;
	
	NSString *timeString = @"";
	if ([game.startDate fsp_isToday]) {
		timeString = @"Today ";
	}
	self.timeLabel.text = [timeString stringByAppendingString:[game.startDate fsp_lowercaseMeridianDateString]];
	self.teamsLabel.text = [anEvent alertEventTitle];

	// this *should* be on if we've subscribed to alerts for this event
	self.switchControl.on = NO;
	
	NSDictionary *subscribedAlerts = nil;
	NSArray *allSubs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
	for (NSDictionary *sub in allSubs) {
		if ([[sub valueForKey:@"fsId"] isEqualToString:event.uniqueIdentifier]) {
			subscribedAlerts = [sub valueForKey:@"alerts"];
			break;
		}
	}

	NSUInteger alerts = [[self.event getPrimaryOrganization].alertMask unsignedIntegerValue];
	NSMutableArray *rows = [NSMutableArray array];
	if (alerts & FSPAlertsStart) {
		[rows addObject:@(kStartRow)];
		self.gameStartAlerts = [[subscribedAlerts valueForKey:@"startAlert"] boolValue];
	}
	if (alerts & FSPAlertsScore) {
		[rows addObject:@(kScoreRow)];
		self.eachScoringPlayAlerts = [[subscribedAlerts valueForKey:@"scoreBasedAlert"] boolValue];
	}
	if (alerts & FSPAlertsPhase) {
		[rows addObject:@(kPhaseRow)];
		self.eachQuarterAlerts = [[subscribedAlerts valueForKey:@"phaseBasedAlert"] boolValue];
	}
	if (alerts & FSPAlertsFinish) {
		[rows addObject:@(kFinishRow)];
		self.finalAlerts = [[subscribedAlerts valueForKey:@"finishAlert"] boolValue];
	}
	if (alerts & FSPAlertsUpdate) {
		[rows addObject:@(kUpdateRow)];
		self.updateAlerts = [[subscribedAlerts valueForKey:@"updateAlert"] boolValue];
	}
	if (alerts & FSPAlertsExciting) {
		[rows addObject:@(kExcitingRow)];
		self.excitingAlerts = [[subscribedAlerts valueForKey:@"excitingGameAlert"] boolValue];
	}
	
	self.rowIdentifiers = rows;
	
	self.contentSizeForViewInPopover = CGSizeMake(320, 124 + [self.rowIdentifiers count] * self.tableView.rowHeight);
}

- (void)populateWithOrganization:(FSPOrganization *)org
{
	
}

#pragma mark - Tableview

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 102.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return self.headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.rowIdentifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
		cell.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
	}
	
	BOOL selected = NO;
	
	NSUInteger rowIdentifier = [[self.rowIdentifiers objectAtIndex:indexPath.row] unsignedIntegerValue];
	
	NSString *branch = [self.event baseBranch];
	
	switch (rowIdentifier) {
		case kStartRow:
			if ([branch isEqualToString:FSPNASCAREventBranchType]) {
				cell.textLabel.text = @"Race Start";
			} else if ([branch isEqualToString:FSPSoccerEventBranchType]) {
				cell.textLabel.text = @"Match Start";
			} else if ([branch isEqualToString:FSPGolfBranchType] || [branch isEqualToString:FSPUFCEventBranchType]) {
				cell.textLabel.text = @"Event Start";
			} else {
				cell.textLabel.text = @"Game Start";
			}
	
			if (self.gameStartAlerts) selected = YES;
			break;
		
		case kScoreRow:
			if ([branch isEqualToString:FSPSoccerEventBranchType]) {
				cell.textLabel.text = @"Scoring Plays";
			} else if ([branch isEqualToString:FSPGolfBranchType]) {
				cell.textLabel.text = @"Hour Updates";
			} else {
				cell.textLabel.text = @"Each Scoring Play";
			}

			if (self.eachScoringPlayAlerts) selected = YES;
			break;
		
		case kPhaseRow:
			if ([branch isEqualToString:FSPNCAAFootballEventBranchType]) {
				cell.textLabel.text = @"Halftime Score";
			} else if ([branch isEqualToString:FSPMLBEventBranchType]) {
				cell.textLabel.text = @"Each Inning";
			} else if ([branch isEqualToString:FSPNHLEventBranchType]) {
				cell.textLabel.text = @"Each Period";
			} else if ([branch isEqualToString:FSPSoccerEventBranchType]) {
				cell.textLabel.text = @"Score at Half";
			} else if ([branch isEqualToString:FSPGolfBranchType]) {
				cell.textLabel.text = @"By Day Results";
			} else if ([branch isEqualToString:FSPUFCEventBranchType]) {
				cell.textLabel.text = @"Undercard Results";
			} else {
				cell.textLabel.text = @"Each Quarter";
			}
			if (self.eachQuarterAlerts) selected = YES;
			break;
		
		case kFinishRow:
			if ([branch isEqualToString:FSPNASCAREventBranchType]) {
				cell.textLabel.text = @"Race Results";
			} else if ([branch isEqualToString:FSPGolfBranchType]) {
				cell.textLabel.text = @"Final Results";
			} else if ([branch isEqualToString:FSPUFCEventBranchType]) {
				cell.textLabel.text = @"Main Event Results";
			} else {
				cell.textLabel.text = @"Final Score";
			}
			if (self.finalAlerts) selected = YES;
			break;
		
		case kUpdateRow:
            if ([branch isEqualToString:FSPSoccerEventBranchType]) {
                cell.textLabel.text = @"Red Cards";
            } else if ([branch isEqualToString:FSPNASCAREventBranchType]) {
				cell.textLabel.text = @"Race Updates";
            } else {
                cell.textLabel.text = @"Event-specific updates";
            }
			if (self.updateAlerts) selected = YES;
			break;
		
		case kExcitingRow:
			cell.textLabel.text = @"Exciting Game Alerts";
			if (self.excitingAlerts) selected = YES;
			break;
	}
	
	if (selected) {
		cell.imageView.image = [UIImage imageNamed:@"checkmark"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"empty_circle"];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger rowIdentifier = [[self.rowIdentifiers objectAtIndex:indexPath.row] unsignedIntegerValue];
	switch (rowIdentifier) {
		case kStartRow:
			self.gameStartAlerts = !self.gameStartAlerts;
			break;
		case kScoreRow:
			self.eachScoringPlayAlerts = !self.eachScoringPlayAlerts;
			break;
		case kPhaseRow:
			self.eachQuarterAlerts = !self.eachQuarterAlerts;
			break;
		case kFinishRow:
			self.finalAlerts = !self.finalAlerts;
			break;
		case kUpdateRow:
			self.updateAlerts = !self.updateAlerts;
			break;
		case kExcitingRow:
			self.excitingAlerts = !self.updateAlerts;
			break;
	}
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
