//
//  FSPTournamentPreTournamentViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTournamentPreTournamentViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPEvent.h"


@interface FSPTournamentPreTournamentViewController ()

@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@end

@implementation FSPTournamentPreTournamentViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
        [self.dataCoordinator updateMatchupForUFCEvent:currentEvent.objectID];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
