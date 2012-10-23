//
//  FSPOrganizationNewsViewController.m
//  FoxSports
//
//  Created by Steven Stout on 6/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationNewsViewController.h"
#import "FSPDataCoordinator.h"
#import "FSPOrganization.h"
#import "FSPEventChipsSectionHeader.h"
#import "FSPNewsStoryCell.h"

@interface FSPOrganizationNewsViewController ()
@property (nonatomic)  NSFetchedResultsController *videosFetchedResultsController;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;
@end

@implementation FSPOrganizationNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
}

- (NSFetchedResultsController *)videosFetchedResultsController;
{
    if (_videosFetchedResultsController)
        return _videosFetchedResultsController;
    
	// TODO: need to add something to the model, I think, so we can fetch the appropriate videos.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FSPVideo" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY organizations.uniqueIdentifier == %@", self.organization.uniqueIdentifier];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSSortDescriptor *formatSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"format" ascending:YES];
    NSArray *sortDescriptors = @[formatSortDescriptor, sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    

    _videosFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"format" cacheName:nil];

    _videosFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_videosFetchedResultsController performFetch:&error]) {
        NSLog(@"Unable to execute fetch request in: %s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        _videosFetchedResultsController = nil;
    }
    
    return _videosFetchedResultsController;
}


- (NSString *)lastSelectedEventDefaultsKey
{
	return [NSString stringWithFormat:@"%@%@%@", FSPSelectedEventUserDefaultsPrefixKey, @"OrganizationNews", self.organization.uniqueIdentifier];
}

- (NSPredicate *)newsFetchPredicate
{
    return [NSPredicate predicateWithFormat:@"isTopNews == 0 AND %@ in organizations", self.organization];
}

- (void)updateHeadlines
{        
    [self.dataCoordinator updateNewsHeadlinesForOrganizationId:self.organization.objectID success:^{
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
			[self.tableView reloadData];
			if (indexPath) {
				[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			} else {
				[self selectCurrentEventOnTable];
			}
		});
	} failure:^(NSError *error) {
		NSLog(@"error updating news:%@", error);
	}];
}

- (void)updateVideos
{
	[self.dataCoordinator updateVideosForOrganizationsIds:[NSArray arrayWithObject:self.organization.objectID] callback:^(BOOL success) {
    }];

}


#pragma mark - TableView DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.fetchedResultsController.sections.count + self.videosFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if ((NSUInteger)section < self.fetchedResultsController.sections.count) {
		return [super tableView:tableView numberOfRowsInSection:section];
	} else {
		return self.videosFetchedResultsController.fetchedObjects.count;
	}
}


#pragma mark - TableView Delegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if ((NSUInteger)section < self.fetchedResultsController.sections.count) {
		return [super tableView:tableView viewForHeaderInSection:section];
	} else {
		FSPEventChipsSectionHeader *sectionHeader = nil;
		
		UINib *sectionHeaderNib = [UINib nibWithNibName:@"FSPEventChipsSectionHeader" bundle:nil];
		NSArray *topLevelObjects = [sectionHeaderNib instantiateWithOwner:nil options:nil];
		sectionHeader = [topLevelObjects lastObject];
		sectionHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]);
		
		sectionHeader.startDateGroupLabel.text = @"Video Clips";
		
		return sectionHeader;

	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if ((NSUInteger)indexPath.section < self.fetchedResultsController.sections.count) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	} else {
		FSPVideo *video = (FSPVideo *)[[self.videosFetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
		
		FSPNewsStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPNewsChipIdentifier];
		[cell populateWithVideo:video];
		return cell;

	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((NSUInteger)indexPath.section < self.fetchedResultsController.sections.count) {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	} else {
		FSPVideo *video = [[self.videosFetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(eventsViewController:didSelectVideo:)]) {
			[self.delegate eventsViewController:self didSelectVideo:video];
        }
	}

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
	[self.tableView reloadData];
	[super controllerDidChangeContent:controller];
}

@end

