//
//  FSPUFCFightTraxViewController.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-05.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFightTraxViewController.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPUFCPlayer.h"
#import "FSPUFCEvent.h"
#import "FSPUFCFight.h"
#import "FSPDataCoordinator.h"
#import "FSPUFCFightersAndRoundInfoView.h"

@interface FSPUFCFightTraxViewController ()

@property (nonatomic, weak) FSPUFCEvent *ufcEvent;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@property (nonatomic, strong) UIPopoverController *fighterOneProfilePopover;
@property (nonatomic, strong) UIPopoverController *fighterTwoProfilePopover;

@property (nonatomic, strong) FSPUFCFightersAndRoundInfoView *headerView;

@end

@implementation FSPUFCFightTraxViewController

@synthesize currentEvent = _currentEvent;
@synthesize ufcEvent;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize fighterOneProfilePopover;
@synthesize fighterTwoProfilePopover;
@synthesize fightDetailsView;
@synthesize headerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //main view
    [self setupFightDetailView];
    [self setupHeaderView];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
}

- (void)setupHeaderView
{
    if (!headerView)
        headerView = [[FSPUFCFightersAndRoundInfoView alloc] initWithFrame:CGRectMake(0, 0, 650, 200)];
    
    [headerView.viewFighterOneProfileButton addTarget:self action:@selector(fighterOneProfileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.viewFighterTwoProfileButton addTarget:self action:@selector(fighterTwoProfileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:headerView];
}

- (void)setupFightDetailView
{
    if (!fightDetailsView)
        fightDetailsView = [[FSPUFCFightDetailsView alloc] init];
    
    [self.view addSubview:fightDetailsView];
    
    fightDetailsView.frame = CGRectMake(
                                     0,
                                     150,
                                     650,
                                     431);//size numbers dont update view for some reason
}
- (void)fighterOneProfileButtonClicked:(UIButton *)sender
{
    if (!self.fighterOneProfilePopover) //create popover if it isnt created yet
    {
        FSPUFCFighterProfilePopoverView *controller = [[FSPUFCFighterProfilePopoverView alloc] initWithNibName:@"FSPUFCFighterProfilePopoverView" bundle:nil];
        self.fighterOneProfilePopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.fighterOneProfilePopover.delegate = self;
    }
    
    //allow other views to be clicked so we can have both open at once
    self.fighterOneProfilePopover.passthroughViews = [[NSArray alloc] initWithObjects:self.headerView.viewFighterOneProfileButton, self.headerView.viewFighterTwoProfileButton, self.fighterTwoProfilePopover.contentViewController.view, nil];
    
    if (self.fighterOneProfilePopover.isPopoverVisible == NO)
    {
        FSPUFCFighterProfilePopoverView *popoverProfileView = (FSPUFCFighterProfilePopoverView *)self.fighterOneProfilePopover.contentViewController;
        
        [popoverProfileView setFighterInfo:self.headerView.fighter1];
        
        //TODO Causes crash "unrecognized selector sent to instance"
        //[self.fighterProfilePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //FIXED
        [self.fighterOneProfilePopover presentPopoverFromRect:[sender bounds]
                                                    inView:sender
                                  permittedArrowDirections:UIPopoverArrowDirectionUp
                                                  animated:YES];
    }
    else //dismiss it
    {
        [self.fighterOneProfilePopover dismissPopoverAnimated:YES];
    }
}

- (void)fighterTwoProfileButtonClicked:(UIButton *)sender
{
    if (!self.fighterTwoProfilePopover) //create popover if it isnt created yet
    {
        FSPUFCFighterProfilePopoverView *controller = [[FSPUFCFighterProfilePopoverView alloc] initWithNibName:@"FSPUFCFighterProfilePopoverView" bundle:nil];
        self.fighterTwoProfilePopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.fighterTwoProfilePopover.delegate = self;
    }
    
    //allow other views to be clicked so we can have both open at once
    self.fighterTwoProfilePopover.passthroughViews = [[NSArray alloc] initWithObjects:self.headerView.viewFighterOneProfileButton, self.headerView.viewFighterTwoProfileButton, self.fighterOneProfilePopover.contentViewController.view, nil];
    
    if (self.fighterTwoProfilePopover.isPopoverVisible == NO)
    {
        FSPUFCFighterProfilePopoverView *popoverProfileView = (FSPUFCFighterProfilePopoverView *)self.fighterTwoProfilePopover.contentViewController;
        
        [popoverProfileView setFighterInfo:self.headerView.fighter2];
        
        //TODO Causes crash "unrecognized selector sent to instance"
        //[self.fighterProfilePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //FIXED
        [self.fighterTwoProfilePopover presentPopoverFromRect:[sender bounds]
                                                       inView:sender
                                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                                     animated:YES];
    }
    else //dismiss it
    {
        [self.fighterTwoProfilePopover dismissPopoverAnimated:YES];
    }
}


//override for UIPopovers
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.fighterOneProfilePopover)
        [self.fighterTwoProfilePopover dismissPopoverAnimated:YES];
    else if (popoverController == self.fighterTwoProfilePopover)
        [self.fighterOneProfilePopover dismissPopoverAnimated:YES];
    
    return YES;
}

- (FSPUFCEvent *)ufcEvent;
{
    return (FSPUFCEvent *)self.currentEvent;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent && ([currentEvent isKindOfClass:[FSPUFCEvent class]]))
    {
        _currentEvent = currentEvent;
        [self.dataCoordinator updateMatchupForUFCEvent:currentEvent.objectID];
        
        FSPUFCFight *lastFightInSet;
        
        //get the last fight in the set
        for (NSUInteger counter = 0; counter < self.ufcEvent.fights.count; ++counter)
        {
            lastFightInSet = (FSPUFCFight *)[self.ufcEvent.fights.allObjects objectAtIndex:counter];
           // NSLog(@"NSUInteger: %d%@%@", counter, fi.fighter1.firstName, fi.fighter1.lastName);
        }
        
        if (lastFightInSet)
            [self updateCurrentFighterProfiles:lastFightInSet];
    }
}

- (void)updateCurrentFighterProfiles:(FSPUFCFight *)fight
{
    if (fight)
        [self.headerView setFightersInfo:fight.fighter1 :fight.fighter2];
    else
        NSLog(@"Error Fight is nil");
}

- (void)eventDidUpdate;
{
    NSLog(@"UFC Event Did Update");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end