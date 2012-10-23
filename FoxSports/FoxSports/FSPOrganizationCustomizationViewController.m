//
//  FSPOrganizationCustomizationViewController.m
//  FoxSports
//
//  Created by Chase Latta on 5/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationCustomizationViewController.h"
#import "FSPOrganization.h"
#import "FSPTeam.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPCoreDataManager.h"

#define kCellOrgLabelOrginX 44.0
#define kCellOrgLabelOrginY 10.0

@interface FSPOrganizationCustomizationViewController ()
@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *orderedChildren;

- (void)addTeamsButtonWasPressed:(id)sender;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withExtraControls:(FSPOrganization *)org;
@end

@implementation FSPOrganizationCustomizationViewController {
    BOOL isShowingTeams;
}
@synthesize organization;
@synthesize managedObjectContext;
@synthesize orderedChildren = _orderedChildren;

- (NSArray *)orderedChildren;
{
    if (!_orderedChildren) {
        NSString *keyToSortOn;
        NSSet *setToSort;
        if (isShowingTeams) {   
            keyToSortOn = @"name";
            setToSort = self.organization.teams;
            // Don't display "eventOnly" teams
            NSMutableSet *tempset = [NSMutableSet set];
            [setToSort enumerateObjectsUsingBlock:^(FSPTeam *team, BOOL *stop) {
                if (!team.isEventOnly.boolValue) {
                    [tempset addObject:team];
                }
            }];
            setToSort = tempset;
        } else {
            keyToSortOn = @"ordinal";
            setToSort = self.organization.children;
            for (FSPOrganization *org in setToSort) {
                for (FSPOrganizationHierarchyInfo *info in org.currentHierarchyInfo)
                    if (info.parentOrg == self.organization && info.currentOrg == org)
                        org.ordinal = info.ordinal;
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customizable == YES OR selectable == YES"];
        setToSort = [setToSort filteredSetUsingPredicate:predicate];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:keyToSortOn ascending:YES];
        _orderedChildren = [setToSort sortedArrayUsingDescriptors:@[sort]];
    }
    return _orderedChildren;
}

- (id)initWithOrganization:(FSPOrganization *)org;
{
    return [self initWithOrganization:org isShowingTeams:NO];
}

- (id)initWithOrganization:(FSPOrganization *)org isShowingTeams:(BOOL)yesNo;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        isShowingTeams = yesNo;
        self.organization = org;
        self.managedObjectContext = org.managedObjectContext;
        self.title = [org.name uppercaseString];
		[self updateContentSize];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                        target:self
                                                                                        action:@selector(doneAddingOrganizations)];
            self.navigationItem.rightBarButtonItem = doneButton;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.orderedChildren = nil;
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

- (void)updateContentSize;
{
	// a bit of a hack to get the popover to resize correctly
	CGSize size = CGSizeMake(320.0, [self tableView:self.tableView numberOfRowsInSection:0] * self.tableView.rowHeight);
	if (self.tableView.style == UITableViewStyleGrouped) {
		size.height += 20;
	}
    self.contentSizeForViewInPopover = CGSizeMake(size.width, size.height - 1.0f);
	self.contentSizeForViewInPopover = size;
}

- (void)doneAddingOrganizations {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderedChildren count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // https://ubermind.jira.com/browse/FSTOGOIOS-1749
        // The checked and unchecked images are different sizes, so when they are changed the cell's text moves
        // horizontally.  Replace the cell's text with a label that won't move.
        UILabel *orgLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 10, 240, cell.frame.size.height - 20)];
        orgLabel.backgroundColor = [UIColor clearColor];
        orgLabel.shadowColor = [UIColor clearColor];
        orgLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        orgLabel.tag = 1;
        [cell.contentView addSubview:orgLabel];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Cell Configuration
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    FSPOrganization *org = [self.orderedChildren objectAtIndex:indexPath.row];
    NSString *organizationName;
    if ([org isKindOfClass:[FSPTeam class]]) {
        organizationName = [(FSPTeam *)org longNameDisplayString];
    }
    else
        organizationName = org.name;
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = organizationName;
    label.shadowColor = [UIColor clearColor];
    
    if ([org.selectable boolValue]) {
        if ([org.favorited boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"checkmark_green"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"empty_circle"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.imageView.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    if (isShowingTeams) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self configureCell:cell atIndexPath:indexPath withExtraControls:org];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withExtraControls:(FSPOrganization *)org;
{
    BOOL hasTeams = [org.hasTeams boolValue];
    BOOL hasChildren = [org.children count] > 0;
    
    UIView *orgLabel = [cell viewWithTag:1];
    CGFloat orgLabelWidth = 220.0;
    orgLabel.frame = CGRectMake(kCellOrgLabelOrginX,kCellOrgLabelOrginY, orgLabelWidth, orgLabel.frame.size.height);
    
    if (hasTeams || hasChildren) {
        // Show a disclosure
        UITableViewCellAccessoryType accessory;
        if (hasTeams) {
            accessory = UITableViewCellAccessoryNone;
            UIButton *addTeamButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [addTeamButton setBackgroundImage:[UIImage imageNamed:@"add_team_button"] forState:UIControlStateNormal];
            [addTeamButton sizeToFit];
            [addTeamButton addTarget:self action:@selector(addTeamsButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];

            // Set the tag on the view so that we can get the row back when this is tapped.  We need to do this because the delegate
            // method tableView:accessoryButtonTappedForRowWithIndexPath: does not get called when using accessoryView.
            addTeamButton.tag = indexPath.row;
            cell.accessoryView = addTeamButton;
            
            orgLabelWidth = 160.0;
            orgLabel.frame = CGRectMake(kCellOrgLabelOrginX, kCellOrgLabelOrginY, orgLabelWidth, orgLabel.frame.size.height);
        } else {
            accessory = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }
        cell.accessoryType = accessory;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPOrganization *org = [self.orderedChildren objectAtIndex:indexPath.row];
    if ([org.selectable boolValue]) {
        BOOL isFavorited = [org.favorited boolValue];
        [org updateFavoriteState:!isFavorited];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView reloadData];

        [[FSPCoreDataManager sharedManager] synchronizeSaving];
    } else if ([org.children count] > 0) {
        FSPOrganizationCustomizationViewController *vc = [[FSPOrganizationCustomizationViewController alloc] initWithOrganization:org isShowingTeams:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addTeamsButtonWasPressed:(UIButton *)sender;
{
    // This means that we want to push a teams view controller
    FSPOrganization *org = [self.orderedChildren objectAtIndex:sender.tag];
    FSPOrganizationCustomizationViewController *vc = [[FSPOrganizationCustomizationViewController alloc] initWithOrganization:org isShowingTeams:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
