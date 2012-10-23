//
//  FSPSportsNewsViewController.m
//  FoxSports
//
//  Created by greay on 5/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSportsNewsViewController.h"
#import "FSPDataCoordinator.h"

#import "FSPNewsHeadline.h"
#import "FSPNewsStory.h"

#import "FSPEventChipsSectionHeader.h"
#import "FSPNewsStoryCell.h"
#import "FSPMoreHeadlinesCell.h"
#import "AFNetworking.h"
#import "FSPLabel.h"
#import "FSPOrganization.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPNewsCity.h"
#import "FSPImageFetcher.h"


#define kHeadlinesGroup @"HEADLINES"
#define kExclusivesGroup @"EXCLUSIVES"

@interface FSPSportsNewsViewController ()

@property (nonatomic, strong) NSMutableDictionary *visibleItemsInSection;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@end

@implementation FSPSportsNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize visibleItemsInSection = _visibleItemsInSection;

- (NSNumber *)newsPageSize;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return [NSNumber numberWithInt:3];
    } else {
        return [NSNumber numberWithInt:5];
    }
}

- (NSString *)lastSelectedEventDefaultsKey;
{
    return [NSString stringWithFormat:@"%@%@", FSPSelectedEventUserDefaultsPrefixKey, @"SportsNews"];
}

- (NSString *)sectionNameKeyPath;
{
    return @"group";
}

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPNewsHeadline"];

    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedDate" ascending:NO];
    NSSortDescriptor *groupSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"group" ascending:NO];
        
    fetchRequest.sortDescriptors = @[groupSortDescriptor, dateSortDescriptor];
    fetchRequest.predicate = [self newsFetchPredicate];
    [fetchRequest setFetchBatchSize:20];
        
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:[self sectionNameKeyPath]
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unable to execute fetch request in: %s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        _fetchedResultsController = nil;
    }
    
    return _fetchedResultsController;
}

- (NSPredicate *)newsFetchPredicate;
{
    return [NSPredicate predicateWithFormat:@"isTopNews == 1"];
}

- (void)dealloc;
{
	self.tableView.delegate = nil;
    _fetchedResultsController.delegate = nil;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPMoreHeadlinesCell" bundle:nil] forCellReuseIdentifier:@"more"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FSPNewsStoryCell" bundle:nil] forCellReuseIdentifier:FSPNewsChipIdentifier];
	
    self.tableView.rowHeight = 65;
    
    self.visibleItemsInSection = [NSMutableDictionary new];
    [self updateHeadlines];
	[self updateVideos];
}

- (void)updateHeadlines;
{    	
	[self.dataCoordinator updateTopNewsHeadlines:^{
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
	// TODO
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSNumber *visibleItemsThisSection = [self.visibleItemsInSection objectForKey:[[NSNumber numberWithInteger:section] stringValue] defaultObject:[self newsPageSize]];
    if (visibleItemsThisSection.unsignedIntegerValue < sectionInfo.objects.count) {
        return visibleItemsThisSection.unsignedIntegerValue + 1;
    } else {
        return sectionInfo.objects.count;
    }
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
	return [super tableView:tableView heightForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	FSPEventChipsSectionHeader *sectionHeader = nil;
    
    if ((NSUInteger)section < self.fetchedResultsController.sections.count) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        title = sectionInfo.name;
        
        if (title) {
            UINib *sectionHeaderNib = [UINib nibWithNibName:@"FSPEventChipsSectionHeader" bundle:nil];
            NSArray *topLevelObjects = [sectionHeaderNib instantiateWithOwner:nil options:nil];
            sectionHeader = [topLevelObjects lastObject];
            sectionHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]);
            
            sectionHeader.startDateGroupLabel.text = title;
        }
    }
    
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (ADS_ENABLED && indexPath.section == FSPAdSectionIndex && indexPath.row == FSPAdRowIndex) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:indexPath.section];
        NSNumber *visibleItemsThisSection = [self.visibleItemsInSection objectForKey:[[NSNumber numberWithInteger:indexPath.section] stringValue] defaultObject:[self newsPageSize]];
        
		BOOL isMoreCell = ((visibleItemsThisSection.unsignedIntegerValue < sectionInfo.objects.count) &&
                           (indexPath.row >= visibleItemsThisSection.integerValue));
		
		if (isMoreCell) {
			FSPMoreHeadlinesCell *cell = (FSPMoreHeadlinesCell *)[self.tableView dequeueReusableCellWithIdentifier:@"more"];
			cell.moreLabel.text = @"More Headlines";
			return cell;
		} else {
			FSPNewsHeadline *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
			FSPNewsStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPNewsChipIdentifier];
			[cell populateWithHeadline:event];
			return cell;
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {

        if ([self.currentSelectedEventPath isEqual:indexPath]) {
            // if we've already selected this row don't reload the
            return;
        }
    }

	if (indexPath.section == FSPAdSectionIndex && indexPath.row == FSPAdRowIndex) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
    
    NSIndexPath *lastSelectedIndexPath = self.currentSelectedEventPath;
	self.currentSelectedEventPath = indexPath;
    
    FSPNewsHeadline	*headline = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    if ([self lastSelectedEventDefaultsKey]) {
        [[NSUserDefaults standardUserDefaults] setValue:headline.newsId forKey:[self lastSelectedEventDefaultsKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    UIView *tableCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([tableCell isKindOfClass:FSPMoreHeadlinesCell.class]) {
        self.currentSelectedEventPath = lastSelectedIndexPath;
        
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:indexPath.section];
        NSNumber *visibleItemsInSection = [self.visibleItemsInSection objectForKey:[[NSNumber numberWithInteger:indexPath.section] stringValue] defaultObject:[self newsPageSize]];
        NSUInteger newItemCount = MIN(visibleItemsInSection.unsignedIntegerValue + [self newsPageSize].intValue,
                                      sectionInfo.objects.count);
        [self.visibleItemsInSection setObject:@(newItemCount) forKey:[[NSNumber numberWithInteger:indexPath.section] stringValue]];
        [self.tableView reloadData];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (lastSelectedIndexPath) {
                [self.tableView selectRowAtIndexPath:lastSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(eventsViewController:didSelectNewsHeadline:)]) {
			[self.delegate eventsViewController:self didSelectNewsHeadline:headline];
        }
    }
}

- (void)selectCurrentEventOnTable
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
	
    if (self.firstLaunch) {
        
		FSPNewsHeadline *selectedHeadline = nil;
        FSPNewsHeadline *defaultHeadline = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		__block NSIndexPath *indexPath = nil;
		
		NSString *currentSelectedEventID = nil;
		if ([self lastSelectedEventDefaultsKey]) {
			currentSelectedEventID = [[NSUserDefaults standardUserDefaults] stringForKey:[self lastSelectedEventDefaultsKey]];        
		}
		if (currentSelectedEventID) {
            [self.fetchedResultsController.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stopIteratingSections) {
                id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)obj;
                __block NSNumber *visibleItemsThisSection = [self.visibleItemsInSection objectForKey:[[NSNumber numberWithInteger:sectionIndex] stringValue] defaultObject:[self newsPageSize]];
                [section.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger headlineIndex, BOOL *stopIteratingItems) {
                    if (visibleItemsThisSection.unsignedIntegerValue < headlineIndex) {
                        visibleItemsThisSection = @(headlineIndex);
                    }
                    FSPNewsHeadline *thisHeadline = (FSPNewsHeadline *)obj;
                    if ([thisHeadline.newsId isEqualToString:currentSelectedEventID]) {
                        indexPath = [NSIndexPath indexPathForRow:(NSInteger)headlineIndex inSection:(NSInteger)sectionIndex];
                        *stopIteratingItems = YES;
                    }
                }];
                if (selectedHeadline) {
                    [self.visibleItemsInSection setObject:visibleItemsThisSection forKey:[[NSNumber numberWithInteger:sectionIndex] stringValue]];
                    *stopIteratingSections = YES;
                }
            }];
        } else if (defaultHeadline) {
            selectedHeadline = defaultHeadline;
			indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		}
		
		if (selectedHeadline && indexPath) {
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
			if (self.delegate && [self.delegate respondsToSelector:@selector(eventsViewController:didSelectNewsHeadline:)]) {
				[self.delegate eventsViewController:self didSelectNewsHeadline:selectedHeadline];
			}
		}
        self.firstLaunch = NO;
        return;
	}
        
    if ([self lastSelectedEventDefaultsKey]) {
		NSString *lastSelectedHeadline = [[NSUserDefaults standardUserDefaults] valueForKey:[self lastSelectedEventDefaultsKey]];
		NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
		for (FSPNewsHeadline *headline in fetchedObjects) {
			if ([headline.newsId isEqualToString:lastSelectedHeadline]) {
				NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:headline];
                if ([self.tableView cellForRowAtIndexPath:indexPath])
                    if (indexPath) {
                        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    }
				break;
			}
		}
	}

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self hideActivityIndicator];
    
    [self selectCurrentEventOnTable];

    NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;

    if (currentIndexPath) {
        [self.tableView selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:currentIndexPath];
    } else if (!self.currentSelectedEventPath) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
}

@end
