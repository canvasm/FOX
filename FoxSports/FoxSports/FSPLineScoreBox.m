//
//  FSPLineScoreBox.m
//  FoxSports
//
//  Created by Laura Savino on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLineScoreBox.h"
#import "FSPGameSegmentView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailSectionHeader.h"

@interface FSPLineScoreBox () {}

@property (nonatomic, weak) IBOutlet UILabel *awayTeamLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scoresContainerView;

/**
 * This view contains a varying number of game segment subviews. The segmentViews
 * array holds references these subviews in display order, so their scores
 * can be updated.
 */
@property (nonatomic, strong) NSMutableArray *segmentViews;

- (void)addGameSegmentWithName:(NSString *)name;

/**
 * The display name for a given game segment number, specific to a sport.
 * For example, the 3rd period in an NCAA basketball game is "OT1", 
 * but the 3rd period in an NBA basketball game is "3".
 */
- (NSString *)displayNameForGameSegment:(NSUInteger)segment;

@end

@implementation FSPLineScoreBox 

@synthesize contentView;
@synthesize homeTeamLabel = _homeTeamLabel;
@synthesize awayTeamLabel = _awayTeamLabel;
@synthesize segmentViews = _segmentViews;
@synthesize maxRegularPlayGameSegments = _maxRegularPlayGameSegments;
@synthesize scoresContainerView = _scoresContainerView;


- (void)drawRect:(CGRect)rect;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGFloat dividerLineY = CGRectGetMaxY(rect) - 1.0;
    FSPDrawGameSectionDividerLine(ctx, CGPointMake(0.0, dividerLineY), CGPointMake(CGRectGetMaxX(rect), dividerLineY), YES, YES);
    CGContextRestoreGState(ctx);

}

- (id)initWithFrame:(CGRect)frame;
{
	self = [super initWithFrame:frame];
	if (self) {
		UINib *nib = [UINib nibWithNibName:@"FSPLineScoreBox" bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		[self addSubview:self.contentView];
        self.frame = self.contentView.frame;

	    self.maxRegularPlayGameSegments = 4;
		self.segmentViews = [[NSMutableArray alloc] init];
		
		self.backgroundColor = [UIColor clearColor];
		
		// Used by QA for automationed UI tests
		self.scoresContainerView.accessibilityIdentifier = @"periodScores";
		self.homeTeamLabel.accessibilityIdentifier = @"homeTeamName";
		self.awayTeamLabel.accessibilityIdentifier = @"awayTeamName";
		
		UIFont *teamNameLabelFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0f];
		self.homeTeamLabel.font = teamNameLabelFont;
		self.awayTeamLabel.font = teamNameLabelFont;
        
        self.maxSegmentsToDisplay = 7;
	}
    return self;
}

- (void)updateScoresForGameSegment:(NSUInteger)segment homeScore:(NSString *)homeScore awayScore:(NSString *)awayScore;
{
    //If we're updating scores for a new game segment, add the new game segment
    if(self.segmentViews.count < segment)
    {
        [self addGameSegmentWithName:[self displayNameForGameSegment:segment]];
    }
    
    //Get the game segment view corresponding to the requested game segment
    FSPGameSegmentView *segmentView = [self.segmentViews objectAtIndex:segment - 1];
    segmentView.homeTeamScoreLabel.text = homeScore;
    segmentView.awayTeamScoreLabel.text = awayScore;
    segmentView.homeTeamScoreLabel.accessibilityLabel = segmentView.homeTeamScoreLabel.text;
    segmentView.awayTeamScoreLabel.accessibilityLabel = segmentView.awayTeamScoreLabel.text;
}

- (void)addGameSegmentWithName:(NSString *)name;
{
    FSPGameSegmentView *newSegmentView = [[FSPGameSegmentView alloc] initWithFrame:CGRectZero];

    NSUInteger widthDivisor = self.segmentViews.count;
    if (widthDivisor >= self.maxSegmentsToDisplay) {
        widthDivisor = self.maxSegmentsToDisplay;
    }
    else {
        widthDivisor = (self.segmentViews.count + 1 > self.maxRegularPlayGameSegments ? self.segmentViews.count + 1 : self.maxRegularPlayGameSegments);
    }
    __block CGFloat segmentsWidth = self.scoresContainerView.bounds.size.width / widthDivisor;

	newSegmentView.frame = CGRectMake(segmentsWidth * (self.segmentViews.count), 0, segmentsWidth, self.scoresContainerView.bounds.size.height);
    newSegmentView.gameSegmentLabel.text = name;
    newSegmentView.gameSegmentLabel.accessibilityIdentifier = [NSString stringWithFormat:@"period%@Header", name];
    newSegmentView.homeTeamScoreLabel.accessibilityIdentifier = [NSString stringWithFormat:@"period%@HomeTeamScore", name];
    newSegmentView.awayTeamScoreLabel.accessibilityIdentifier = [NSString stringWithFormat:@"period%@AwayTeamScore", name];
	UIFont *scoreSubTotalFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:15.0f];
	[newSegmentView setScoreLabelFonts:scoreSubTotalFont];
	
    [self.segmentViews addObject:newSegmentView];
    [self.scoresContainerView addSubview:newSegmentView];
    
    __block CGSize contentSize = CGSizeMake(CGRectGetMaxX(newSegmentView.frame), self.frame.size.height);

    // If beyond maxRegularPlayGameSegments, resize all the segments
    if (self.segmentViews.count > self.maxRegularPlayGameSegments) {
        [self.segmentViews enumerateObjectsUsingBlock:^(FSPGameSegmentView *segment, NSUInteger idx, BOOL *stop) {
            segment.frame = CGRectMake(segmentsWidth * idx, 0, segmentsWidth, self.scoresContainerView.bounds.size.height);
        }];
        
        contentSize = CGSizeMake(CGRectGetMaxX(((UIView *)[self.segmentViews lastObject]).frame), self.frame.size.height);
    }
    
	self.scoresContainerView.contentSize = contentSize;
    self.scoresContainerView.contentSize = CGSizeMake(CGRectGetMaxX(newSegmentView.frame), self.frame.size.height);
}

- (NSString *)displayNameForGameSegment:(NSUInteger)segment;
{
    if(segment <= self.maxRegularPlayGameSegments)
        return [NSString stringWithFormat:@"%d", segment];
    
//    NSUInteger overtimeCount = segment - self.maxRegularPlayGameSegments;
//    return [NSString stringWithFormat:@"OT", overtimeCount];
	return @"OT";
}


- (void)resetGameSegments;
{
    // Start clean
    self.scoresContainerView.scrollEnabled = YES;
    do
    {
        FSPGameSegmentView *segmentView = [self.segmentViews lastObject];
        [segmentView removeFromSuperview];
        [self.segmentViews removeLastObject];
    } while((NSInteger)self.segmentViews.count > 0);
    
    //Add initial (possibly empty) game segments up to max number of regular play game segments
	for(NSUInteger segment = self.segmentViews.count + 1; segment <= self.maxRegularPlayGameSegments; segment++)
	{
		[self addGameSegmentWithName:[self displayNameForGameSegment:segment]];
	}
    
    //Reset scrollview to not scroll
    self.scoresContainerView.contentSize = CGSizeMake([[self.segmentViews lastObject] frame].size.width, self.scoresContainerView.frame.size.height);
    
    //Reset score views to avoid artifacts from previous event scores
    [self.segmentViews enumerateObjectsUsingBlock:^(FSPGameSegmentView *segmentView, NSUInteger idx, BOOL *stop)
    {
        segmentView.homeTeamScoreLabel.text = @"";
        segmentView.awayTeamScoreLabel.text = @"";
        segmentView.homeTeamScoreLabel.accessibilityLabel = segmentView.homeTeamScoreLabel.text;
        segmentView.awayTeamScoreLabel.accessibilityLabel = segmentView.awayTeamScoreLabel.text;
    }];
}

- (void)clearGameSegments
{
    for (FSPGameSegmentView *segmentView in self.segmentViews) {
        [segmentView removeFromSuperview];
    }
    [self.segmentViews removeAllObjects];
}

- (void)scrollToLatestGameSegment;
{
    FSPGameSegmentView *lastView = [self.segmentViews lastObject];
    [self.scoresContainerView scrollRectToVisible:lastView.frame animated:NO];
    self.scoresContainerView.scrollEnabled = NO;
}

- (NSString *)accessibilityIdentifier
{
    return @"lineScore";
}

/* The container itself is not accessible, so MultiFacetedView should return NO in isAccessiblityElement. */
- (BOOL)isAccessibilityElement
{
    return NO;
}

/* The following methods are implementations of UIAccessibilityContainer protocol methods. */
- (NSInteger)accessibilityElementCount
{
    return [[self subviews] count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [[self subviews] objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [[self subviews] indexOfObject:element];
}

@end
