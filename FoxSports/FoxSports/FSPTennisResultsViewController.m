//
//  FSPTennisResultsViewController.m
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisResultsViewController.h"
#import "FSPTennisRoundTableViewController.h"
#import "FSPTennisEvent.h"
#import "FSPGameDetailSectionHeader.h"
@interface FSPTennisResultsViewController ()

@property (nonatomic, assign) IBOutlet FSPGameDetailSectionHeader *header;
@property (nonatomic, assign) IBOutlet UIButton *previousRoundButton;
@property (nonatomic, assign) IBOutlet UIButton *nextRoundButton;

@property (nonatomic, strong)  FSPTennisRoundTableViewController *resultsTableViewController;
@property (nonatomic, assign) IBOutlet UIView *containerView;

- (IBAction)previousRound:(id)sender;
- (IBAction)nextRound:(id)sender;

@end

@implementation FSPTennisResultsViewController

- (id)initWithEvent:(FSPEvent *)event
{
    self = [super init];
    if (self) {
        _currentEvent = event;
    }
    return self;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
	_currentEvent = currentEvent;
	self.resultsTableViewController.currentEvent = self.currentEvent;
	self.resultsTableViewController.round = 0;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.resultsTableViewController = [[FSPTennisRoundTableViewController alloc] initWithStyle:UITableViewStylePlain];
	self.resultsTableViewController.managedObjectContext = self.currentEvent.managedObjectContext;
	self.resultsTableViewController.currentEvent = self.currentEvent;
	self.resultsTableViewController.round = 0;

	self.header.titleLabel.textAlignment = UITextAlignmentCenter;
	
	self.resultsTableViewController.tableView.frame = self.containerView.bounds;
	[self.containerView addSubview:self.resultsTableViewController.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self viewRound:0];
}

- (void)viewRound:(NSInteger)round
{
	self.resultsTableViewController.round = round;
	self.header.titleLabel.text = [NSString stringWithFormat:@"Round %d", round + 1];
}

- (IBAction)previousRound:(id)sender {
	if (self.resultsTableViewController.round > 0) {
		[self viewRound:self.resultsTableViewController.round - 1];
	}
}

- (IBAction)nextRound:(id)sender {
	if ((NSUInteger)self.resultsTableViewController.round < [(FSPTennisEvent *)self.currentEvent rounds].count - 1) {
		[self viewRound:self.resultsTableViewController.round + 1];
	}
}


@end
