//
//  FSPConferencesModalViewController.m
//  FoxSports
//
//  Created by greay on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConferencesModalViewController.h"
#import "FSPOrganization.h"

@implementation FSPConferencesModalViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrganizationsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	[self populateCell:cell atIndexPath:indexPath withOrganization:[self.organizations objectAtIndex:[indexPath row]]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the schedule conference
    FSPOrganization *selectedConference = [self.organizations objectAtIndex:[indexPath row]];
	if (selectedConference.children.count > 0) {
		FSPConferencesModalViewController *drillDownViewController = [[FSPConferencesModalViewController alloc] initWithOrganizations:selectedConference.children
																													includeTournamets:self.includeTournaments
																																style:UITableViewStyleGrouped
																										   selectionCompletionHandler:self.selectionChangedBlock];
		drillDownViewController.title = selectedConference.name;
		drillDownViewController.selectedConference = self.selectedConference;
		[self.navigationController pushViewController:drillDownViewController animated:YES];
	} else {
		self.selectedConference = selectedConference;
		[tableView reloadData];
		self.selectionChangedBlock(selectedConference);
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)addTeamsButtonWasPressed:(UIButton *)sender;
{
    // This means that we want to push a teams view controller
    FSPOrganization *selectedConference = [self.organizations objectAtIndex:sender.tag];
    FSPConferencesModalViewController *vc = [[FSPConferencesModalViewController alloc] initWithOrganizations:selectedConference.teams
																						   includeTournamets:self.includeTournaments
																									   style:UITableViewStyleGrouped
																				  selectionCompletionHandler:self.selectionChangedBlock];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
