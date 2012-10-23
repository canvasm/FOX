//
//  FSPLineScoreBox.h
//  FoxSports
//
//  Created by Laura Savino on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGameSegmentView;

@interface FSPLineScoreBox : UIView

@property (nonatomic, weak, readonly) IBOutlet UIView *contentView;


/**
 * TODO: This should be stored on the sport object.
 */
@property (nonatomic, assign) NSUInteger maxRegularPlayGameSegments;

/**
 * Maximum number of segments to display before scrolling
 */
@property (nonatomic, assign) NSUInteger maxSegmentsToDisplay;

/**
 * The displayed names of home and away teams; should be 'pinned' to the 
 * left side of the view. 
 */
@property (nonatomic, weak, readonly) UILabel *awayTeamLabel;
@property (nonatomic, weak, readonly) UILabel *homeTeamLabel;

/**
 * The scrolling container for all periods; expands to hold as many overtime periods as needed.
 */
@property (nonatomic, weak, readonly) UIScrollView *scoresContainerView;

/**
 * Takes the numerical value of the period and updates its scores for home and away teams.
 */
- (void)updateScoresForGameSegment:(NSUInteger)segment homeScore:(NSString *)homeScore awayScore:(NSString *)awayScore;

/**
 * Prepares the view to present a new event.
 */
- (void)resetGameSegments;

/**
 * Removes all segment views from the scores container view and empties the 
 * segmentViews array
 */
- (void)clearGameSegments;

/**
 * Scrolls score view to show latest game segment (period).
 */
- (void)scrollToLatestGameSegment;

@end
