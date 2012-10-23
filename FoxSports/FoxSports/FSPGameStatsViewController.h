//
//  FSPGameStatsViewController.h
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPExtendedEventDetailManaging.h"
#import "FSPLineScoreBox.h"

@class FSPBoxScoreHeaderView;
@class FSPGameTopPlayersViewContainer;
@class FSPBoxScoreViewController;
@class FSPGame;

@interface FSPGameStatsViewController : UIViewController <FSPExtendedEventDetailManaging, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FSPEvent *currentEvent;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIView *lineScoreContainer;

@property (strong, nonatomic) IBOutlet UIView *gameStateView;
@property (nonatomic, strong) FSPGameTopPlayersViewContainer *topPlayersView;

@property (nonatomic, strong) FSPLineScoreBox *lineScoreBox;

@property (nonatomic, weak) IBOutlet UIView *boxScoreContainer;

/**
 * Controls the box score (displays team stats)
 */
@property (nonatomic, strong) FSPBoxScoreViewController *boxScoreViewController;

/**
 * Updates positions of subviews to account for hidden/expanded sections
 */
- (void)updateInterface;
- (void)updateGameStateInterface;
- (void)updateTotalScoreInterface;
- (void)updateLineScoreBox;
- (void)layoutStatsViews;

- (NSSet *)allPlayers;

// Return the FSPBoxScoreViewController subclass used to instantiate the box score, or nil if this view doesn't have a boxscore.
// Override to change or hide the box score section.
+ (Class)boxScoreViewControllerClass;

@end
