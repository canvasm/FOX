//
//  ListAllOrgsViewController.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "ListAllOrgsViewController.h"
#import "FSPOrganization.h"
#import "FSPCoreDataManager.h"
#import "ShowScheduleViewController.h"
#import "FSPOrganizationSchedule.h"

@implementation ListAllOrgsViewController {
    NSArray *allOrgs;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
    allOrgs = [[[FSPCoreDataManager sharedManager] GUIObjectContext] executeFetchRequest:fetch error:nil];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allOrgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    FSPOrganization *org = [allOrgs objectAtIndex:indexPath.row];
    cell.textLabel.text = org.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"schedule last update %@", org.schedule.updatedDate];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([segue.identifier isEqualToString:@"ShowScheduleSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        if (indexPath.row < [allOrgs count]) {
            FSPOrganization *org = [allOrgs objectAtIndex:indexPath.row];
            ((ShowScheduleViewController *)segue.destinationViewController).organization = org;
        }
    }
}

@end
