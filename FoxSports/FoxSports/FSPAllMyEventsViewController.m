//
//  FSPAllMyEventsViewController.m
//  FoxSports
//
//  Created by greay on 5/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPAllMyEventsViewController.h"
#import "FSPEvent.h"
#import "FSPOrganization.h"
#import "FSPDataCoordinator.h"

@interface FSPAllMyEventsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *favoritesFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *favoriteOrganizationsFetchedResultsController;
@property (nonatomic, strong) NSArray *organizations;
@property (nonatomic, weak) id favoritesUpdateObserver;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;
@property NSString *lastSelectedEventIdentifier;

@end

@implementation FSPAllMyEventsViewController

- (NSString *)lastSelectedEventDefaultsKey
{
	return self.lastSelectedEventIdentifier;
}

- (void)setLastSelectedEventKeyIdentifier:(NSString *)uniqueIdentifier;
{
    self.lastSelectedEventIdentifier = uniqueIdentifier;
}

- (NSFetchedResultsController *)fetchedResultsController;
{
    return self.favoritesFetchedResultsController;
}

- (NSFetchedResultsController *)favoritesFetchedResultsController;
{
    if (_favoritesFetchedResultsController) {
        return _favoritesFetchedResultsController;
    }
    
    [FSPOrganization endUpdatingOrganziations];
    NSArray *favoritedOrganizations = [[self favoriteOrganizationsFetchedResultsController] fetchedObjects];
    [self.dataCoordinator beginUpdatingEventsForOrganizationIds:[favoritedOrganizations valueForKey:@"objectID"]];
    
    NSFetchRequest *fetchRequest  = [[NSFetchRequest alloc] initWithEntityName:@"FSPEvent"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY organizations IN %@", favoritedOrganizations];
	[fetchRequest setFetchBatchSize:20];
	
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    NSSortDescriptor *uniqueIdSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uniqueIdentifier" ascending:YES];
    NSArray *sortDescriptors = @[dateSortDescriptor, uniqueIdSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    _favoritesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"startDateGroup" cacheName:nil];
    
    _favoritesFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_favoritesFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _favoritesFetchedResultsController = nil;
	}
	
    return _favoritesFetchedResultsController;
}

- (NSFetchedResultsController *)favoriteOrganizationsFetchedResultsController;
{
    if (_favoriteOrganizationsFetchedResultsController) {
        return _favoriteOrganizationsFetchedResultsController;
    }
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPOrganization"];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"favorited == YES"];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"uniqueIdentifier" ascending:YES]]];
	
    _favoriteOrganizationsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _favoriteOrganizationsFetchedResultsController.delegate = self;

    NSError *error = nil;
	if (![_favoriteOrganizationsFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _favoritesFetchedResultsController = nil;
	}
    
    return _favoriteOrganizationsFetchedResultsController;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    self.lastSelectedEventIdentifier = nil;
    [FSPOrganization endUpdatingOrganziations];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.favoritesFetchedResultsController) {
        [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    } else if (controller == self.favoriteOrganizationsFetchedResultsController) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
            case NSFetchedResultsChangeDelete:
                self.favoriteOrganizationsFetchedResultsController = nil;
                self.favoritesFetchedResultsController = nil;
                break;
            case NSFetchedResultsChangeMove:
            case NSFetchedResultsChangeUpdate:
            default:
                break;
        }

    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[FSPOrganization endUpdatingOrganziations];
}


@end
