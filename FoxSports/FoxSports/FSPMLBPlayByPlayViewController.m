//
//  FSPMLBPlayByPlayViewController.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPlayByPlayViewController.h"

//static NSString * const cacheName = @"com.foxsports.PlayByPlayCache";
//static NSString * const FSPPlayByPlayCellIdentifier = @"FSPPlayByPlayCellIdentifier";
//
@interface FSPMLBPlayByPlayViewController ()
//@property (nonatomic, weak) IBOutlet UITableView *tableView;
//@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSFetchedResultsController *playsFetchedResultsController;
//@property (nonatomic, strong) NSFetchedResultsController *scoringFetchedResultsController;
//@property (nonatomic, strong, readonly) NSFetchedResultsController *currentFetchedResultsController;
//@property (weak, nonatomic) IBOutlet UILabel *noDataAvailableLabel;
@end
//
@implementation FSPMLBPlayByPlayViewController
//
//@synthesize tableView = _tableView;
//@synthesize selectedIndex;
//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize currentEvent = _currentEvent;
@synthesize playsFetchedResultsController = _playsFetchedResultsController;
//@synthesize scoringFetchedResultsController = _scoringFetchedResultsController;
//@synthesize currentFetchedResultsController = _currentFetchedResultsController;
//@synthesize noDataAvailableLabel = _noDataAvailableLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subclassing

- (NSFetchedResultsController *)currentFetchedResultsController;
{
    return self.playsFetchedResultsController;
}

@end
