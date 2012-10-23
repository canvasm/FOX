//
//  FSPLeaderboardViewController~ipad.m
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLeaderboardViewController.h"
#import "FSPCoreDataManager.h"
#import "FSPRacingEvent.h"
#import "FSPExtendedEventDetailManaging.h"
#import "FSPEvent.h"
#import "UIFont+FSPExtensions.h"

@interface FSPLeaderboardViewController () <FSPExtendedEventDetailManaging>

@end

@implementation FSPLeaderboardViewController

@synthesize tableView = _tableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize noDataAvailableLabel = _noDataAvailableLabel;

- (id)initWithEvent:(FSPEvent *)event
{
    NSString *nibName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = @"FSPLeaderboardViewController~iphone";
    } else {
        nibName = @"FSPLeaderboardViewController~ipad";
    }
    self = [self initWithNibName:nibName bundle:nil];
    if (self) {
        _currentEvent = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.hidden = YES;
    
    [self setupNoDataAvailableLabel];
}

- (void)setupNoDataAvailableLabel
{
    NSString *labelText = @"No Data Available";
    self.noDataAvailableLabel.backgroundColor = [UIColor clearColor];
    self.noDataAvailableLabel.textColor = [UIColor whiteColor];
    self.noDataAvailableLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:18.0];
    self.noDataAvailableLabel.text = labelText;
    self.noDataAvailableLabel.hidden = YES;
}

- (void)updateViewForNewData
{
    if ([[self.fetchedResultsController fetchedObjects] count] < 1) {
        self.tableView.hidden = YES;
        self.noDataAvailableLabel.hidden = NO;
    } else {
        self.tableView.hidden = NO;
        self.noDataAvailableLabel.hidden = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)fetchData
{
    // To be overridden
}

- (NSArray *)setIndexPathsForReloadWithSelectedIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *oldIndexPath = self.selectedIndexPath;
    NSArray *indexPaths = nil;
    
    if (!oldIndexPath) {
        indexPaths = @[indexPath];
        self.selectedIndexPath = indexPath;
    }
    else if ([indexPath isEqual:oldIndexPath]) {
        indexPaths = @[indexPath];
        self.selectedIndexPath = nil;
    } else {
        indexPaths = @[oldIndexPath, indexPath];
        self.selectedIndexPath = indexPath;
    }
    return indexPaths;
}

@end
