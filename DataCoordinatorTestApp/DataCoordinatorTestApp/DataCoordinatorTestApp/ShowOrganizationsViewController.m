//
//  ShowOrganizationsViewController.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "ShowOrganizationsViewController.h"
#import "FSPOrganization.h"
#import "FSPCoreDataManager.h"

@implementation ShowOrganizationsViewController
@synthesize organizations = _organizations;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return [self.organizations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NoChildCellIdentifier = @"NoChild";
    static NSString *HasChildCellIdentifier = @"HasChild";
    
    FSPOrganization *organization = [self.organizations objectAtIndex:indexPath.row];
    NSString *identifier;
    if (organization.children.count > 0) {
        identifier = HasChildCellIdentifier;
    } else {
        identifier = NoChildCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = organization.name;
    cell.imageView.image = [UIImage imageWithData:organization.smallLogo];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([segue.identifier isEqualToString:@"ShowChildOrgSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        FSPOrganization *selectedOrg = [self.organizations objectAtIndex:indexPath.row];
        ((ShowOrganizationsViewController *)segue.destinationViewController).organizations = [selectedOrg.children allObjects];
    }
}

@end
