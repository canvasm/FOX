//
//  FSPConferencesOverlayViewController.m
//  FoxSports
//
//  Created by greay on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConferencesOverlayViewController.h"
#import "FSPOrganization.h"
#import "FSPConferencesModalViewController.h"
#import "FSPRootViewController.h"
#import "FSPConferencesOverlayCell.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPConferencesOverlayViewController ()
@property (nonatomic, strong) NSMutableArray *rows;
@end

@implementation FSPConferencesOverlayViewController

- (id)initWithOrganizations:(NSSet *)organizations includeTournamets:(BOOL)includeTournaments style:(UITableViewStyle)style selectionCompletionHandler:(void (^)(FSPOrganization *))selectionCompletion
{
	self = [super initWithOrganizations:organizations includeTournamets:includeTournaments style:style selectionCompletionHandler:selectionCompletion];
	if (self) {
		self.rows = [NSMutableArray array];
		NSUInteger i = 0;
		while (i < self.organizations.count) {
			NSMutableArray *row = [NSMutableArray array];
			[self.rows addObject:row];
			FSPOrganization *org = [self.organizations objectAtIndex:i];
			[row addObject:org];
			i++;
			if (org.children.count == 0 && i < self.organizations.count) {
				org = [self.organizations objectAtIndex:i];
				if (org.children.count == 0) {
					[row addObject:org];
					i++;
				}
			}
		}
		
		[self updateContentSize];
		if ([self contentSizeForViewInPopover].height > self.tableView.bounds.size.height) {
			self.tableView.scrollEnabled = YES;
		} else {
			self.tableView.scrollEnabled = NO;
		}
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.rows.count;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.rowHeight = 38.0;
    self.tableView.backgroundColor = [UIColor colorWithRed:9/255.0f green:33/255.0f blue:73/255.0f alpha:1.000];
    self.tableView.accessibilityIdentifier = @"dropDownMenu";
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = [UIColor colorWithRed:0.0 green:16/255.0f blue:35/255.0f alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrganizationsCell";
    FSPConferencesOverlayCell *cell = (FSPConferencesOverlayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[FSPConferencesOverlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.delegate = self;
    }
	NSArray *row = [self.rows objectAtIndex:[indexPath row]];
	[cell populateWithConferences:row selected:[self.selectedConference objectID]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didSelectConference:(FSPOrganization *)selectedConference
{
	if (selectedConference.children.count > 0) {
		FSPConferencesModalViewController *drillDownViewController = [[FSPConferencesModalViewController alloc] initWithOrganizations:selectedConference.children
																													includeTournamets:self.includeTournaments
																																style:UITableViewStyleGrouped
																										   selectionCompletionHandler:self.selectionChangedBlock];
		drillDownViewController.title = selectedConference.name;
		drillDownViewController.selectedConference = self.selectedConference;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:drillDownViewController];
		navController.navigationBar.barStyle = UIBarStyleBlack;
		UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self.overlayPresentingViewController action:@selector(dismissModalViewControllerAnimated:)];
		drillDownViewController.navigationItem.rightBarButtonItem = backItem;
		[self.overlayPresentingViewController presentModalViewController:navController animated:YES];
	} else {
		self.selectedConference = selectedConference;
		[self.tableView reloadData];
		self.selectionChangedBlock(selectedConference);
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the schedule conference
    FSPOrganization *selectedConference = [self.organizations objectAtIndex:[indexPath row]];
	[self didSelectConference:selectedConference];
}

- (void)cell:(FSPConferencesOverlayCell *)cell didSelectConference:(FSPOrganization *)selectedConference
{
	[self didSelectConference:selectedConference];
}

@end
