//
//  FSPTennisRoundTableViewController.m
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisRoundTableViewController.h"
#import "FSPTennisResultsCell.h"

#import "FSPTennisEvent.h"
#import "FSPTennisMatch.h"
#import "FSPTennisPlayer.h"

static NSString * FSPTennisResultsCellIdentifier = @"FSPTennisResultsCell";

@interface FSPTennisRoundTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation FSPTennisRoundTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		self.round = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView registerNib:[UINib nibWithNibName:@"FSPTennisResultsCell" bundle:nil] forCellReuseIdentifier:FSPTennisResultsCellIdentifier];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)setRound:(NSInteger)round
{
	_round = round;
	if (self.currentEvent && round >= 0) {
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTennisMatch"];
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"round.event.uniqueIdentifier == %@ && round.ordinal == %d", self.currentEvent.uniqueIdentifier, round];
		fetchRequest.shouldRefreshRefetchedObjects = YES;

		NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
		fetchRequest.sortDescriptors = @[sortDescriptorPeriod];
		
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		self.fetchedResultsController.delegate = self;
		
		NSError *error = nil;
		if (![self.fetchedResultsController performFetch:&error]) {
			NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
			self.fetchedResultsController = nil;
		}
	} else {
		self.fetchedResultsController = nil;
	}
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}

#pragma mark - Table view delegate / data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSInteger rows = (NSInteger)[sectionInfo numberOfObjects];
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPTennisResultsCell *cell = (FSPTennisResultsCell *)[tableView dequeueReusableCellWithIdentifier:FSPTennisResultsCellIdentifier];
	
    // Configure the cell...
	FSPTennisMatch *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell populateWithMatch:match];
    return cell;
}

@end
