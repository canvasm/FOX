//
//  FSPMLBGameTraxViewController.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxViewController.h"
#import "FSPSecondarySegmentedControl.h"
#import "FSPMLBGameTraxPitchCountCell.h"
#import "UIFont+FSPExtensions.h"

@interface FSPMLBGameTraxViewController ()

@end

@implementation FSPMLBGameTraxViewController

@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize playByPlayContentView, playByPlayViewController;
@synthesize bdhContentView, bdhViewController;
@synthesize battingLeftImageView, battingRightImageView;
@synthesize pitchCountTableView;
@synthesize mphLabel, liveLabel;
@synthesize hotZoneView, onDeckView, hotZoneButton;
@synthesize pitcherView, batterView, playerStatsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hotZoneView = [[FSPMLBGameTraxHotZoneView alloc] initWithFrame:hotZoneView.bounds];
        pitcherView = [[FSPMLBGameTraxPlayerView alloc] initWithFrame:pitcherView.bounds];
        batterView = [[FSPMLBGameTraxPlayerView alloc] initWithFrame:batterView.bounds];
        playerStatsView = [[FSPMLBGameTraxPlayerStatsView alloc] initWithFrame:playerStatsView.bounds];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self initializeHotZoneView];
    [self addBDHView];
    [self addPlayByPlayView];

    // Skinning
    [mphLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12]];
    [liveLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Child View Controllers

- (void)initializeHotZoneView
{

    [hotZoneView setHotValues:[NSArray arrayWithObjects:@".448", @".327", @".192", @".260", @".198", @".188", @".367", @".279", @".510", nil]];
    [hotZoneView setHotLabelsHidden:NO];
}

- (void)addBDHView
{
    bdhViewController = [[FSPMLBGameTraxBDHViewController alloc] initWithNibName:@"FSPMLBGameTraxBDHViewController" bundle:nil];

    [bdhViewController.view setFrame:bdhContentView.bounds];
    [self addChildViewController:bdhViewController];
    [bdhViewController didMoveToParentViewController:self];

    [bdhContentView addSubview:bdhViewController.view];
}

- (void)addPlayByPlayView
{
    // Add the Play By Play view controller
    playByPlayViewController = [[FSPMLBPlayByPlayViewController alloc] init];

    if (playByPlayViewController.isViewLoaded && playByPlayViewController.view.superview) {
        [playByPlayViewController willMoveToParentViewController:nil];
        [playByPlayViewController.view removeFromSuperview];
        [playByPlayViewController removeFromParentViewController];
    }

    if (![playByPlayViewController conformsToProtocol:@protocol(FSPExtendedEventDetailManaging)]) {
        [NSException raise:@"Does not conform to protocol" format:@"%@ must conform to the FSPExtendedEventDetailManaging protocol", playByPlayViewController];
    }
    playByPlayViewController.managedObjectContext = self.managedObjectContext;

    [playByPlayViewController.view setFrame:playByPlayContentView.bounds];
    if ([playByPlayViewController respondsToSelector:@selector(segmentedControl)]) {
        FSPSegmentedControl *segmentedControl = [playByPlayViewController segmentedControl];
        if ([segmentedControl isKindOfClass:[FSPSecondarySegmentedControl class]] && [playByPlayViewController respondsToSelector:@selector(segmentTitlesForEvent:)]) {
            [segmentedControl removeAllSegments];
            NSArray *segments = [playByPlayViewController segmentTitlesForEvent:self.currentEvent];
            for (NSUInteger i = 0; i < [segments count]; i++) {
                [segmentedControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i animated:NO];
            }
            segmentedControl.selectedSegmentIndex = 0;
        } else {
            segmentedControl.selectedSegmentIndex = -1;
        }
    }

    [self addChildViewController:playByPlayViewController];
    [playByPlayViewController didMoveToParentViewController:self];
    [self.playByPlayContentView addSubview:playByPlayViewController.view];
    playByPlayViewController.currentEvent = self.currentEvent;
    [playByPlayViewController.view setNeedsLayout];

    // Update the event and moc for the view controllers
    if (![playByPlayViewController conformsToProtocol:@protocol(FSPExtendedEventDetailManaging)]) {
        [NSException raise:@"Does not conform to protocol" format:@"%@ must conform to the FSPEventDetailLoading protocol", playByPlayViewController];
    }
}

#pragma mark - Pitch Count Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 26;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PitchCountTableCell";

    FSPMLBGameTraxPitchCountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[FSPMLBGameTraxPitchCountCell alloc] init];
        
    }

    return cell;
}

#pragma mark - Interaction

- (IBAction)hotZoneButtonPressed:(id)sender
{
    if (hotZoneView.hidden) {
        [hotZoneView setHidden:NO];
        [onDeckView setHidden:YES];
        [hotZoneView setHotLabelsHidden:YES];
    } else {
        if (hotZoneView.hotLabel1.hidden) {
            [hotZoneView setHidden:NO];
            [onDeckView setHidden:YES];
            [hotZoneView setHotLabelsHidden:NO];
        } else {
            [hotZoneView setHidden:YES];
            [onDeckView setHidden:NO];
            [hotZoneView setHotLabelsHidden:YES];
        }
    }
}

@end
