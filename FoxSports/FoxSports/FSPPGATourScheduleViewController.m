//
//  FSPPGATourScheduleViewController.m
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGATourScheduleViewController.h"
#import "FSPPGATourScheduleHeaderView.h"
#import "FSPPGATourScheduleCell.h"
#import "FSPPGAEvent.h"
#import "FSPOrganization.h"
#import "FSPOrganizationSchedule.h"
#import "FSPDataCoordinator.h"

@interface FSPPGATourScheduleViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;
@end

@implementation FSPPGATourScheduleViewController

@synthesize tableView = _tableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize organization = _organization;

- (id)initWithOrganization:(FSPOrganization *)org managedObjectContext:(NSManagedObjectContext *)context;
{
    self = [super init];
    if (self) {
        self.organization = org;
        self.managedObjectContext = context;
        self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    
//    [self.dataCoordinator updateScheduleForOrganization:self.organization callback:^(BOOL success) {
//        if (success) {
//            if (_fetchedResultsController) {
//                [self.fetchedResultsController performFetch:nil];
//            }
//            [self.tableView reloadData];
//        }
//    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPPGATourScheduleCell" bundle:nil] forCellReuseIdentifier:FSPPGATourScheduleCellIdentifier];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - TableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    FSPPGAEvent *event = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    UIView *header = [[FSPPGATourScheduleHeaderView alloc] initWithSectionDate:event.normalizedStartDate];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return FSPPGATourScheduleHeaderHieght;
}

#pragma mark - TableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionsInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionsInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{    
    FSPPGATourScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPPGATourScheduleCellIdentifier];
    [cell populateWithEvent:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return cell;
}

- (NSFetchedResultsController *)fetchedResultsController;
{
    if ([self.organization.schedule.events count] == 0)
        return  nil;
    
    if (_fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPPGAEvent"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.organization.schedule.events];
        
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDesc];
        
        [fetchRequest setFetchBatchSize:40];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dateGroup" cacheName:nil];
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _fetchedResultsController = nil;
        }
        
    }
    return _fetchedResultsController;
}

@end
