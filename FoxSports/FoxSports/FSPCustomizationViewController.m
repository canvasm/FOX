//
//  FSPCustomizationViewController.m
//  FoxSports
//
//  Created by Chase Latta on 4/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPCustomizationViewController.h"
#import "FSPCustomizationView.h"
#import "UIFont+FSPExtensions.h"
#import "FSPOrganization.h"
#import "FSPOrganizationCustomizationViewController.h"

static CGFloat EdgeInset = 40.0;

@interface FSPCustomizationViewController () <FSPCustomizationViewDelegate>
@property (nonatomic, strong, readonly) NSArray *topLevelOrganizations;
@property (nonatomic, strong) UIPopoverController *orgPopover;

- (void)presentPopoverControllerFromCustomizationView:(FSPCustomizationView *)customizationView showingTeams:(BOOL)yesNo;

@end

@implementation FSPCustomizationViewController {
    NSUInteger numberOfRows;
}
@synthesize managedObjectContext;
@synthesize topLevelOrganizations = _topLevelOrganizations;
@synthesize orgPopover;

- (NSArray *)topLevelOrganizations;
{
    if (_topLevelOrganizations)
        return _topLevelOrganizations;
    
    // Fetch the orgs who don't have a parent
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
    fetch.includesSubentities = NO; // exclude teams
    fetch.predicate = [NSPredicate predicateWithFormat:@"parents.@count == 0"];
    
    NSSortDescriptor *ordinalSort = [NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES];
    fetch.sortDescriptors = @[ordinalSort];
    
    _topLevelOrganizations = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    return _topLevelOrganizations;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView;
{
    UIImageView *mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 704, 748)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainView.image = [UIImage imageNamed:@"bckrnd"];
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:containerScrollView];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(EdgeInset, 40.0, CGRectGetWidth(self.view.bounds) - EdgeInset, 25.0)];
    topLabel.textColor = [UIColor whiteColor];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:20.0];
    topLabel.text = @"Which sports and teams are you interested in?";
    [containerScrollView addSubview:topLabel];
    
    CGFloat customizationViewStartY = CGRectGetMaxY(topLabel.frame) + 45.0;
    
    // Place all of the cells in the scroll view
    NSUInteger cellCount = self.topLevelOrganizations.count;
    numberOfRows = cellCount / 2;
    if (cellCount % 2 != 0)
        numberOfRows += 1;
    
    // Place all of our left column views
    CGRect customizationFrame = CGRectZero;
    customizationFrame.size = [FSPCustomizationView preferedSize];
    customizationFrame.origin.x = EdgeInset;
    customizationFrame.origin.y = customizationViewStartY;
    
    CGFloat yIncrement = customizationFrame.size.height + 20.0;
    for (NSUInteger index = 0; index < numberOfRows; index++) {
        FSPCustomizationView *customizationView = [FSPCustomizationView customizationViewWithFrame:customizationFrame organization:[self.topLevelOrganizations objectAtIndex:index]];
        [containerScrollView addSubview:customizationView];
        customizationView.delegate = self;
        customizationFrame.origin.y += yIncrement;
    }
    
    // We set the scroll view size after we place the first column of views because it makes it easier to get the height.
    CGSize customizationSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(customizationFrame) + 20.0);
    containerScrollView.contentSize = customizationSize;
    
    // Place the right column
    customizationFrame.origin.y = customizationViewStartY;
    customizationFrame.origin.x = CGRectGetMaxX(customizationFrame) + EdgeInset;
    for (NSUInteger index = numberOfRows; index < cellCount; index++) {
        FSPCustomizationView *customizationView = [FSPCustomizationView customizationViewWithFrame:customizationFrame organization:[self.topLevelOrganizations objectAtIndex:index]];
        [containerScrollView addSubview:customizationView];
        customizationView.delegate = self;
        customizationFrame.origin.y += yIncrement;
    }
}

- (void)viewDidUnload
{
    self.orgPopover = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Customization Delegate
- (void)customizationViewWantsToShowSubOrganizations:(FSPCustomizationView *)customizationView;
{
    [self presentPopoverControllerFromCustomizationView:customizationView showingTeams:NO];
}

- (void)customizationViewWantsToShowTeams:(FSPCustomizationView *)customizationView;
{
    [self presentPopoverControllerFromCustomizationView:customizationView showingTeams:YES];
}

- (void)presentPopoverControllerFromCustomizationView:(FSPCustomizationView *)customizationView showingTeams:(BOOL)yesNo;
{
    FSPOrganizationCustomizationViewController *viewController = [[FSPOrganizationCustomizationViewController alloc] initWithOrganization:customizationView.organization isShowingTeams:yesNo];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (!self.orgPopover) {
        self.orgPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    } else {
        self.orgPopover.contentViewController = navController;
    }
    
    NSUInteger index = [self.topLevelOrganizations indexOfObject:customizationView.organization];
    UIPopoverArrowDirection direction;
    if (index < numberOfRows)
        direction = UIPopoverArrowDirectionLeft;
    else 
        direction = UIPopoverArrowDirectionRight;
    
    CGRect presentationRect = [customizationView convertRect:customizationView.bounds toView:self.view];
    [self.orgPopover presentPopoverFromRect:presentationRect inView:self.view permittedArrowDirections:direction animated:YES];
}
@end
