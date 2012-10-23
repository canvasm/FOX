//
//  FSPConferenceSelectorTableViewController.m
//  FoxSports
//
//  Created by Stephen Spring on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConferenceSelectorViewController.h"
#import "FSPOrganization.h"
#import "FSPOrganizationHierarchyInfo.h"

@interface FSPConferenceSelectorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy, readwrite) SelectionChangedBlock selectionChangedBlock;
@property (nonatomic, strong, readwrite) NSArray *organizations;

@end

@implementation FSPConferenceSelectorViewController


- (id)initWithOrganizations:(NSSet *)organizations includeTournamets:(BOOL)includeTournaments style:(UITableViewStyle)style selectionCompletionHandler:(void(^)(FSPOrganization *organization))selectionCompletion
{
    self = [super initWithStyle:style];
    if (self) {
		_includeTournaments = includeTournaments;
        NSPredicate *predicate;
		if (includeTournaments) {
			predicate = [NSPredicate predicateWithFormat:@"customizable == YES OR selectable == YES"];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"(customizable == YES OR selectable == YES) AND type != %@", FSPOrganizationTournamentType];
		}
        NSMutableSet *setToSort = [[organizations filteredSetUsingPredicate:predicate] mutableCopy];
		
		NSMutableSet *setToRemove = [NSMutableSet set];
		for (FSPOrganization *org in setToSort) {
			if ([org.children count] > 0) {
				if ([[org.children filteredSetUsingPredicate:predicate] count] == 0) {
					[setToRemove addObject:org];
				}
			}
		}
		[setToSort minusSet:setToRemove];
		
        for (FSPOrganization *org in setToSort) {
            for (FSPOrganizationHierarchyInfo *info in org.currentHierarchyInfo) {
                if (info.currentOrg == org)
                    org.ordinal = info.ordinal;
			}
        }
        NSSortDescriptor *sortOrdinal = [NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES];
        NSSortDescriptor *sortName = [NSSortDescriptor sortDescriptorWithKey:@"longNameDisplayString" ascending:YES];

        _organizations = [setToSort sortedArrayUsingDescriptors:@[sortOrdinal, sortName]];
        _selectionChangedBlock = selectionCompletion;
		[self updateContentSize];
    }
    return self;
}

- (void)updateContentSize
{
	// a bit of a hack to get the popover to resize correctly
	CGSize size = CGSizeMake(320.0, [self tableView:self.tableView numberOfRowsInSection:0] * self.tableView.rowHeight);
	if (self.tableView.style == UITableViewStyleGrouped) {
		size.height += 20;
	}
    self.contentSizeForViewInPopover = CGSizeMake(size.width, size.height - 1.0f);
	self.contentSizeForViewInPopover = size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateContentSize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (void)populateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withOrganization:(FSPOrganization *)organization
{
    cell.textLabel.text = organization.longNameDisplayString;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    BOOL hasTeams = [organization.hasTeams boolValue];
    BOOL hasChildren = [organization.children count] > 0;
    
	if (self.includeTeams) {
		if (hasTeams || hasChildren) {
			// Show a disclosure
			UITableViewCellAccessoryType accessory;
			if (hasTeams) {
				accessory = UITableViewCellAccessoryNone;
				UIButton *addTeamButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[addTeamButton setBackgroundImage:[UIImage imageNamed:@"view_team_button"] forState:UIControlStateNormal];
				[addTeamButton sizeToFit];
				[addTeamButton addTarget:self action:@selector(addTeamsButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
				
				// Set the tag on the view so that we can get the row back when this is tapped.  We need to do this because the delegate
				// method tableView:accessoryButtonTappedForRowWithIndexPath: does not get called when using accessoryView.
				addTeamButton.tag = indexPath.row;
				cell.accessoryView = addTeamButton;
			} else {
				accessory = UITableViewCellAccessoryDisclosureIndicator;
				cell.accessoryView = nil;
			}
			cell.accessoryType = accessory;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = nil;
		}
	} else {
		if ([[organization objectID] isEqual:[self.selectedConference objectID]]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else if (hasChildren) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}


@end
