//
//  FSPEventVideosViewController.m
//  FoxSports
//
//  Created by Stephen Spring on 6/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventVideosViewController.h"
#import "FSPEvent.h"
#import "FSPDataCoordinator.h"
#import "FSPVideoTableViewCell.h"
#import "FSPGameDetailSectionHeader.h"
#import "UIFont+FSPExtensions.h"

@interface FSPEventVideosViewController ()

@property (weak, nonatomic) IBOutlet UITableView *videosTableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSUInteger videosPerCell;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

- (void)updateVideos;

@end

@implementation FSPEventVideosViewController
@synthesize videosTableView;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize videosPerCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    }
    return self;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent) {
		_currentEvent = currentEvent;
        [self updateFetchedResultsController];
		[self updateVideos];
        if ([[[self fetchedResultsController] sections] count]) {
            for (NSUInteger i = 0; i < [[[self fetchedResultsController] sections] count]; i++) {
                if ([self tableView:nil numberOfRowsInSection:i]) {
                    [self.videosTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
            }
        }
        
        /**** TESTING ONLY ****/
        // Remove when we have actual video requests to use the tokens with.
#ifdef FSP_LOG_VIDEO
        [[FSPDataCoordinator defaultCoordinator] getPlatformAuthenticationTokenWithCallback:^(NSString *response) {
            FSPLogVideo(@"thePlatform authorization token = %@", response);
        }];
#endif
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.videosTableView.accessibilityIdentifier = @"videoList";
    self.videosTableView.allowsSelection = NO;
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.videosTableView.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.videosTableView.backgroundView = backgroundView;
    self.videosTableView.backgroundColor = [UIColor clearColor];
    self.videosTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.videosPerCell = 3;
}

- (void)viewDidUnload
{
    [self setVideosTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)updateVideos
{
    if (self.currentEvent) {
        [self.dataCoordinator updateVideosForEventId:self.currentEvent.objectID callback:^(BOOL success) {
            if (success)
                [self.videosTableView reloadData];
        }];
    }
}

- (void)updateFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FSPVideo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY events.uniqueIdentifier == %@", self.currentEvent.uniqueIdentifier];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSSortDescriptor *formatSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"contentType" ascending:YES];
    NSArray *sortDescriptors = @[formatSortDescriptor, sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"contentType" cacheName:nil];
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Video Fetch Error: %@", error.localizedDescription);
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"VideoCellIdentifier";
    
    FSPVideoTableViewCell *cell = (FSPVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FSPVideoTableViewCell" owner:self options:nil];
        
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = currentObject;
            }
        }
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        backgroundView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backgroundView;
    }
    
    // Populate cell with videos 
    
    // Reset the number of videos per cell to maximum amount of vidoes per cell
    self.videosPerCell = 3;
    
    // Get info about the current section in the tableView
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:[indexPath section]];
    
    // Create one tableView row for every videosPerCell
    NSUInteger firstVideoIndexForCell = [indexPath row] * videosPerCell;
    
    // Handle situation where there are not enough videos left in the section to populate all video containers in the cell
    NSUInteger remainingVideoIndexes = [sectionInfo numberOfObjects] - firstVideoIndexForCell;
    if (remainingVideoIndexes < videosPerCell) {
        self.videosPerCell = remainingVideoIndexes;
    }
    
    // Find the videos that belong to the cell
    NSRange videosRange = NSMakeRange(firstVideoIndexForCell, videosPerCell);
    NSIndexSet *videosIndexSet = [NSIndexSet indexSetWithIndexesInRange:videosRange];
    NSArray *videosForCell = [[sectionInfo objects] objectsAtIndexes:videosIndexSet];
    [cell configureWithVideos:videosForCell];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    NSUInteger sectionsCount = [[self.fetchedResultsController sections] count];
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSUInteger numberOfFetchedObjects = [sectionInfo numberOfObjects];
    if (numberOfFetchedObjects == 0) {
        return numberOfFetchedObjects;
    }
    NSUInteger numberOfRows = numberOfFetchedObjects/videosPerCell + 1;
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FSPGameDetailSectionHeader *headerView = [[FSPGameDetailSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
    headerView.highlightLineFlag = @(YES);
    headerView.darkLineFlag = @(YES);
    headerView.backgroundColor = [UIColor clearColor];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 20.0f, 0.0f)];
    label.text = sectionInfo.name;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0f];
    [headerView addSubview:label];
    return headerView; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 186.0;
    }
    return 100.0;
}

@end
