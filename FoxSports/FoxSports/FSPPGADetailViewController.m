//
//  FSPPGADetailViewController.m
//  FoxSports
//
//  Created by Chase Latta on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGADetailViewController.h"
#import "FSPPGAPreviewViewController.h"
#import "FSPPGAEvent.h"
#import "FSPSegmentedNavigationControl.h"
#import "FSPPGALeaderboardViewController.h"
#import "FSPGameHeaderView.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"


@interface FSPPGADetailViewController ()
@property (nonatomic, weak) IBOutlet UIView *headerViewContainer;
@property (nonatomic, readonly) FSPPGAEvent *PGAEvent;
@property (weak, nonatomic) IBOutlet FSPSegmentedNavigationControl *navigationView;
@property (nonatomic, strong, readonly) NSArray *extendedInformationViewControllers;
@property (weak, nonatomic) IBOutlet UIView *lowerContainerView;
@property (nonatomic, strong) FSPPGAPreviewViewController *previewViewController;
@property (nonatomic, strong) FSPPGALeaderboardViewController *leaderboardViewController;

- (void)changeExtendedInformation:(id)sender;
@end

@implementation FSPPGADetailViewController

- (FSPLeaderboardViewController *)leaderboardViewController
{
    if (!_leaderboardViewController) {
        _leaderboardViewController = [[FSPPGALeaderboardViewController alloc] initWithEvent:self.event];
        _leaderboardViewController.view.frame = self.view.frame;
    }
    return _leaderboardViewController;
}

- (Class)preEventViewControllerClass
{
	return [FSPPGAPreviewViewController class];
}

- (FSPPGAEvent *)PGAEvent;
{
    return (FSPPGAEvent *)[self event];
}


#pragma mark - Memory Management
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self styleHeaderView];
}

- (void)viewDidUnload
{
    self.headerViewContainer = nil;
    [self setLowerContainerView:nil];
    [super viewDidUnload];
}

#pragma mark - Contained view controller management
- (void)changeExtendedInformation:(id)sender;
{
    NSInteger newIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    [self selectExtendedViewAtIndex:newIndex];
}


#pragma mark - Overrides
- (void)eventDidUpdate;
{
    [super eventDidUpdate];
    [self updateHeaderView];
}

- (void)eventDidChange;
{
    [super eventDidChange];
    self.leaderboardViewController.currentEvent = self.event;
    [self updateHeaderView];
    [self.leaderboardViewController fetchData];
}

- (BOOL)recapIsPreview
{
    return YES;
}

- (NSDictionary *)updatedExtendedInformationDictionary
{
    NSDictionary *baseExtendedInformation = [super updatedExtendedInformationDictionary];
    
    if (![self.event.eventStarted boolValue]) {
        self.leaderboardViewController.view.hidden = YES;
        return baseExtendedInformation;
    }
    
    self.leaderboardViewController.view.hidden = NO;
    
    NSArray *baseExtendedTitles = [baseExtendedInformation objectForKey:FSPExtendedInformationTitlesKey];
    NSArray *baseExtendedViewControllers = [baseExtendedInformation objectForKey:FSPExtendedInformationViewControllersKey];
    
    NSArray *additionalTitles = [self.event.eventCompleted boolValue] ? @[@"Results"] : @[@"Leaderboard"];
    NSArray *additionalViewControllers = @[ self.leaderboardViewController ];
    NSArray *extendedTitles = [baseExtendedTitles arrayByAddingObjectsFromArray:additionalTitles];
    NSArray *extendedViewControllers = [baseExtendedViewControllers arrayByAddingObjectsFromArray:additionalViewControllers];
    
    return @{ FSPExtendedInformationViewControllersKey : extendedViewControllers, FSPExtendedInformationTitlesKey: extendedTitles };
}

#pragma mark - Instance Methods

- (void)updateHeaderView;
{
    self.gameHeaderView.eventLocation.text = [self.event valueForKey:@"location"];
    self.gameHeaderView.eventTitle.text = [self.event valueForKey:@"eventTitle"];
}

- (void)styleHeaderView
{
    self.gameHeaderView.homeScoreLabel.hidden = YES;
    self.gameHeaderView.awayScoreLabel.hidden = YES;
    
    self.gameHeaderView.homeColor = [UIColor fsp_colorWithIntegralRed:0 green:73 blue:158 alpha:1];
    self.gameHeaderView.awayColor = [UIColor fsp_colorWithIntegralRed:0 green:73 blue:158 alpha:1];
    self.gameHeaderView.middleColor = [UIColor fsp_colorWithIntegralRed:50 green:132 blue:225 alpha:1];
    
    self.gameHeaderView.eventTitle.hidden = NO;
    self.gameHeaderView.eventTitle.textColor = [UIColor whiteColor];
    self.gameHeaderView.eventTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.gameHeaderView.eventTitle.shadowOffset = CGSizeMake(0, -1);
    
    self.gameHeaderView.eventLocation.hidden = NO;
    self.gameHeaderView.eventLocation.textColor = [UIColor fsp_colorWithIntegralRed:197 green:224 blue:255 alpha:1];
    self.gameHeaderView.eventLocation.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.gameHeaderView.eventLocation.shadowOffset = CGSizeMake(0, -1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.gameHeaderView.eventLocation.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        self.gameHeaderView.eventOrganizationName.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        self.gameHeaderView.eventTitle.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:22];
    } else {
        self.gameHeaderView.eventLocation.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12];
        self.gameHeaderView.eventOrganizationName.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12];
        self.gameHeaderView.eventTitle.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:20];
    }
}

@end
