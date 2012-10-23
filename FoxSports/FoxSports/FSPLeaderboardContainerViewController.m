//
//  FSPLeaderboardContainerViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLeaderboardContainerViewController.h"
#import "FSPSecondarySegmentedControl.h"
#import "FSPEvent.h"
#import "FSPNASCARLeaderboardQualifyingViewController.h"
#import "FSPNASCARLeaderboardResultsViewController.h"

typedef enum {
    SegmentIndexQualifying = 0,
    SegmentIndexResults
} SegmentIndex;

@interface FSPLeaderboardContainerViewController ()


@property (strong, nonatomic) FSPNASCARLeaderboardQualifyingViewController *qualifyingViewController;
@property (strong, nonatomic) FSPNASCARLeaderboardResultsViewController *resultsViewController;
@property (strong, nonatomic) NSArray *containedViewControllers;

@end

@implementation FSPLeaderboardContainerViewController

- (id)initWithEvent:(FSPEvent *)event
{
    self = [super init];
    if (self) {
        _currentEvent = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect contentFrame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		contentFrame = CGRectMake(0.0, CGRectGetMaxY(self.segmentedControl.frame), self.view.frame.size.width, self.view.bounds.size.height - self.segmentedControl.frame.size.height);
	} else {
		contentFrame = self.view.bounds;
	}
    
	self.qualifyingViewController = [[FSPNASCARLeaderboardQualifyingViewController alloc]initWithEvent:(FSPEvent *)self.currentEvent];
    self.qualifyingViewController.view.frame = contentFrame;
    [self addChildViewController:self.qualifyingViewController];
    [self.view addSubview:self.qualifyingViewController.view];

    self.resultsViewController = [[FSPNASCARLeaderboardResultsViewController alloc] initWithEvent:(FSPEvent *)self.currentEvent];
    self.resultsViewController.view.frame = contentFrame;
    [self addChildViewController:self.resultsViewController];
    
    self.containedViewControllers = [NSArray arrayWithObjects:self.resultsViewController, self.qualifyingViewController, nil];
}

- (void)viewDidUnload
{
    self.segmentedControl = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.segmentedControl.selectedSegmentIndex = 0;
        [self selectDetailViewAtIndex:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
    
- (void)reloadTableviewsWithEvent:(FSPEvent *)event
{
    self.currentEvent = event;
    for (FSPLeaderboardViewController *viewController in self.containedViewControllers) {
        viewController.currentEvent = self.currentEvent;
        [viewController fetchData];
    }
    [self selectDetailViewAtIndex:SegmentIndexQualifying];
}

#pragma mark - Segmented Control

- (IBAction)segmentedControlUpdate:(FSPSecondarySegmentedControl *)sender
{
    // For tabbing in iPad
	[self selectDetailViewAtIndex:sender.selectedSegmentIndex];
}

#pragma mark - FSPExtendedEventDetailManaging

- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event
{
    return @[@"Qualifying Speeds", @"Running Order"];
}

- (void)selectGameDetailViewAtIndex:(NSUInteger)index
{
    // For tabbing in iPhone
    [self selectDetailViewAtIndex:index];
}

- (void)selectDetailViewAtIndex:(NSUInteger)index
{
    switch (index) {
        case SegmentIndexQualifying:
            [self.view addSubview:self.qualifyingViewController.view];
            [self.resultsViewController.view removeFromSuperview];
            break;
        case SegmentIndexResults:
            [self.view addSubview:self.resultsViewController.view];
            [self.qualifyingViewController.view removeFromSuperview];
            break;
        default:
            break;
    }
}

@end
