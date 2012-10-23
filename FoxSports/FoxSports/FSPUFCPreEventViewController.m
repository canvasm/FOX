//
//  FSPUFCPreEventViewController.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCPreEventViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPEvent.h"
#import "FSPUFCEvent.h"
#import "FSPUFCFight.h"
#import "FSPUFCPlayer.h"
#import "FSPImageFetcher.h"

#import "FSPUFCPreEventCell.h"

@interface FSPUFCPreEventViewController ()

@property (nonatomic, weak) FSPUFCEvent *ufcEvent;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@end

NSString * const FSPUFCPreEventCellReuseIdentifier = @"FSPUFCPreEventCellReuseIdentifier";
NSString * const FSPUFCPreEventCellNibName = @"FSPUFCPreEventCell";


@implementation FSPUFCPreEventViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize ufcEvent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];

    [self.tableView registerNib:[UINib nibWithNibName:FSPUFCPreEventCellNibName bundle:nil]  forCellReuseIdentifier:FSPUFCPreEventCellReuseIdentifier];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 445;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    [self.tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (FSPUFCEvent *)ufcEvent;
{
    return (FSPUFCEvent *)self.currentEvent;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent && ([currentEvent isKindOfClass:[FSPUFCEvent class]])) {
        _currentEvent = currentEvent;
        [self.dataCoordinator updateMatchupForUFCEvent:currentEvent.objectID];
        [self.tableView reloadData];
        if (self.ufcEvent.fights.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:NO];
        }
    }
}

- (void)eventDidUpdate;
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 710.0f;
    } 
    return 700;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ufcEvent.fights.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPUFCPreEventCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPUFCPreEventCellReuseIdentifier];
    if (!cell) {
        cell = [[FSPUFCPreEventCell alloc] init ];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray *array = [[[self.ufcEvent fights] allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES]]];
    FSPUFCFight *fight = [array objectAtIndex:indexPath.row];

    // photos
    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:fight.fighter1.photoURL]
                                       withCallback:^(UIImage *image) {
                                           if (image) {
                                               cell.fighterOneImage.image = image;
                                           } else {
                                               cell.fighterOneImage.image = [UIImage imageNamed:@"Default_Headshot_UFC"];
                                           }
                                       }];
    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:fight.fighter2.photoURL]
                                       withCallback:^(UIImage *image) {
                                           if (image) {
                                               cell.fighterTwoImage.image = image;
                                           } else {
                                               cell.fighterTwoImage.image = [UIImage imageNamed:@"Default_Headshot_UFC"];
                                           }
                                       }];
    
    // status
    [cell.fightProgress setTitle:fight.fightStatus forState:UIControlStateNormal];
    
    // names
    cell.fighterOneName.text = [NSString stringWithFormat:@"%@ %@", fight.fighter1.firstName.uppercaseString, fight.fighter1.lastName.uppercaseString];
    cell.fighterTwoName.text = [NSString stringWithFormat:@"%@ %@", fight.fighter2.firstName.uppercaseString, fight.fighter2.lastName.uppercaseString];
    
    // nicks
    if (![fight.fighter1.nickname isEqualToString:@""])
        cell.fighterOneNick.text = [NSString stringWithFormat:@"\"%@\"", fight.fighter1.nickname];
    if (![fight.fighter2.nickname isEqualToString:@""])
        cell.fighterTwoNick.text = [NSString stringWithFormat:@"\"%@\"", fight.fighter2.nickname];

    // WLD
    cell.fighterOneWLD.text = [NSString stringWithFormat:@"%@-%@-%@", fight.fighter1.wins, fight.fighter1.losses, fight.fighter1.draws];
    cell.fighterTwoWLD.text = [NSString stringWithFormat:@"%@-%@-%@", fight.fighter2.wins, fight.fighter2.losses, fight.fighter2.draws];

    NSNumber *noValue = @0;
    
    // height
    cell.fighterOneHeight.text = [fight.fighter1.height isEqualToNumber:noValue] ? @"--" : [fight.fighter1.height stringValue];
    cell.fighterTwoHeight.text = [fight.fighter2.height isEqualToNumber:noValue] ? @"--" : [fight.fighter2.height stringValue];
 
    // weight
    cell.fighterOneWeight.text = [fight.fighter1.weight isEqualToNumber:noValue] ? @"--" : [fight.fighter1.weight stringValue];
    cell.fighterTwoWeight.text = [fight.fighter2.weight isEqualToNumber:noValue] ? @"--" : [fight.fighter2.weight stringValue];

    // reach
    cell.fighterOneReach.text = [fight.fighter1.reach isEqualToNumber:noValue] ? @"--" : [fight.fighter1.reach stringValue];
    cell.fighterTwoReach.text = [fight.fighter2.reach isEqualToNumber:noValue] ? @"--" : [fight.fighter2.reach stringValue];
    
    // age
    cell.fighterOneAge.text = [fight.fighter1.age isEqualToNumber:noValue] ? @"--" : [fight.fighter1.age stringValue];
    cell.fighterTwoAge.text = [fight.fighter2.age isEqualToNumber:noValue] ? @"--" : [fight.fighter2.age stringValue];
    
    // hometown
    cell.fighterOneHometown.text = fight.fighter1.homeTown ? @"--" : fight.fighter1.homeTown;
    cell.fighterTwoHometown.text = fight.fighter2.homeTown ? @"--" : fight.fighter2.homeTown;

    // fights out of
    cell.fighterOneFightsOutOf.text = fight.fighter1.fightsOutOf ? @"--" : fight.fighter1.fightsOutOf;
    cell.fighterTwoFightsOutOf.text = fight.fighter2.fightsOutOf ? @"--" : fight.fighter2.fightsOutOf;
    
    // striks per min
    cell.fighterOneStrikesLandedPerMinute.text = [fight.fighter1.strikesLandedPerMinute isEqualToNumber:noValue] ? @"--" : [fight.fighter1.strikesLandedPerMinute stringValue];
    cell.fighterTwoStrikesLandedPerMinute.text = [fight.fighter2.strikesLandedPerMinute isEqualToNumber:noValue] ? @"--" : [fight.fighter2.strikesLandedPerMinute stringValue];

    // strike accuracy
    cell.fighterOneStrikingAccuracy.text = [fight.fighter1.strikingAccuracy isEqualToNumber:noValue] ? @"--" : [fight.fighter1.strikingAccuracy stringValue];
    cell.fighterTwoStrikingAccuracy.text = [fight.fighter2.strikingAccuracy isEqualToNumber:noValue] ? @"--" : [fight.fighter2.strikingAccuracy stringValue];

    // strikes abs per min
    cell.fighterOneStrikesAbsorbedPerMinute.text = [fight.fighter1.strikesAbsorbedPerMinute isEqualToNumber:noValue] ? @"--" : [fight.fighter1.strikesAbsorbedPerMinute stringValue];
    cell.fighterTwoStrikesAbsorbedPerMinute.text = [fight.fighter2.strikesAbsorbedPerMinute isEqualToNumber:noValue] ? @"--" : [fight.fighter2.strikesAbsorbedPerMinute stringValue];

    // strike defense
    cell.fighterOneStrikeDefense.text = [fight.fighter1.strikingDefense isEqualToNumber:noValue] ? @"--" : [fight.fighter1.strikingDefense stringValue];
    cell.fighterTwoStrikeDefense.text = [fight.fighter2.strikingDefense isEqualToNumber:noValue] ? @"--" : [fight.fighter2.strikingDefense stringValue];

    // takedown average
    cell.fighterOneTakedownAverage.text = [fight.fighter1.takedownAverage isEqualToNumber:noValue] ? @"--" : [fight.fighter1.takedownAverage stringValue];
    cell.fighterTwoTakedownAverage.text = [fight.fighter2.takedownAverage isEqualToNumber:noValue] ? @"--" : [fight.fighter2.takedownAverage stringValue];

    // takedown accuracy
    cell.fighterOneTakedownAccuracy.text = [fight.fighter1.takedownAccuracy isEqualToNumber:noValue] ? @"--" : [fight.fighter1.takedownAccuracy stringValue];
    cell.fighterTwoTakedownAccuracy.text = [fight.fighter2.takedownAccuracy isEqualToNumber:noValue] ? @"--" : [fight.fighter2.takedownAccuracy stringValue];
    
    // takedown defense
    cell.fighterOneTakedownDefense.text = [fight.fighter1.takedownDefense isEqualToNumber:noValue] ? @"--" : [fight.fighter1.takedownDefense stringValue];
    cell.fighterTwoTakedownDefense.text = [fight.fighter2.takedownDefense isEqualToNumber:noValue] ? @"--" : [fight.fighter2.takedownDefense stringValue];

    // submission average
    cell.fighterOneSubmissionAverage.text = [fight.fighter1.submissionAverage isEqualToNumber:noValue] ? @"--" : [fight.fighter1.submissionAverage stringValue];
    cell.fighterTwoSubmissionAverage.text = [fight.fighter2.submissionAverage isEqualToNumber:noValue] ? @"--" : [fight.fighter2.submissionAverage stringValue];


    return cell;
}

#pragma mark - Table view delegate


@end
