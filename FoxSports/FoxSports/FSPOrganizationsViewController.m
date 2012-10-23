//
//  FSPOrganizationsViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 1/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationsViewController.h"
#import "FSPStandingsViewController.h"
#import "FSPOrganization.h"
#import "FSPTeam.h"
#import "FSPEvent.h"
#import "FSPOrganizationTableViewCell.h"
#import "FSPDataCoordinator.h"
#import "UIImageView+AFNetworking.h"
#import "FSPOrganizationsHeaderView.h"
#import "FSPOrganizationsAddSportsViewController.h"
#import "FSPImageFetcher.h"

#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import "UIFont+FSPExtensions.h"
#import "NSUserDefaults+FSPExtensions.h"

NSString * const FSPOrganizationCellIdentifier = @"FSPOrganizationTableViewCell";
NSString * const FSPOrganizationSpecialCellIdentifier = @"FSPOrganizationTableViewSpecialCell";
NSString * const FSPCellImageDescriptionKey = @"CellImageDescriptionKey";

// comment these out to disable these features
#define FSPPlayNowEnabled
//#define FSPChannelsEnabled

@interface FSPOrganizationsViewController ()
@property (nonatomic, strong) FSPOrganization *currentOrganization;
@property (nonatomic, copy) NSString *defaultBranchString;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *doneButton;  // iPhone only
@property (nonatomic, strong) UIButton *addButton;   // iPhone only
@property (nonatomic, weak) id favoriteStateObserver;
@property id postUpdateScrollTarget;
@property (nonatomic) BOOL isOrganizationCell;

@property (nonatomic, strong) NSFetchedResultsController *organizationsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *favoritesFetchedResultsController;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsToRemoveOnPhone;

- (void)closeVideoModal;
- (void)displayViewController:(UIViewController *)placeholder;

- (void)selectOrganizationAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)updateEditButton;

- (void)beginAddOrganizations;

- (void)showAllVideos;

- (void)toggleFavoriteStatusForOrganization:(FSPOrganization *)organization;

- (FSPOrganization *)organizationAtIndexPath:(NSIndexPath *)indexPath;
@end

typedef enum {
    FSPOrganizationsFavoriteIndexIPhoneMyEvents,
    FSPOrganizationsFavoriteIndexIPhoneFirstFavorite,
} FSPOrganizationsFavoriteIndexIPhone;

typedef enum {
    FSPOrganizationsFavoriteIndexIPadEdit,
    FSPOrganizationsFavoriteIndexIPadMyEvents,
    FSPOrganizationsFavoriteIndexIPadFirstFavorite,
} FSPOrganizationsFavoriteIndexIPad;

@implementation FSPOrganizationsViewController {
    BOOL retrySelectionOnFill_;
}
@synthesize currentOrganization = _currentOrganization;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize delegate = _delegate;
@synthesize defaultBranchString = _defaultBranchString;
@synthesize buttonsToRemoveOnPhone = _buttonsToRemoveOnPhone;
@synthesize favoriteStateObserver;
@synthesize editButton = _editButton;
@synthesize doneButton = _doneButton;
@synthesize addButton = _addButton;
@synthesize favoritesFetchedResultsController = _favoritesFetchedResultsController;
@synthesize organizationsFetchedResultsController = _organizationsFetchedResultsController;

#pragma mark - Custom getters & setters
- (UIButton *)editButton
{
    if (!_editButton) {
        UIImage *backgroundButtonImage = nil;
        CGRect buttonRect = CGRectZero;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            backgroundButtonImage = [UIImage imageNamed:@"button_background_black"];
            CGSize imageSize = backgroundButtonImage.size;
            backgroundButtonImage = [backgroundButtonImage stretchableImageWithLeftCapWidth:imageSize.width/2
                                                                               topCapHeight:imageSize.height/2];
            buttonRect = CGRectMake(8, 5, 5, 5); // size will be reset in -viewForHeaderInSection
        }

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            backgroundButtonImage = [UIImage imageNamed:@"A_Edit_Button"];
            buttonRect = CGRectMake(8, 5, backgroundButtonImage.size.width, backgroundButtonImage.size.height);
        }
        
        _editButton = [[UIButton alloc] initWithFrame:buttonRect];
        [_editButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.editButton.titleEdgeInsets = UIEdgeInsetsMake(4, 8, 0, 0);
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.editButton.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        }
        self.editButton.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
        self.editButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;

        [self updateEditButton];

        [self.editButton addTarget:self action:@selector(enterEditingMode) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _editButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
            return nil;
        }

        UIImage *darkBlueButtonImage = nil;
        darkBlueButtonImage = [UIImage imageNamed:@"button_background_dkblue"];
        CGSize imageSize = darkBlueButtonImage.size;
        darkBlueButtonImage = [darkBlueButtonImage stretchableImageWithLeftCapWidth:imageSize.width/2
                                                                           topCapHeight:imageSize.height/2];
        UIImage *lightBlueButtonImage = nil;
        lightBlueButtonImage = [UIImage imageNamed:@"button_background_ltblue"];
        lightBlueButtonImage = [lightBlueButtonImage stretchableImageWithLeftCapWidth:imageSize.width/2
                                                                         topCapHeight:imageSize.height/2];
        CGRect buttonRect = CGRectMake(8, 5, 5, 5); // size will be reset in -viewForHeaderInSection

        _doneButton = [[UIButton alloc] initWithFrame:buttonRect];
        [_doneButton setBackgroundImage:lightBlueButtonImage forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:darkBlueButtonImage forState:UIControlEventTouchDown];
        _doneButton.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
        _doneButton.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
        _doneButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [_doneButton addTarget:self
                        action:@selector(exitEditingMode)
              forControlEvents:UIControlEventTouchUpInside];

        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
    }

    return _doneButton;
}

- (UIButton *)addButton {
    if (!_addButton) {
        UIImage *backgroundButtonImage = [UIImage imageNamed:@"button_background_black"];
        backgroundButtonImage = [backgroundButtonImage stretchableImageWithLeftCapWidth:backgroundButtonImage.size.width/2
                                                                           topCapHeight:backgroundButtonImage.size.height/2];
        CGRect buttonRect = CGRectMake(0, 0, 30, 30);
        UIImage *plusImage = [UIImage imageNamed:@"plus"];

        _addButton = [[UIButton alloc] initWithFrame:buttonRect];
        [_addButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
        [_addButton setImage:plusImage forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(beginAddOrganizations) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

- (void)setCurrentOrganization:(FSPOrganization *)currentOrganization;
{
    if (_currentOrganization != currentOrganization) {
        _currentOrganization = currentOrganization;
    }
	
	// We want to send this regardless of whether or not this is the current org, because the user could be viewing news / video
	if ([self.delegate respondsToSelector:@selector(organizationsViewController:didSelectNewOrganization:)])
		[self.delegate organizationsViewController:self didSelectNewOrganization:currentOrganization];
}

#pragma mark - Memory manangement
- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.favoriteStateObserver];
}

#pragma mark - View lifecycle

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.favoriteStateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FSPOrganizationDidUpdateFavoritedStateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        FSPOrganization *updatedOrg = (FSPOrganization *)note.object;
        [self toggleFavoriteStatusForOrganization:updatedOrg];
        [self updateEditButton];
    }];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Remove the buttons that we don't want on the phone for now.
        for (UIButton *button in self.buttonsToRemoveOnPhone) {
            [button removeFromSuperview];
        }
    }
    
    self.tableView.accessibilityLabel = NSLocalizedString(@"organization list", nil);
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"channel-cell-background-pattern"]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidUnload;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.favoriteStateObserver];
    [self setButtonsToRemoveOnPhone:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate.rootViewController exitCustomizationModeAnimated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSFetchedResultsController *)organizationsFetchedResultsController {
    if (!_organizationsFetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorited == 0) AND (type != %@) AND (parents.@count == 0)", FSPOrganizationTeamType];
        NSSortDescriptor *ordinalSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ordinal"
                                                                                ascending:YES];
        fetchRequest.sortDescriptors = @[ordinalSortDescriptor];
        
        _organizationsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     managedObjectContext:self.managedObjectContext
                                                                                       sectionNameKeyPath:nil
                                                                                                cacheName:nil];
        _organizationsFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_organizationsFetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _organizationsFetchedResultsController = nil;
        }
    }
    return _organizationsFetchedResultsController;
}

- (NSFetchedResultsController *)favoritesFetchedResultsController {
    if (!_favoritesFetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];

        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorited == 1)", FSPOrganizationTeamType];
        NSSortDescriptor *ordinalSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ordinal"
                                                                                ascending:YES];
        NSSortDescriptor *userSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userDefinedOrder"
                                                                             ascending:YES];
        fetchRequest.sortDescriptors = @[userSortDescriptor,
                                        ordinalSortDescriptor];

        _favoritesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:self.managedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];
        _favoritesFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_favoritesFetchedResultsController performFetch:&error]) {
            NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
            _favoritesFetchedResultsController = nil;
        }
    }
    return _favoritesFetchedResultsController;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Resize the tableView width so that the Delete buttons don't extend to the right under the Column B
        // view controller. The tableView frame is reset by the view controller elsewhere; TODO: this is a hack.
        // Figure out the correct way to do this
        self.tableView.frame = CGRectMake(CGRectGetMinX(self.tableView.frame),
                                          CGRectGetMinY(self.tableView.frame),
                                          CGRectGetWidth(UIScreen.mainScreen.bounds) - 44,
                                          CGRectGetHeight(self.tableView.frame));
    }

	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)enterEditingMode;
{
	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate.rootViewController enterCustomizationModeAnimated:YES];
    [self updateEditButton];
}

- (void)exitEditingMode {
	FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate.rootViewController exitCustomizationModeAnimated:YES];
    [self updateEditButton];
}

- (void)beginAddOrganizations {
    NSString *vcClassName = NSStringFromClass(FSPOrganizationsAddSportsViewController.class);
    FSPOrganizationsAddSportsViewController *addSportsViewController;
    addSportsViewController = [[FSPOrganizationsAddSportsViewController alloc] initWithNibName:vcClassName
                                                                                        bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addSportsViewController];
    navController.view.backgroundColor = [UIColor whiteColor];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - Table View Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    NSInteger sections = FSPOrganizationViewControllerSectionCount;
#ifndef FSPChannelsEnabled
        sections--;
#endif
        return sections;
}

- (NSInteger)rowsInFavoritesSection;
{
    NSInteger rows = 0;

    if (!self.tableView.isEditing) {
        // On iPad, there's a row in the favorites section dedicated to the edit button. On iPhone,
        // the edit button is a subview of the section header view.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            rows++;
        }

        // Include the "all my events" cell
        if (self.favoritesFetchedResultsController.fetchedObjects.count > 0 && !self.tableView.isEditing) {
            rows++;
        }
    }
    
    // add any favorites
    rows += self.favoritesFetchedResultsController.fetchedObjects.count; 

    return rows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	switch (section) {
		case FSPOrganizationsPersistentCellsSection: {
			NSInteger rows = FSPOrganizationsPersistentCellsRowCount;
			
#ifndef FSPPlayNowEnabled
			rows--;
#endif
		
			return tableView.isEditing ? 0 : rows;
		}
		case FSPOrganizationFavoritesSection: {
            return [self rowsInFavoritesSection];
		}
		case FSPOrganizationAllSection: {
			return tableView.isEditing ? 0 : [self.organizationsFetchedResultsController.fetchedObjects count];
		}
		default: {
			return 0;
		}
	}
}

- (FSPOrganizationTableViewCell *)organizationCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    FSPOrganizationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[FSPOrganizationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.textColor = [UIColor colorWithWhite:170/256.0 alpha:1.0];
        }
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (!self.tableView.isEditing && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        // edit button cell
        if (indexPath.section == FSPOrganizationFavoritesSection && indexPath.row == 0) {
            static NSString *editIdentifier = @"FSPChannelsEditCellIdentifier";
            FSPOrganizationTableViewCell *cell = [[FSPOrganizationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editIdentifier];

            // This only happens on iPad; on iPhone, this section doesn't have a row for the button.
            [cell.contentView addSubview:self.editButton];
            return cell;
        }
	}
    
    FSPOrganizationTableViewCell *cell = nil;
    
    if (!self.tableView.isEditing) {
        
        // persistent cells
        if (indexPath.section == FSPOrganizationsPersistentCellsSection) {
            NSInteger row = indexPath.row;
#ifndef FSPPlayNowEnabled
            row++;
#endif

            cell = [self organizationCellWithReuseIdentifier:FSPOrganizationSpecialCellIdentifier];
            switch (row) {
                case FSPOrganizationsPersistentCellsVideoRow:
                    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
                        cell.imageView.image = [UIImage imageNamed:@"A_play"];
                        cell.textLabel.text = @"Live Events";
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"live_events"];
                    }
					cell.accessibilityLabel = @"watch now";	
                    break;
                    
                case FSPOrganizationsPersistentCellsNewsRow:
                    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
                        cell.imageView.image = [UIImage imageNamed:@"A_News"];  
                        cell.textLabel.text = @"Sports News";
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"sports_news"];
                    }
					cell.accessibilityLabel = @"sports news";	
                    break;
            }
            return cell;
        } 
        
        // all my events cell
        if (indexPath.section == FSPOrganizationFavoritesSection) {
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
                (indexPath.row == FSPOrganizationsFavoriteIndexIPhoneMyEvents)) {
                cell = [self organizationCellWithReuseIdentifier:FSPOrganizationSpecialCellIdentifier];
                cell.imageView.image = [UIImage imageNamed:@"A_calendar"];
                cell.textLabel.text = @"All My Events";
                cell.accessibilityLabel = @"all my events";
                return cell;
            }

            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) &&
                (indexPath.row == FSPOrganizationsFavoriteIndexIPadMyEvents)) {
                cell = [self organizationCellWithReuseIdentifier:FSPOrganizationSpecialCellIdentifier];
                cell.imageView.image = [UIImage imageNamed:@"All_my_events"];
                cell.accessibilityLabel = @"all my events";
                return cell;
            }
        } 
    }
    
    cell = [self organizationCellWithReuseIdentifier:FSPOrganizationCellIdentifier];
    cell.textLabel.text = nil;
	cell.showsLabel = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) || (self.tableView.isEditing));
        
    // organization cells
    FSPOrganization *org = [self organizationAtIndexPath:indexPath];
    
    // cell.imageView.image = nil;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([org isKindOfClass:[FSPTeam class]]) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (self.tableView.isEditing) {
                cell.textLabel.text = [(FSPTeam *)org longNameDisplayString];
            }
            else {
                cell.textLabel.text = [(FSPTeam *)org shortNameDisplayString];
            }
        }
        else {
            cell.textLabel.text = [(FSPTeam *)org shortNameDisplayString];
        }
        
    }
    else {
        cell.textLabel.text = org.name;
    }
    //NSString *orgName = org.name;

	cell.accessibilityLabel = org.name;
    
    if (!cell.imageView.image) {
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:org.logo1URL]
                                           withCallback:^(UIImage *image) {
                                               
                                               cell.imageView.image = image;
                                               [cell setNeedsLayout];
                                               
                                           }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Deselect all other cells
    for (UITableViewCell *cell in [tableView visibleCells]) {
        [cell setSelected:NO];
    }
    
    BOOL selectOrganization = NO;
	
    [[NSUserDefaults standardUserDefaults] fsp_setIndexPath:indexPath forKey:@"lastSelectedOrganization"];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lastSelectedEvent"];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[NSUserDefaults standardUserDefaults] setObject:cell.imageView.image.description forKey:FSPCellImageDescriptionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
    if (indexPath.section == FSPOrganizationsPersistentCellsSection) {
		NSInteger row = indexPath.row;
		
#ifndef FSPPlayNowEnabled
		row++;
#endif
		switch (row) {
			case FSPOrganizationsPersistentCellsVideoRow: {
				// Present video modal
				[self showAllVideos];
				// do not actually switch what we have selected
				if (self.currentOrganization) {
					NSUInteger currentIndex = [self.organizationsFetchedResultsController.fetchedObjects indexOfObject:self.currentOrganization];
					NSUInteger section = FSPOrganizationAllSection;
					if (currentIndex == NSNotFound) {
						currentIndex = [self.favoritesFetchedResultsController.fetchedObjects indexOfObject:self.currentOrganization];
						section = FSPOrganizationFavoritesSection;
					}
					NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:section];
					[self.tableView selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
				}
				break;
			}
				
			case FSPOrganizationsPersistentCellsNewsRow: {
				if ([self.delegate respondsToSelector:@selector(organizationsViewControllerDidSelectSportsNews:)])
					[self.delegate organizationsViewControllerDidSelectSportsNews:self];
				break;
			}
		}
    } else if (indexPath.section == FSPOrganizationFavoritesSection) {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && (indexPath.row == FSPOrganizationsFavoriteIndexIPadEdit)) {
            [self enterEditingMode];
        } else if (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && (indexPath.row == FSPOrganizationsFavoriteIndexIPadMyEvents)) ||
                   ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (indexPath.row == FSPOrganizationsFavoriteIndexIPhoneMyEvents))) {
            if ([self.delegate respondsToSelector:@selector(organizationsViewControllerDidSelectAllMyEvents:)])
                [self.delegate organizationsViewControllerDidSelectAllMyEvents:self];
        } else {
            selectOrganization = YES;
        }
	} else {
        selectOrganization = YES;
    }

    // select the organization
    if (selectOrganization) {
        FSPOrganization *selectedOrg = [self organizationAtIndexPath:indexPath];
        self.currentOrganization = selectedOrg;
        self.isOrganizationCell = YES;
    }

    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOrganizationCell) {
        FSPOrganization *organization = [self organizationAtIndexPath:indexPath];
        if (organization && [organization.objectID isEqual:self.currentOrganization.objectID]) {
            [cell setSelected:YES];
            return;
        }
    }
    
    if ([cell.imageView.image.description isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:FSPCellImageDescriptionKey]]) {
        [cell setSelected:YES];
        self.isOrganizationCell = NO;
        return;
    }
    
    [cell setSelected:NO];
}

#define IPHONE_CELL_HEIGHT (38.0)
#define IPAD_PERSISTENT_CELL_HEIGHT (54.0)
#define IPAD_EDIT_ROW_CELL_HEIGHT (38.0)
#define IPAD_ORGANIZATION_CELL_HEIGHT (88.0)
#define HEADER_HEIGHT_IPAD (22.0)
#define HEADER_HEIGHT_IPHONE (38.0)

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    CGFloat platformHeaderHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
                                    HEADER_HEIGHT_IPAD : HEADER_HEIGHT_IPHONE);
    switch (section) {
        case FSPOrganizationFavoritesSection:
            return platformHeaderHeight;
        case FSPOrganizationsPersistentCellsSection:
            return 0.0f;
        default:
            return platformHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        return IPAD_ORGANIZATION_CELL_HEIGHT;
    }
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return IPHONE_CELL_HEIGHT;
	}
    
    if (indexPath.section == FSPOrganizationsPersistentCellsSection) {
		return IPAD_PERSISTENT_CELL_HEIGHT;
	} else {
		if (indexPath.section == FSPOrganizationFavoritesSection) {
			switch (indexPath.row) {
				case 0: {
					return IPAD_EDIT_ROW_CELL_HEIGHT;
				}
				case 1: {
					return IPAD_PERSISTENT_CELL_HEIGHT;
				}
			}
		}
	}
	return IPAD_ORGANIZATION_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (section == FSPOrganizationsPersistentCellsSection) {
        return nil;
	} else {
        FSPOrganizationsHeaderView *headerView = nil;
        
        if ((section == FSPOrganizationFavoritesSection) ||
            !tableView.isEditing) {
            headerView = [[FSPOrganizationsHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, [self tableView:tableView heightForHeaderInSection:section])];
            
            [headerView selectHeaderForSection:section];
            
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
                (section == FSPOrganizationFavoritesSection)) {
                self.editButton.frame = CGRectMake(218, 4, 50, 30);
                [headerView addSubview:self.editButton];
                self.doneButton.frame = CGRectMake(218, 4, 50, 30);
                [headerView addSubview:self.doneButton];
                self.addButton.frame = CGRectMake(6, 4, 30, 30);
                if (self.tableView.isEditing) {
                    [headerView addSubview:self.addButton];
					headerView.star.hidden = YES;
                } else {
					headerView.star.hidden = NO;
				}
            }
        } else {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }

        return headerView;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.tableView.isEditing) {
        return YES;
    }
    
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && self.tableView.isEditing) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    FSPOrganization *org = [self organizationAtIndexPath:indexPath];
    [org updateFavoriteState:NO];
    [self toggleFavoriteStatusForOrganization:org];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (self.tableView.isEditing) {
        return YES;
    }
    
    if (indexPath.section == FSPOrganizationFavoritesSection && (indexPath.row > 1)) {
			return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
{
    FSPOrganization *orgToMove = [self organizationAtIndexPath:sourceIndexPath];
    NSMutableArray *favorites = [NSMutableArray arrayWithArray:self.favoritesFetchedResultsController.fetchedObjects];
    [favorites removeObjectAtIndex:sourceIndexPath.row];
    [favorites insertObject:orgToMove atIndex:destinationIndexPath.row];

    // Reset the userDefinedOrder on all the orgs
    [favorites enumerateObjectsUsingBlock:^(FSPOrganization *org, NSUInteger userDefinedOrder, BOOL *stop) {
        org.userDefinedOrder = @(userDefinedOrder);
    }];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error on updating user defined favorite order: %@", [error description]);
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;               
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [self tableView:tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
    }
    
    return proposedDestinationIndexPath;
}

- (void)updateEditButton;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.favoritesFetchedResultsController.fetchedObjects.count) {
            self.editButton.titleLabel.numberOfLines = 1;
            [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        } else {
            self.editButton.titleLabel.numberOfLines = 2;
            [self.editButton setTitle:@"Setup" forState:UIControlStateNormal];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.favoritesFetchedResultsController.fetchedObjects.count) {
			[self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
		} else {
			[self.editButton setTitle:@"Setup" forState:UIControlStateNormal];
		}

        if (self.tableView.isEditing) {
            self.editButton.hidden = YES;
            self.doneButton.hidden = NO;
        } else {
            self.editButton.hidden = NO;
            self.doneButton.hidden = YES;
            [self.addButton removeFromSuperview];
        }
    }
}

- (FSPOrganization *)organizationAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (self.tableView.isEditing) {
        if ((NSUInteger)indexPath.row < self.favoritesFetchedResultsController.fetchedObjects.count) {
            return [self.favoritesFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        } else {
            return nil;
        }
    }

    if (indexPath.section == FSPOrganizationFavoritesSection) {
        // On iPad: if we have favorites then there are 2 extra cells, the edit button and the "All My Events", so remove 2 from the row count.
        // On iPhone: there's an "All My Events" cell; the edit button is a subview of the section header view.
        NSInteger firstFavoriteCell = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
                                       FSPOrganizationsFavoriteIndexIPadFirstFavorite : FSPOrganizationsFavoriteIndexIPhoneFirstFavorite);
        NSUInteger orgIndex = (NSUInteger)(indexPath.row - firstFavoriteCell);
        if (orgIndex < self.favoritesFetchedResultsController.fetchedObjects.count) {
            return [self.favoritesFetchedResultsController.fetchedObjects objectAtIndex:orgIndex];
        } else {
            return nil;
        }
    } else if (indexPath.section == FSPOrganizationAllSection) {
        return [self.organizationsFetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    }
    
    return nil;
}

- (void)setInCustomizationMode:(BOOL)customizationMode animated:(BOOL)animated;
{
    [self.tableView setEditing:customizationMode animated:animated];
    [self.tableView reloadData];
    
    // Switch the edit/done buttons on iPhone.
    [self updateEditButton];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)toggleFavoriteStatusForOrganization:(FSPOrganization *)updatedOrg;
{
	// clear out the "delete" button if one is showing. seems there should be a better way...
	for (UITableViewCell *cell in self.tableView.visibleCells) {
		if (cell.showingDeleteConfirmation) {
			cell.editing = NO;
			cell.editingAccessoryView = nil;
			cell.editing = YES;
		}
	}
	
    BOOL addOrganizationToFavorites = [updatedOrg.favorited boolValue];
    
    // don't add an organization to the favorite list if it's already added
    if (addOrganizationToFavorites && [self.favoritesFetchedResultsController.fetchedObjects containsObject:updatedOrg]) {
        return;
    }
    
    if (addOrganizationToFavorites) {
        // add object to favorites
        
        NSInteger allSportsIndex = [self.organizationsFetchedResultsController.fetchedObjects indexOfObject:updatedOrg];
        if (allSportsIndex != NSNotFound) {
            [updatedOrg updateFavoriteState:YES];
        }
        
        
        NSInteger favoriteCount = self.favoritesFetchedResultsController.fetchedObjects.count;
        updatedOrg.userDefinedOrder = @(favoriteCount);
    } else {
        // remove object from favorites
        [updatedOrg updateFavoriteState:NO];
        
        NSInteger favoritesIndex = [self.favoritesFetchedResultsController.fetchedObjects indexOfObject:updatedOrg];
        if (favoritesIndex == NSNotFound)
            return;
    }

    if (addOrganizationToFavorites) {
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
//                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Row Selection
- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch;
{
    [self selectFirstOrganizationMatchingBranchName:branch animated:NO retryOnReload:NO];
}

- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch animated:(BOOL)animated;
{
    [self selectFirstOrganizationMatchingBranchName:branch animated:animated retryOnReload:NO];
}

- (void)selectFirstOrganizationMatchingBranchName:(NSString *)branch animated:(BOOL)animated retryOnReload:(BOOL)retry;
{
    NSUInteger index = NSNotFound;
    NSInteger section;
    if (self.favoritesFetchedResultsController.fetchedObjects.count) {
        index = [self.favoritesFetchedResultsController.fetchedObjects indexOfObjectPassingTest:^BOOL(FSPOrganization *organization, NSUInteger idx, BOOL *stop) {
            BOOL found = NO;
            if ([organization.branch isEqualToString:branch]) {
                *stop = YES;
                found = YES;
            }
            return found;
        }];
		
        if (index != NSNotFound) {
            section = FSPOrganizationFavoritesSection;
		}
    }
    
    if (index == NSNotFound && self.organizationsFetchedResultsController.fetchedObjects.count) {
        // check the other array
        index = [self.organizationsFetchedResultsController.fetchedObjects indexOfObjectPassingTest:^BOOL(FSPOrganization *organization, NSUInteger idx, BOOL *stop) {
            BOOL found = NO;
            if ([organization.branch isEqualToString:branch]) {
                *stop = YES;
                found = YES;
            }
            return found;
        }];
        if (index != NSNotFound)
            section = FSPOrganizationAllSection;
    }
    
    if (index != NSNotFound) {
        // We found an org
        [self selectOrganizationAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section] animated:animated];
    } else {
        retrySelectionOnFill_ = retry;
        self.defaultBranchString = retry ? branch : nil;
    }
}

- (void)selectOrganizationAtIndexPath:(NSIndexPath *)indexPath;
{
    [self selectOrganizationAtIndexPath:indexPath animated:NO];
}

- (void)selectOrganizationAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
{
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionTop];
    
    self.currentOrganization = [self organizationAtIndexPath:indexPath];
}

- (void)showAllVideos;
{

}

- (void)displayViewController:(UIViewController *)placeholder;
{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeVideoModal)];
    placeholder.navigationItem.leftBarButtonItem = barItem;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:placeholder];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

//TODO: Remove after NBA schedule has a home
- (void)closeVideoModal;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller;
{
    [self.tableView reloadData];
    if (controller == self.favoritesFetchedResultsController) {
        
        if (self.postUpdateScrollTarget)
        {
            [self.tableView scrollToRowAtIndexPath:self.postUpdateScrollTarget atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        self.postUpdateScrollTarget = nil;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (controller == self.organizationsFetchedResultsController) {
        return;
    }

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            self.postUpdateScrollTarget = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
            break;
        default:
            break;
    }
}

@end
