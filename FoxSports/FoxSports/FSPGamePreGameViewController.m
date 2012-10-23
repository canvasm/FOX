//
//  FSPNBAPreGameViewController.m
//  FoxSports
//
//  Created by Jason Whitford on 1/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGamePreGameViewController.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "FSPGameDetailTeamHeader.h"
#import "FSPGameOdds.h"
#import "FSPStoryViewController.h"
#import "FSPGameMatchupView.h"
#import "FSPNBAMatchupView.h"
#import "FSPMLBPitcherVsPitcherMatchupView.h"
#import "FSPNFLMatchupView.h"
#import "FSPSoccerMatchupView.h"
#import "FSPHockeyMatchupView.h"
#import "FSPGameOddsView.h"
#import "FSPInjuryReportContainer.h"
#import "FSPEventDetailSectionManaging.h"
#import "UILabel+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPGameDetailSectionHeader.h"

static NSString * const FSPNoDataString = @"--";

@interface FSPGamePreGameViewController ()
@property(nonatomic, strong) NSArray *homeTeamInjuries;
@property(nonatomic, strong) NSArray *awayTeamInjuries;

@property (nonatomic, weak) IBOutlet FSPGameDetailSectionHeader *injuryReportSectionHeader;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIView *matchupContainer;
@property (nonatomic, strong) FSPGameMatchupView *matchupView;

@property (nonatomic, weak) IBOutlet UIView *oddsContainer;
@property (nonatomic, strong) FSPGameOddsView *oddsView;

@property (nonatomic, weak) IBOutlet FSPInjuryReportContainer *injuryReportContainer;

@property (nonatomic, weak) IBOutlet UIView *storyContainer;
@property (nonatomic, weak) IBOutlet UIView *storyHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *noStoryLabel;
@property (nonatomic, strong) FSPStoryViewController *storyViewController;

@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

/**
 * Sections that should collapse when they have insufficient data.
 */
@property (nonatomic, strong) IBOutletCollection(UIView<FSPGamePregameSectionManaging>) NSArray *collapsibleSections;

/**
 * Updates subviews of matchup view with details from the current event; adds the matchup view if needed
 */
- (void)updateMatchupView;
- (void)updateInjuryReportView;
- (void)updateStoryView;

- (void)updateViewPositions;

/**
 * Sets event-specific text on odds labels
 */
- (void)updateOddsView;

@end

@implementation FSPGamePreGameViewController {
    CGRect storyViewCachedFrame;
}

@synthesize injuryReportSectionHeader;
@synthesize injuryReportContainer;
@synthesize oddsContainer;
@synthesize oddsView;
@synthesize matchupContainer;
@synthesize matchupView = _matchupView;
@synthesize storyContainer;
@synthesize storyHeaderLabel;
@synthesize noStoryLabel;
@synthesize storyViewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize collapsibleSections = _collapsibleSections;


@synthesize homeTeamInjuries, awayTeamInjuries;

- (UIScrollView *)scrollView;
{
    return (UIScrollView *)self.view;
}


- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
        [self updateForEvent];
    }
}

- (void)updateForEvent;
{
    if (!self.isViewLoaded || !self.currentEvent) {
        return;
    }
        
    [self updateOddsView];
    [self updateStoryView];
    [self updateMatchupView];
    [self updateInjuryReportView];
    [self updateViewPositions];

    [self.scrollView scrollRectToVisible:matchupContainer.frame animated:NO];
    
    //Fetch injury report information
    [self.dataCoordinator updateInjuryReportForEvent:self.currentEvent.objectID];
    [self.dataCoordinator updatePitchingMatchupForMLBGame:self.currentEvent.objectID];
}

- (void)updateInjuryReportView;
{
	if (![self.currentEvent isKindOfClass:[FSPGame class]]) {
		return;
	}

    [self.injuryReportContainer injuryReportDidChangeContent];
    [self.injuryReportContainer updateInterfaceWithGame:(FSPGame *)self.currentEvent];
    [self updateViewPositions];
}

- (void)updateOddsView;
{
	if (![self.currentEvent isKindOfClass:[FSPGame class]]) {
		return;
	}

	if (!self.oddsView) {
		self.oddsView = [[FSPGameOddsView alloc] init];
		[self.oddsContainer addSubview:self.oddsView];
	}
	
	[self.oddsView updateInterfaceWithGame:(FSPGame *)self.currentEvent];
}

- (void)showNoStoryState;
{
    self.noStoryLabel.hidden = NO;
    self.storyViewController.view.hidden = YES;
    
    if (!CGRectIsNull(storyViewCachedFrame)) {
        CGRect frame = self.storyContainer.frame;
        frame.size = storyViewCachedFrame.size;
        self.storyContainer.frame = frame;
    }
}

- (void)updateStoryView;
{
    
    FSPStoryType storyType;
    if (self.currentEvent.eventCompleted.boolValue) {
        storyType = FSPStoryTypeRecap;
    } else {
        storyType = FSPStoryTypePreview;
    }
    
    [self.dataCoordinator asynchronouslyLoadNewsStoryForEvent:self.currentEvent.objectID storyType:storyType success:^(FSPNewsStory *story) {
        
        if ([story.fullText length] > 0) {
            // we have a valid story
            if (!self.storyViewController) {
                // Create a story
                self.storyViewController = [[FSPStoryViewController alloc] initWithStoryType:FSPStoryTypePreview];
				self.storyViewController.delegate = self;
                storyViewCachedFrame = self.storyContainer.frame;
                [self.storyContainer addSubview:self.storyViewController.view];
            }
            self.noStoryLabel.hidden = YES;
            self.storyViewController.view.hidden = NO;
            self.storyViewController.scrollEnabled = NO;
            
            self.storyViewController.view.frame = self.storyContainer.bounds;
            
            self.storyViewController.story = story;
        } else {
            [self showNoStoryState];
        }
        [self updateViewPositions];
        
    } failure:^(NSError *error) {
        [self showNoStoryState];
        NSLog(@"Error fetching story for event %@ :%@", self.currentEvent.branch, error);
    }];
    
}

- (void)updateMatchupView;
{
	if (![self.currentEvent isKindOfClass:[FSPGame class]]) {
		return;
	}

    FSPGame *game = (id)self.currentEvent;

    if ([game matchupAvailable]) {
        if (!self.matchupView) {
            //TODO: Add other matchup views when written
            //all orgs from the team should have the same viewType
			switch (((FSPOrganization *)[game.homeTeam.organizations anyObject]).viewType) {
				case FSPBasketballViewType:
                case FSPNCAABViewType:
                case FSPNCAAWBViewType:
					self.matchupView = [[FSPNBAMatchupView alloc] init];
					break;
				case FSPBaseballViewType:
					self.matchupView = [[FSPMLBPitcherVsPitcherMatchupView alloc] init];
					break;
                case FSPSoccerViewType:
                    self.matchupView = [[FSPSoccerMatchupView alloc] init];
                    break;
                case FSPHockeyViewType:
                    self.matchupView = [[FSPHockeyMatchupView alloc] init];
                    break;
				case FSPNCAAFViewType:
				case FSPNFLViewType:
					self.matchupView = [[FSPNFLMatchupView alloc] init];
					break;
				default:
					self.matchupView = nil;
					break;
			}
        }
        self.matchupContainer.hidden = NO;
        [self.matchupContainer addSubview:self.matchupView];
        [self.matchupView updateInterfaceWithGame:game];
    }
    else {
        [self.matchupView removeFromSuperview];
        self.matchupContainer.hidden = YES;
    }
    [self updateViewPositions];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    
    self.matchupContainer.autoresizesSubviews = YES;
    
    self.injuryReportSectionHeader.highlightLineFlag = @(NO);
    
    storyViewCachedFrame = CGRectNull;

    self.noStoryLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:18.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInjuryReportView) name:FSPDataCoordinatorUpdatedInjuryReportForEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOddsView) name:FSPDataCoordinatorDidUpdateOddsForEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMatchupView) name:FSPDataCoordinatorDidUpdatePitchingMatchupForEventNotification object:nil];

    self.injuryReportContainer.managedObjectContext = self.managedObjectContext;
    [self.injuryReportContainer updateInterfaceWithGame:(FSPGame *)self.currentEvent];

    [self updateForEvent];
}

- (void)viewDidUnload;
{
    self.storyViewController = nil;
    self.matchupView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout
- (void)updateViewPositions;
{
	if (![self.currentEvent isKindOfClass:[FSPGame class]]) {
		return;
	}

    // Section order, vertically: Matchup | Away Injury | Home Injury | Odds | Story
    FSPGame *game = (id)self.currentEvent;
    if ([game matchupAvailable]){
        [self.matchupView sizeToFit];
        self.matchupView.hidden = NO;
        self.matchupContainer.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.matchupView.frame.size.height);
		//        NSParameterAssert([self.matchupView.superview isEqual:self.matchupContainer]);
    } else {
        self.matchupView.hidden = YES;
        self.matchupContainer.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 0.0f);;
    }
    
    CGRect injuryReportFrame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 0.0f);;
    if (self.injuryReportContainer.isInformationComplete) {
        [self.injuryReportContainer sizeToFit];
        injuryReportFrame = self.injuryReportContainer.frame;
        injuryReportFrame.size.width = self.view.frame.size.width;
        self.injuryReportContainer.hidden = NO;
    } else {
        self.injuryReportContainer.hidden = YES;
    }
    injuryReportFrame.origin.y = CGRectGetMaxY(self.matchupContainer.frame);
    self.injuryReportContainer.frame = injuryReportFrame;
    
    CGRect oddsFrame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 0.0f);;
    if (self.oddsView.isInformationComplete) {
        [self.oddsView sizeToFit];
    } else {
        self.oddsContainer.hidden = YES;
    }
    oddsFrame.origin.y = CGRectGetMaxY(injuryReportFrame);
    self.oddsContainer.frame = oddsFrame;
	
    CGRect storyHeaderFrame = self.storyHeaderLabel.frame;
    storyHeaderFrame.origin = CGPointMake(0, CGRectGetMaxY(self.oddsContainer.frame));
    self.storyHeaderLabel.frame = storyHeaderFrame;
    
    CGRect storyFrame = self.storyContainer.frame;
    storyFrame.origin = CGPointMake(0, CGRectGetMaxY(self.storyHeaderLabel.frame));
	storyFrame.size.height = self.storyViewController.storyViewSize.height;
    self.storyContainer.frame = storyFrame;

	self.storyViewController.view.frame = self.storyContainer.bounds;
	[self.storyViewController.view layoutSubviews];
    
    CGFloat contentHeight = CGRectGetMaxY(self.storyContainer.frame);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, contentHeight);

    [self.scrollView flashScrollIndicators];
}

- (void)storyViewControllerDidFinishLoad:(FSPStoryViewController *)storyViewController
{
	[self updateViewPositions];
}

@end
