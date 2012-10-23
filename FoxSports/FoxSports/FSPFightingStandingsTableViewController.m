//
//  FSPMLBStandingsViewController.m
//  FoxSports
//
//  Created by Laura Savino on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFightingStandingsTableViewController.h"
#import "FSPFightTitleHolder.h"
#import "FSPOrganization.h"
#import "FSPFightingStandingsCell.h"
#import "FSPCoreDataManager.h"


static const NSInteger FSPMLBWildCardTeamCount = 5;
static NSString * const FSPMLBStandingsSectionHeaderViewNibName = @"FSPMLBStandingsSectionHeaderView";

@interface FSPFightingStandingsTableViewController ()

- (NSArray *)fightersForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) FSPOrganization * organization;

@end

@implementation FSPFightingStandingsTableViewController {
    NSUInteger fighters;
    NSUInteger cellHeight;
}
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize organization = _organization;

- (id)initWithOrganization:(FSPOrganization *)organization conferenceName:(NSString *)conferenceName
      managedObjectContext:(NSManagedObjectContext *)context segment:(FSPStandingsSegmentSelected)segment
{
    self = [super initWithOrganization:organization conferenceName:conferenceName managedObjectContext:context segment:segment];
    if (!self) return nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fighters = 2;
        cellHeight = 197;
    } else {
        fighters = 3;
        cellHeight = 234;
    }
    
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UINib *conferenceCellNib = [UINib nibWithNibName:@"FSPFightingStandingsCell" bundle:nil];
    [self.tableView registerNib:conferenceCellNib forCellReuseIdentifier:FSPFightingStandingsCellReuseIdeintifier];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSUInteger numFighters = [sectionInfo numberOfObjects];
    NSUInteger rows = numFighters / fighters;
    if ([sectionInfo numberOfObjects] % fighters != 0)
        rows++;

    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPFightingStandingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPFightingStandingsCellReuseIdeintifier];
    [cell populateWithFighters:[self fightersForIndexPath:indexPath]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    return nil;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!self.organization)
        return nil;
    
    if(_fetchedResultsController)
        return _fetchedResultsController;
    
    [self refreshFetchedResultsController];
    
    return _fetchedResultsController;
}

- (void)refreshFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPFightTitleHolder"];
    NSPredicate *predicate;
    NSSortDescriptor *sectionSortDescriptor;
    NSString *sectionNameKeyPath;
    
    predicate = [NSPredicate predicateWithFormat:@"branch == %@", self.organization.branch];
    sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sectionSortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[FSPCoreDataManager sharedManager] GUIObjectContext] sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
	}
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView reloadData];
}

- (NSArray *)fightersForIndexPath:(NSIndexPath *)indexPath;
 {
     NSMutableArray *titleholders = [NSMutableArray array];
     NSUInteger maxFighters = ((indexPath.row * fighters) + fighters);
     for (NSUInteger i = indexPath.row * fighters; i < maxFighters && i < [self.fetchedResultsController.fetchedObjects count] ; ++i) {
         [titleholders addObject:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
         indexPath = [NSIndexPath indexPathForRow:i + 1 inSection:indexPath.section];
     }
         
     return [NSArray arrayWithArray:titleholders];
 }

@end
