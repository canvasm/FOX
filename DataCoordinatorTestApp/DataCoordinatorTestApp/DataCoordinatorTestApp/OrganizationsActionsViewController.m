//
//  OrganizationsActionsViewController.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "OrganizationsActionsViewController.h"
#import "FSPDataCoordinator.h"
#import "FSPMockDataFetcher.h"
#import "FSPCoreDataManager.h"
#import "FSPOrganization.h"

enum {
    FlushActionsSection = 0,
    OrganizationActionsSection,
    EventActionsSection,
    StandingsSection,
    
    ActionsViewControllerSectionCount
};

enum FlushActionsRows {
    FlushAllOrganizationsIndex = 0
};

enum OrganizationsActionsRows {
    UpdateAllOrganizationsActionIndex = 0,
    UpdateAllOrganizationsAltActionIndex,
    UpdateAllOrganizationsFailActionIndex
};

enum EventActionsRows {
    UpdateNBATeamRow = 0,
    UpdateUnknownOrgRow
};

enum StandingsSectionRows {
    UpdateNBARow = 0
};

@interface OrganizationsActionsViewController ()
@property (nonatomic, strong) UIView *blockingOverlay;
@property (nonatomic, weak) id orgSuccessObserver;
@property (nonatomic, weak) id orgFailObserver;

- (void)showOverlay;
- (void)hideOverlay;

- (void)flushOrgs;
- (void)updateOrgs:(BOOL)alt fail:(BOOL)fail;

- (void)updateScheduleForOrg:(NSInteger)orgID stopAfter:(double)stopTime;
- (void)updateStandingsForOrg:(NSInteger)orgId;

- (void)beginObserving;
- (void)endObserving;
@end

@implementation OrganizationsActionsViewController  {
    BOOL isBlocking;
}
@synthesize orgSuccessObserver;
@synthesize orgFailObserver;
@synthesize blockingOverlay;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc;
{
    [self endObserving];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self beginObserving];
}

- (void)viewDidUnload
{
    [self endObserving];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Observing
- (void)beginObserving;
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    self.orgSuccessObserver = [center addObserverForName:FSPAllOrganizationsUpdatedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"organizations updated notification received");
    }];
    
    self.orgFailObserver = [center addObserverForName:FSPAllOrganizationsFailedToUpdateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"organizations failed to update notification received");
    }];
}

- (void)endObserving;
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self.orgSuccessObserver];
    [center removeObserver:self.orgFailObserver];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case FlushActionsSection:
            switch (indexPath.row) {
                case FlushAllOrganizationsIndex:
                    [self flushOrgs];
                    break;
            }
            break;
        case OrganizationActionsSection:
            switch (indexPath.row) {
                case UpdateAllOrganizationsActionIndex:
                    [self updateOrgs:NO fail:NO];
                    break;
                case UpdateAllOrganizationsAltActionIndex:
                    [self updateOrgs:YES fail:NO];
                    break;
                case UpdateAllOrganizationsFailActionIndex:
                    [self updateOrgs:NO fail:YES];
                    break;
            }
            break;
        case EventActionsSection:
            switch (indexPath.row) {
                case UpdateNBATeamRow:
                    [self updateScheduleForOrg:120 stopAfter:5];
                    break;
                case UpdateUnknownOrgRow:
                    [self updateScheduleForOrg:99999 stopAfter:5];
                    break;
            }
            break;
        case StandingsSection:
            switch (indexPath.row) {
                case UpdateNBARow:
                    [self updateStandingsForOrg:22];
                    break;
            }
    }
}

#pragma mark - Actions
- (void)flushOrgs;
{
    [self showOverlay];
    
    NSString *previousTitle = self.title;
    self.title = @"Flushing All Orgs";
    [[FSPDataCoordinator defaultCoordinator] flushAllOrganizationCallback:^(BOOL success, NSArray *deletedOrgs) {
        NSString *title = success ? @"Deleted all Orgs" : @"Failed to delete orgs";
        NSString *msg = success ? [NSString stringWithFormat:@"Deleted %d organizations", [deletedOrgs count]] : @"Unable to delete organizations from database";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [self hideOverlay];
        [alert show];
        self.title = previousTitle;
    }];
}

- (void)updateOrgs:(BOOL)alt fail:(BOOL)fail;
{
    [self showOverlay];
    NSString *previousTitle = self.title;
    self.title = @"Updating all orgs";
    
    FSPMockDataFetcher *fetcher = [[FSPDataCoordinator defaultCoordinator] fetcher];
    fetcher.useAlternateFiles = alt;
    
    BOOL priorPropertyResponse = fetcher.usePropertyForReturnedOrganizations;
    if (fail) { 
        fetcher.usePropertyForReturnedOrganizations = YES;
        fetcher.organizationsToReturn = nil;
    }
    
    [[FSPDataCoordinator defaultCoordinator] updateAllOrganizationsCallback:^(BOOL success, NSDictionary *userInfo) {
        fetcher.usePropertyForReturnedOrganizations = priorPropertyResponse;
        
        NSString *title = success ? @"Updated all Orgs" : @"Failed to update orgs";
        
        NSSet *updatedOrgs = [userInfo objectForKey:FSPChangedOrganizationsKey];
        NSSet *deletedOrgs = [userInfo objectForKey:FSPDeletedOrganizationsKey];
        NSSet *insertedOrgs = [userInfo objectForKey:FSPInsertedOrganizationsKey];
        
        NSString *successMsg = [NSString stringWithFormat:@"inserted %d, deleted %d, updated %d organizations", insertedOrgs.count, deletedOrgs.count, updatedOrgs.count];
        
        
        NSString *msg = success ? successMsg : @"Unable to update organizations in database";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [self hideOverlay];
        [alert show];
        self.title = previousTitle;
    }];
    
}

- (void)updateScheduleForOrg:(NSInteger)orgID stopAfter:(double)stopTime;
{
    __block NSNumber *org = [NSNumber numberWithInteger:orgID];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        org = [NSNumber numberWithInt:145];
    });
    [[FSPDataCoordinator defaultCoordinator] updateScheduleForOrganizationWithId:org callback:^(BOOL success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Org Updated" message:@"Updated schedule for organization" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)updateStandingsForOrg:(NSInteger)orgId;
{
    [[FSPDataCoordinator defaultCoordinator] updateStandingsForOrganizationWithId:[NSNumber numberWithInteger:orgId] callback:^(BOOL success) {
        NSLog(@"finished updating standings success = %@", success ? @"YES" : @"NO");
    }];
}

#pragma mark - Convenience Methods
- (void)showOverlay;
{
    if (isBlocking)
        return;
    
    if (!self.blockingOverlay) {
        self.blockingOverlay = [[UIView alloc] initWithFrame:self.tableView.bounds];
        self.blockingOverlay.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    }
    
    [self.tableView addSubview:self.blockingOverlay]; 
    [self.tableView setScrollEnabled:NO];
    isBlocking = YES;
}

- (void)hideOverlay;
{
    if (!isBlocking)
        return;
    
    [self.blockingOverlay removeFromSuperview];
    [self.tableView setScrollEnabled:YES];
    isBlocking = NO;
}

@end
