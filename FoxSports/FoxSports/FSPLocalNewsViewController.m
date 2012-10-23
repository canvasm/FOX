//
//  FSPLocalNewsViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLocalNewsViewController.h"
#import "FSPDataCoordinator.h"
#import "FSPOrganization.h"

#import "FSPNewsCity.h"
#import "FSPRegionSelectorView.h"
#import "FSPNewsRegionsViewController.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "FSPNewsHeadline.h"
#import "FSPNewsStoryCell.h"

@interface FSPLocalNewsViewController () <UIPopoverControllerDelegate>

@property (nonatomic, strong) NSManagedObjectID *newsCityID;
@property (nonatomic, strong) UIPopoverController *regionsPopoverController;
@property (nonatomic, strong) NSArray *newsRegions;
@property (nonatomic, strong) FSPNewsRegionsViewController *regionsViewController;
@property (nonatomic, strong) FSPRegionSelectorView *regionSelectorView;
@property (readonly) FSPNewsCity *currentCity;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@end

// private methods
@interface FSPLocalNewsViewController (FSPSportsNewsViewController)

- (NSFetchedResultsController *)fetchedResultsController;

@end

@implementation FSPLocalNewsViewController

@synthesize newsCityID = _newsCityID;
@synthesize regionsPopoverController = _regionsPopoverController;
@synthesize newsRegions = _newsRegions;
@synthesize regionsViewController = _regionsViewController;
@synthesize regionSelectorView = _regionSelectorView;

- (FSPNewsCity *)currentCity;
{
    if (self.newsCityID != nil) {
       return (FSPNewsCity *)[[self managedObjectContext] existingObjectWithID:self.newsCityID error:nil];
    } else {
        return nil;
    }
}

- (NSString *)lastSelectedEventDefaultsKey;
{
    return [NSString stringWithFormat:@"%@%@", FSPSelectedEventUserDefaultsPrefixKey, @"LocalSportsNews"];
}

- (NSPredicate *)newsFetchPredicate;
{
    return [NSPredicate predicateWithFormat:@"cityName == %@", self.currentCity.cityName];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    
    NSString *localNewsCityName = [[NSUserDefaults standardUserDefaults] valueForKey:@"localNewsCityName"];

    if (localNewsCityName) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPNewsCity"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"cityName == %@", localNewsCityName];
        NSError *error = nil;
        NSArray *localCityArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        self.newsCityID = [[localCityArray lastObject] objectID];
        [self updateHeadlines];
    }
    
    [self setRegionsSelectorViewVisible:YES];
    [self updateLocalNewsCities];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self setRegionsSelectorViewVisible:YES];
}

- (void)updateHeadlines;
{
    if (self.newsCityID) {
        [self.dataCoordinator updateNewsHeadlinesForCity:self.newsCityID success:^{
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                self.fetchedResultsController.delegate = nil;
                self.fetchedResultsController = nil;
                
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
}

- (void)updateLocalNewsCities;
{
    [self.dataCoordinator updateNewsCities:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPNewsCity"];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityName" ascending:YES];
            [fetchRequest setSortDescriptors:@[sortDescriptor]];
            NSError *error = nil;
            self.newsRegions = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if ([self.newsRegions count] > 0 && !self.newsCityID) {
                if (!self.newsCityID) {
                    [self showRegions:self.regionSelectorView.selectRegionButton];
                }
            }
            [self updateHeadlines];
        });
	} failure:^(NSError *error) {
		NSLog(@"error updating cities:%@", error);
	}];
}

- (void)setRegionsSelectorViewVisible:(BOOL)visible;
{
    CGFloat segmentedControlHeight = 33.0;
    if (visible) {
        if (!self.regionSelectorView) {
            self.regionSelectorView = [[FSPRegionSelectorView alloc] init];
            self.regionSelectorView.frame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 41.0);
            FSPNewsCity *city = self.currentCity;

            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.regionSelectorView.selectRegionButton setTitle:city.cityName forState:UIControlStateNormal];
            } else {
                self.regionSelectorView.selectedRegionLabel.text = city.cityName;
            }
            [self.regionSelectorView.selectRegionButton addTarget:self action:@selector(showRegions:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.regionSelectorView];
        }
        self.tableView.frame = CGRectMake(0.0, CGRectGetMaxY(self.regionSelectorView.frame), self.view.bounds.size.width, self.view.bounds.size.height - self.regionSelectorView.bounds.size.height);
        self.regionSelectorView.hidden = NO;
    } 
    
    else {
        self.regionSelectorView.hidden = YES;
        self.tableView.frame = CGRectMake(0.0, segmentedControlHeight, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}

- (void)showRegions:(UIButton *)sender;
{
    if (!self.regionsViewController) {
        self.regionsViewController = [[FSPNewsRegionsViewController alloc] initWithRegions:self.newsRegions context:self.managedObjectContext selectionCompletionHandler:^(FSPNewsCity *city) {
            self.newsCityID = city.objectID;
            [[NSUserDefaults standardUserDefaults] setObject:city.cityName forKey:@"localNewsCityName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self updateHeadlines];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.regionsPopoverController dismissPopoverAnimated:YES];
                [self.regionSelectorView.selectRegionButton setTitle:city.cityName forState:UIControlStateNormal];
                self.regionSelectorView.selectedRegionLabel.text = city.cityName;
                [self.regionSelectorView swapColor:NO];
            } else {
                self.regionSelectorView.selectedRegionLabel.text = city.cityName;
                [self.regionsViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    self.regionsViewController.selectedCity = self.currentCity;
    [self.regionSelectorView swapColor:YES];
    
    if (!self.regionsPopoverController && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:self.regionsViewController];
        self.regionsPopoverController = popoverController;
        self.regionsPopoverController.popoverContentSize = [FSPNewsRegionsViewController viewSize];
        self.regionsPopoverController.delegate = self;
        FSPAppDelegate *delegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
        self.regionsPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, delegate.rootViewController.view.bounds.size.width - (CGRectGetMaxX(self.view.frame) + 76.0));
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect popoverOrigin = CGRectMake(CGRectGetMaxX(sender.bounds) - 32.0, 0.0, 32.0, sender.bounds.size.height);
        // See https://ubermind.jira.com/browse/FSTOGOIOS-1843.  Fast clicking can get in a state
        // where the button has no window, causing a crash.
        if ([sender window])
            [self.regionsPopoverController presentPopoverFromRect:popoverOrigin inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self presentViewController:self.regionsViewController animated:YES completion:nil];
    }
}

#pragma mark - Fetched Results Controller
- (NSString *)sectionNameKeyPath;
{
    return nil;
}

#pragma mark - TableView Delegate & Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.objects.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
	return 0;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	FSPNewsStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FSPNewsChipIdentifier];
	[cell populateWithHeadline:[self.fetchedResultsController objectAtIndexPath:indexPath]];
	return cell;
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [self.regionSelectorView swapColor:NO];
    return YES;
}

@end
