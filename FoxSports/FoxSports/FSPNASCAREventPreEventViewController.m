//
//  FSPNASCAREventPreEventViewController.m
//  FoxSports
//
//  Created by greay on 7/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCAREventPreEventViewController.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPCoreDataManager.h"
#import "FSPEvent.h"
#import "FSPRacingEvent.h"
#import "FSPRacingTrackRecords.h"
#import "FSPNASCARTrackRecordsCell.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPImageFetcher.h"
#import "FSPGameDetailSectionHeader.h"

#define MAX_DETAILS_CONTAINER_HEIGHT 450

@interface FSPNASCAREventPreEventViewController ()
@property (nonatomic, weak, readwrite) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *trackTypeLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *locationTitleLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *trackTypeTitleLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *trackImageView;
@property (nonatomic, weak, readwrite) IBOutlet UITableView *tableView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *noStoryLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIView *storyHeaderLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIView *storyContainer;
@property (nonatomic, weak, readwrite) IBOutlet UIView *recordsContainer;
@property (nonatomic, weak, readwrite) IBOutlet UIView *detailsContainer;
@property (nonatomic, weak, readwrite) IBOutlet FSPGameDetailSectionHeader *storySectionHeader;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)updateTrackDetails;

@end

@implementation FSPNASCAREventPreEventViewController
@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize locationLabel = _locationLabel;
@synthesize trackTypeLabel = _trackTypeLabel;
@synthesize locationTitleLabel = _locationTitleLabel;
@synthesize trackTypeTitleLabel = _trackTypeTitleLabel;
@synthesize trackImageView = _trackImageView;
@synthesize tableView = _tableView;
@synthesize noStoryLabel = _noStoryLabel;
@synthesize storyHeaderLabel = _storyHeaderLabel;
@synthesize storyContainer = _storyContainer;
@synthesize recordsContainer = _recordsContainer;
@synthesize detailsContainer = _detailsContainer;
@synthesize storySectionHeader = _storySectionHeader;

@synthesize fetchedResultsController = _fetchedResultsController;

//------------------------------------------------------------------------------
// MARK: - View Lifecyle
//------------------------------------------------------------------------------

- (FSPNASCAREventPreEventViewController *)init
{
    self = [super init];
    if (self) {
        self = [super initWithNibName:@"FSPNASCAREventPreEventViewController" bundle:nil];
    }
    
    return self;
}

- (UIScrollView *)scrollView;
{
    return (UIScrollView *)self.view;
}

- (void)viewDidLoad
{
    UINib *trackRecordNib = [UINib nibWithNibName:@"FSPNASCARTrackRecordsCell" bundle:nil];
    [self.tableView registerNib:trackRecordNib forCellReuseIdentifier:@"FSPTrackRecordCell"];
    
    self.noStoryLabel.textColor = [UIColor whiteColor];
    self.noStoryLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:18.0];
    
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.];
    
    self.trackTypeLabel.textColor = [UIColor whiteColor];
    self.trackTypeLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.];
    
    self.trackTypeTitleLabel.textColor = [UIColor whiteColor];
    self.trackTypeTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.];
    
    self.locationTitleLabel.textColor = [UIColor whiteColor];
    self.locationTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
        
    [self updateViewPositions];
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
        self.fetchedResultsController = nil;
        [self.dataCoordinator updatePreRaceInfoForRacingEvent:currentEvent.objectID];
        [self.scrollView scrollRectToVisible:self.detailsContainer.frame animated:NO];
        [self updateTrackDetails];
        [self.tableView reloadData];
        [self updateViewPositions];

        if (!self.currentEvent) {
            return;
        }
        
        FSPStoryType storyType;
        if (self.currentEvent.eventCompleted.boolValue) {
            storyType = FSPStoryTypeRecap;
        } else {
            storyType = FSPStoryTypePreview;
        }

        [[FSPDataCoordinator defaultCoordinator] asynchronouslyLoadNewsStoryForEvent:self.currentEvent.objectID storyType:storyType success:^(FSPNewsStory *story) {
            [self updateStoryView];

        } failure:^(NSError *error) {
            NSLog(@"Error fetching story for event %@ :%@", self.currentEvent.branch, error);
        }];
        
    }
}

- (void)updateTrackDetails
{
    if ([self.currentEvent isKindOfClass:[FSPRacingEvent class]]) {
        FSPRacingEvent *racingEvent = (FSPRacingEvent *)self.currentEvent;
        self.locationLabel.text = racingEvent.location;
        NSString *trackInfo = [NSString stringWithFormat:@"%@ %@",racingEvent.length, racingEvent.trackType];
        self.trackTypeLabel.text = trackInfo;
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:racingEvent.trackPhotoURL]
                                           withCallback:^(UIImage *image) {
                                               self.trackImageView.image = image;
                                               [self updateViewPositions];
                                           }];
    }
}

#pragma mark - Layout
- (void)updateViewPositions;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Section order, vertically: Track Details | Track Records | Story
        if (self.trackTypeLabel.text.length > 0 || self.locationLabel.text.length > 0) {
            CGFloat height = self.trackTypeLabel.frame.size.height * 2 + 5 + 30;
            self.detailsContainer.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, height);
            self.detailsContainer.hidden = NO;
        
            if (self.trackImageView.image) {
                self.trackImageView.frame = CGRectMake(0, CGRectGetMaxY(self.detailsContainer.frame), self.view.bounds.size.width, self.trackImageView.image.size.height);
                CGRect detailsFrame = self.detailsContainer.frame;
                detailsFrame.size.height = detailsFrame.size.height + self.trackImageView.frame.size.height;
                self.detailsContainer.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, detailsFrame.size.height);
                self.detailsContainer.hidden = NO;
            }
        }
        else {
            self.detailsContainer.hidden = YES;
            self.detailsContainer.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 0.0);
        }
        
        if (self.fetchedResultsController.fetchedObjects.count > 0) {
            self.recordsContainer.hidden = NO;
            CGFloat height = (self.fetchedResultsController.fetchedObjects.count * 44) + 30;
            self.recordsContainer.frame = CGRectMake(0.0, CGRectGetMaxY(self.detailsContainer.frame), self.view.bounds.size.width, height);
        }
        else {
            self.recordsContainer.hidden = YES;
            self.recordsContainer.frame = CGRectMake(0.0, CGRectGetMaxY(self.detailsContainer.frame), self.view.bounds.size.width, 0.0);
        }
            
        CGRect storyHeaderFrame = self.storyHeaderLabel.frame;
        storyHeaderFrame.origin = CGPointMake(0, CGRectGetMaxY(self.recordsContainer.frame));
        self.storyHeaderLabel.frame = storyHeaderFrame;
        
        CGRect storyFrame = self.storyContainer.frame;
        storyFrame.origin = CGPointMake(0, CGRectGetMaxY(self.storyHeaderLabel.frame));
        self.storyContainer.frame = storyFrame;
    }
    else {
        if (self.trackTypeLabel.text.length > 0 || self.locationLabel.text.length > 0 || self.fetchedResultsController.fetchedObjects.count) {
            self.detailsContainer.hidden = NO;
            if (self.trackImageView.image == nil) {
                CGFloat labelY = CGRectGetMaxY(self.trackTypeLabel.frame);
                CGFloat tableY = self.tableView.frame.origin.y + self.fetchedResultsController.fetchedObjects.count * 44;
                CGFloat newHeight = labelY > tableY ? labelY : tableY;
                CGRect detailsFrame = self.detailsContainer.frame;
                // Don't make the frame any bigger than what it would be if the image was present
                if (MAX_DETAILS_CONTAINER_HEIGHT > newHeight ) {
                    detailsFrame.size.height = newHeight;
                    self.detailsContainer.frame = detailsFrame;
                }
            }
            CGRect storyHeaderFrame = self.storySectionHeader.frame;
            storyHeaderFrame.origin = CGPointMake(0, CGRectGetMaxY(self.detailsContainer.frame));
            self.storySectionHeader.frame = storyHeaderFrame;
            
            CGRect storyFrame = self.storyContainer.frame;
            storyFrame.origin.y = CGRectGetMaxY(self.storySectionHeader.frame) + 15;
            self.storyContainer.frame = storyFrame;
        }
        else {
            CGRect storyHeaderFrame = self.storySectionHeader.frame;
            storyHeaderFrame.origin = CGPointMake(0, CGRectGetMinY(self.detailsContainer.frame));
            self.storySectionHeader.frame = storyHeaderFrame;
            
            CGRect storyFrame = self.storyContainer.frame;
            storyFrame.origin.y = CGRectGetMaxY(self.storySectionHeader.frame) + 15;
            self.storyContainer.frame = storyFrame;

            self.detailsContainer.hidden = YES;
            
        }
    }
    
    CGFloat contentHeight = CGRectGetMaxY(self.storyContainer.frame);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, contentHeight);
    
    [self.scrollView flashScrollIndicators];
}


//------------------------------------------------------------------------------
// MARK: - Fetched results controller
//------------------------------------------------------------------------------
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) 
        return _fetchedResultsController;
  
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FSPRacingTrackRecords"];
    request.predicate = [NSPredicate predicateWithFormat:@"track.eventTitle = %@", ((FSPRacingEvent *)self.currentEvent).eventTitle];
    
    NSSortDescriptor *recordSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"track.eventTitle" ascending:NO];
    
    request.sortDescriptors = @[recordSortDescriptor];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    if (error) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _fetchedResultsController = nil;
    }
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
// MARK: - UITableViewDatasource
//------------------------------------------------------------------------------

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPNASCARTrackRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FSPTrackRecordCell"];
    [cell populateWithRace:(FSPRacingTrackRecords *)[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return cell;
}

@end
