//
//  FSPNewsRegionsViewController.m
//  FoxSports
//
//  Created by Stephen Spring on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsRegionsViewController.h"
#import "FSPNewsCity.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPNewsRegionCell.h"
#import "FSPDataCoordinator.h"

#define kRegionCellIdentifier @"RegionCellIdentifier"

typedef void(^SelectionChangedBlock)(FSPNewsCity *selectedCity);

@interface FSPNewsRegionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, copy) SelectionChangedBlock selectionChangedBlock;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation FSPNewsRegionsViewController

@synthesize tableView = _tableView;
@synthesize regions = _regions;
@synthesize selectionChangedBlock = _selectionChangedBlock;
@synthesize selectedCity = _selectedCity;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithRegions:(NSArray *)regions context:(NSManagedObjectContext *)context selectionCompletionHandler:(void(^)(FSPNewsCity *selectedCity))selectionCompletion
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _regions = regions;
        _selectionChangedBlock = selectionCompletion;
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _managedObjectContext = context;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize viewSize = [FSPNewsRegionsViewController viewSize];
	self.view.frame = CGRectMake(0.0, 0.0, viewSize.width, viewSize.height);

    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor fsp_lightGrayColor];
    [self.view addSubview:self.tableView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat toolbarHeight = 44.0;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, viewSize.width, toolbarHeight)];
        UIBarButtonItem *spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSString *title = @"Local Regions";
        UIFont *titleFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:18.0];
        CGSize titleSize = [title sizeWithFont:titleFont];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, titleSize.width, titleSize.height)];
        titleLabel.center = toolbar.center;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = title;
        titleLabel.font = titleFont;
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView)];
        [toolbar setItems:@[spacerItem, titleItem, spacerItem, closeItem]];
        [self.view addSubview:toolbar];
        self.tableView.contentInset = UIEdgeInsetsMake(toolbarHeight, 0.0, 0.0, 0.0);
    }
    
    UINib *cellNib = [UINib nibWithNibName:@"FSPNewsRegionCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kRegionCellIdentifier];
    
    [[UILabel appearanceWhenContainedIn:[self class], nil] performSelector:@selector(setShadowColor:) withObject:[UIColor clearColor]];
}

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPNewsCity"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityName" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unable to execute fetch request in: %s error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        _fetchedResultsController = nil;
    }
    
    return _fetchedResultsController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Instance Methods

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Class Methods

+ (CGSize)viewSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(240.0, 500.0);
    } else {
        return [UIScreen mainScreen].applicationFrame.size;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedCity  = [[self.fetchedResultsController fetchedObjects] objectAtIndex:[indexPath row]];
    [tableView reloadData];
    self.selectionChangedBlock(self.selectedCity);
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPNewsRegionCell *cell = [tableView dequeueReusableCellWithIdentifier:kRegionCellIdentifier];
    if (cell == nil) {
        cell = [[FSPNewsRegionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRegionCellIdentifier];
    }

    FSPNewsCity *city = [[self.fetchedResultsController fetchedObjects] objectAtIndex:[indexPath row]];
    cell.regionNameLabel.text = city.cityName;
    cell.regionNameLabel.backgroundColor = [UIColor clearColor];
    cell.regionNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:17.0f];
    cell.regionNameLabel.textColor = [UIColor blackColor];
    cell.selectionImageView.image = nil;
    
    if ([self.selectedCity.objectID isEqual:city.objectID]) {
        cell.regionNameLabel.textColor = [UIColor fsp_newsRegionSelectionColor];
        cell.selectionImageView.image = [UIImage imageNamed:@"dot.png"];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}
@end
