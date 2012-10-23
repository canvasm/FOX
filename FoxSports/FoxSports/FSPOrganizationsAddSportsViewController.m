//
//  FSPOrganizationsAddSportsViewController.m
//  FoxSports
//
//  Created by Ed McKenzie on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationsAddSportsViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPOrganization.h"
#import "FSPOrganizationsAddSportsTableCellCheckmarkView.h"
#import "FSPOrganizationsAddSportsViewControllerCell.h"

#import "FSPOrganizationCustomizationViewController.h"

@interface FSPOrganizationsAddSportsViewController ()

- (void)doneAddingOrganizations;
- (void)showOrganizationTeams:(id)sender;
- (void)toggleFavoriteOrganization:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *parentOrganizationID;

@end

static NSString *FSPOrganizationsAddSportsViewControllerCellIdentifier = @"FSPOrganizationsAddSportsViewControllerCell";

@implementation FSPOrganizationsAddSportsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize parentOrganizationID = _parentOrganizationID;
@dynamic managedObjectContext;

#pragma mark - UIViewController implementation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Add Sports";
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneAddingOrganizations)];
        self.navigationItem.rightBarButtonItem = doneButton;
        _parentOrganizationID = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parentOrganizationID:(NSManagedObjectID *)parentOrganizationID {
    NSParameterAssert(parentOrganizationID);
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _parentOrganizationID = parentOrganizationID;
        FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:_parentOrganizationID error:nil];
        if ([organization isKindOfClass:FSPOrganization.class]) {
            self.navigationItem.title = organization.name;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)doneAddingOrganizations {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate/data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (NSInteger)self.fetchedResultsController.fetchedObjects.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.fetchedResultsController.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPOrganizationsAddSportsViewControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:FSPOrganizationsAddSportsViewControllerCellIdentifier];
    if (!cell) {
        NSArray *objects = [[UINib nibWithNibName:NSStringFromClass(FSPOrganizationsAddSportsViewControllerCell.class)
                                           bundle:nil] instantiateWithOwner:self options:nil];
        cell = [objects objectAtIndex:0];
		[cell.addTeamButton addTarget:self action:@selector(showOrganizationTeams:)
					 forControlEvents:UIControlEventTouchUpInside];
		[cell.checkmarkView addTarget:self action:@selector(toggleFavoriteOrganization:)
					 forControlEvents:UIControlEventTouchUpInside];
    }

    FSPOrganization *organization = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    cell.label.text = organization.name;
    if (organization.teams.count) {
        cell.addTeamButton.hidden = NO;
		[cell setDisclosureText:@"Add Team"];
    } else {
        cell.addTeamButton.hidden = YES;
    }
	
	if (organization.children.count) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if ([organization.customizable boolValue] && [organization.selectable boolValue]) {
		cell.checkmarkView.hidden = NO;
		cell.checkmarkView.selected = organization.favorited.boolValue;
		cell.indexPath = indexPath;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		cell.checkmarkView.hidden = YES;
	}
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPOrganization *organization = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
	if (organization.children.count) {
		FSPOrganizationCustomizationViewController *childVC = [[FSPOrganizationCustomizationViewController alloc] initWithOrganization:organization isShowingTeams:NO];
		[self.navigationController pushViewController:childVC animated:YES];
	} else {
		FSPOrganizationsAddSportsViewControllerCell *cell;
		cell = (FSPOrganizationsAddSportsViewControllerCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		[self toggleFavoriteOrganization:cell.checkmarkView];
		[tableView reloadData];
	}
}

#pragma mark - control actions

- (void)showOrganizationTeams:(UIButton *)sender {
    FSPOrganizationsAddSportsViewControllerCell *cell = (FSPOrganizationsAddSportsViewControllerCell *)sender.superview.superview;
    NSIndexPath *indexPath = cell.indexPath;

    FSPOrganization *organization = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
	BOOL showTeams = (organization.teams.count);
	FSPOrganizationCustomizationViewController *childVC = [[FSPOrganizationCustomizationViewController alloc] initWithOrganization:organization isShowingTeams:showTeams];
    [self.navigationController pushViewController:childVC animated:YES];
}

- (void)toggleFavoriteOrganization:(id)sender {
    FSPOrganizationsAddSportsTableCellCheckmarkView *checkmarkView = (FSPOrganizationsAddSportsTableCellCheckmarkView *)sender;
    FSPOrganizationsAddSportsViewControllerCell *cell = (FSPOrganizationsAddSportsViewControllerCell *)checkmarkView.superview.superview;
    NSIndexPath *indexPath = cell.indexPath;
    FSPOrganization *organization = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [organization updateFavoriteState:!organization.favorited.boolValue];
    checkmarkView.selected = organization.favorited.boolValue;
}

#pragma mark - NSFetchedResultsController implementation

- (NSManagedObjectContext *)managedObjectContext {
    return FSPCoreDataManager.sharedManager.GUIObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(FSPOrganization.class)];
        if (self.parentOrganizationID) {
            FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:self.parentOrganizationID error:nil];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(type == %@) && (branch == %@)", FSPOrganizationTeamType, organization.branch];
        } else {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(parents.@count == 0) && (type != %@)", FSPOrganizationTeamType];
        }
        NSSortDescriptor *ordinalSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ordinal"
                                                                                ascending:YES];
        fetchRequest.sortDescriptors = @[ordinalSortDescriptor];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:self.managedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _fetchedResultsController = nil;
        }
    }
    return _fetchedResultsController;
}

@end
