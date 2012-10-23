//
//  FSPFootballDNAViewController.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFootballDNAViewController.h"

#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPCoreDataManager.h"
#import "FSPEvent.h"
#import "FSPCoreDataManager.h"


static NSString * const cacheName = @"com.foxsports.DNACache";

@interface FSPFootballDNAViewController ()

@property IBOutlet UIScrollView *scrollView;
@property (strong) UIView *scoreLineView;
@property (nonatomic, strong) NSFetchedResultsController *scoringFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *playsFetchedResultsController;

@property NSManagedObjectContext *managedObjectContext;
@property NSIndexSet *lastPlayIndex;

- (UIView *)viewForPeriodWithName:(NSString *)name frame:(CGRect)periodFrame;
- (void)drawPeriods;
- (void)drawScoreLine;

@end

@implementation FSPFootballDNAViewController
@synthesize scrollView;
@synthesize scoreLineView;
@synthesize scoringFetchedResultsController = _scoringFetchedResultsController;
@synthesize playsFetchedResultsController = _playsFetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize lastPlayIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)stringForPeriod:(NSUInteger)period;
{
    switch (period) {
        case 0:
            return @"1ST";
            break;
        case 1:
            return @"2ND";
            break;
        case 2:
            return @"3RD";
            break;
        case 3:
            return @"4TH";
            break;
        default:
            return [NSString stringWithFormat:@"OT%d", (NSUInteger)period-3];
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.managedObjectContext = [[FSPCoreDataManager sharedManager] GUIObjectContext];
    
    
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.078 alpha:1.000];
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.scoreLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.scoreLineView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.scoreLineView];
    
    [self drawPeriods];
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    self.lastPlayIndex = nil;

    [self.scoreLineView removeFromSuperview];
    self.scoreLineView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)drawPeriods;
{
    for (UIView *view in [scrollView subviews]) {
        if (view != scoreLineView) {
            [view removeFromSuperview];
        }
    }
    
    
    CGRect frame = self.scrollView.frame;
    CGFloat periodHeight = frame.size.height/4;
    CGFloat maxY = 0;
    
    NSUInteger periodIndex;
    for (periodIndex = 0; periodIndex <= 4; periodIndex++) {
        
        CGRect periodFrame = CGRectMake(0, periodHeight*periodIndex, frame.size.width, periodHeight);
        UIView *periodView = [self viewForPeriodWithName:[self stringForPeriod:periodIndex] frame:periodFrame];
        [scrollView addSubview:periodView];
        maxY = MAX(maxY, CGRectGetMaxY(periodFrame));
        
    }
    
    scrollView.contentSize = CGSizeMake(frame.size.width, maxY);
    CGRect scoreFrame = self.scoreLineView.frame;
    scoreFrame.size.height = maxY;
    scoreLineView.frame = scoreFrame;
         
}


#pragma mark - Period Drawing

- (UIView *)viewForPeriodWithName:(NSString *)name frame:(CGRect)periodFrame;
{
    UIView *quarter = [[UIView alloc] initWithFrame:periodFrame];
    quarter.backgroundColor = [UIColor colorWithWhite:0.078 alpha:1.000];
    
    UILabel *qlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, periodFrame.size.width/3, periodFrame.size.height)];
    qlabel.text = name;
    qlabel.textColor = [UIColor whiteColor];
    qlabel.font = [UIFont systemFontOfSize:10];
    qlabel.backgroundColor = [UIColor colorWithWhite:0.141 alpha:1.000];
    qlabel.textAlignment = UITextAlignmentCenter;
    [quarter addSubview:qlabel];
    
    UIColor *gray = [UIColor colorWithWhite:0.204 alpha:1.000];
    
    UIView *firstThirdBlack = [[UIView alloc] initWithFrame:CGRectMake((periodFrame.size.width/3), 0, 1, periodFrame.size.height)];
    firstThirdBlack.backgroundColor = [UIColor blackColor];
    [quarter addSubview:firstThirdBlack];
    
    UIView *firstThirdGray = [[UIView alloc] initWithFrame:CGRectMake((periodFrame.size.width/3)+1, 0, 1, periodFrame.size.height)];
    firstThirdGray.backgroundColor = gray;
    [quarter addSubview:firstThirdGray];
    
    UIView *secondThirdBlack = [[UIView alloc] initWithFrame:CGRectMake((periodFrame.size.width/3)*2, 0, 1, periodFrame.size.height)];
    secondThirdBlack.backgroundColor = [UIColor blackColor];
    [quarter addSubview:secondThirdBlack];
    
    UIView *secondThirdGray = [[UIView alloc] initWithFrame:CGRectMake(((periodFrame.size.width/3)*2)+1, 0, 1, periodFrame.size.height)];
    secondThirdGray.backgroundColor = gray;
    [quarter addSubview:secondThirdGray];
    
    
    UIView *topBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, periodFrame.size.width, 1)];
    topBlack.backgroundColor = [UIColor blackColor];
    [quarter addSubview:topBlack];
    
    UIView *topGray = [[UIView alloc] initWithFrame:CGRectMake(0, 1, periodFrame.size.width, 1)];
    topGray.backgroundColor = gray;
    [quarter addSubview:topGray];
    
    return quarter;
}

#pragma mark - Scoring Line Drawing

- (CGFloat)yForPlayItem:(FSPGamePlayByPlayItem *)play;
{
    CGFloat periodHeight = self.scrollView.frame.size.height/4;

    CGFloat period = [play.period doubleValue] - 1;
    CGFloat minute = 14 - [play.minute doubleValue];
    CGFloat second = 60 - [play.second doubleValue];
    
    CGFloat playY = period * periodHeight;
    playY += (minute/15) * periodHeight;
    playY += (second/60) * (periodHeight/15);
    
    return playY;
}

- (void)drawScoreLine;
{
    [self.scrollView bringSubviewToFront:self.scoreLineView];
    for (UIView *view in scoreLineView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat maxScore = 20;
    NSArray *plays = self.scoringFetchedResultsController.fetchedObjects;
    FSPGamePlayByPlayItem *lastScoreItem = [plays lastObject];
    maxScore = MAX(maxScore, [lastScoreItem.awayScore doubleValue]);
    maxScore = MAX(maxScore, [lastScoreItem.homeScore doubleValue]);

    
    NSArray *allPlays = self.playsFetchedResultsController.fetchedObjects;
    FSPGamePlayByPlayItem *lastItem = [allPlays lastObject];
    CGFloat gameLastPlayY = [self yForPlayItem:lastItem];
    
    CGFloat maxWidth = (self.scrollView.frame.size.width/3);

    CGFloat centerX = (self.scrollView.frame.size.width/3) * 2;
    // CGFloat periodHeight = self.scrollView.frame.size.height/10;
    
    //CGFloat maxHeight = self.scrollView.frame.size.height;
    
    
    UIView *lastView = nil;
    
    for (FSPGamePlayByPlayItem *play in plays) {
        
        //NSLog(@"%@ - home: %@, away: %@, Q:%@ %@:%@", play.summaryPhrase, play.homeScore, play.awayScore, play.period, play.minute, play.second);
        
        CGFloat homeScore = [play.homeScore doubleValue];
        CGFloat awayScore = [play.awayScore doubleValue];
        CGFloat scoreDiff = homeScore - awayScore;
        
        CGFloat currentY = [self yForPlayItem:play];
        
        CGRect scoreViewRect = CGRectMake(centerX, currentY, (ABS(scoreDiff)/maxScore) * maxWidth, gameLastPlayY - currentY);
        if (lastView) {
            CGRect lastRect = lastView.frame;
            lastRect.size.height = currentY - lastRect.origin.y;
            lastView.frame = lastRect;
        }
        
        UIView *scoreView = [[UIView alloc] initWithFrame:scoreViewRect];
    
        
        scoreView.backgroundColor = scoreDiff > 0 ? play.game.homeTeamColor : play.game.awayTeamColor;
        lastView = scoreView;        
        
        [self.scoreLineView addSubview:scoreView];

    }
    
}


#pragma mark - Fetched results controller delegate

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
        if (self.isViewLoaded) {
            //[NSFetchedResultsController deleteCacheWithName:cacheName]; 
            _playsFetchedResultsController = nil;
            _scoringFetchedResultsController = nil;

            [self drawScoreLine];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    // [self drawScoreLine];
}

#define CHRONOLOGICAL_PLAY_BY_PLAY (1)

- (NSFetchedResultsController *)scoringFetchedResultsController;
{
    if (_scoringFetchedResultsController)
        return _scoringFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGamePlayByPlayItem"];
    NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:CHRONOLOGICAL_PLAY_BY_PLAY];
    NSSortDescriptor *sortDescriptorSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:CHRONOLOGICAL_PLAY_BY_PLAY];
    
    fetchRequest.shouldRefreshRefetchedObjects = YES;
    fetchRequest.sortDescriptors = @[sortDescriptorPeriod, sortDescriptorSequence];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"game.uniqueIdentifier == %@ && pointsScored > 0", self.currentEvent.uniqueIdentifier];
    
    _scoringFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"period" cacheName:nil];
    _scoringFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_scoringFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _scoringFetchedResultsController = nil;
	}
    
    return _scoringFetchedResultsController;
}

- (NSFetchedResultsController *)playsFetchedResultsController;
{
    
    if (_playsFetchedResultsController)
        return _playsFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGamePlayByPlayItem"];
    NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:CHRONOLOGICAL_PLAY_BY_PLAY];
    NSSortDescriptor *sortDescriptorSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:CHRONOLOGICAL_PLAY_BY_PLAY];
    
    fetchRequest.shouldRefreshRefetchedObjects = YES;
    fetchRequest.sortDescriptors = @[sortDescriptorPeriod, sortDescriptorSequence];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"game.uniqueIdentifier == %@", self.currentEvent.uniqueIdentifier];
    
    _playsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"period" cacheName:nil];
    _playsFetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_playsFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unable to execute fetch request error %@, %@", error, [error userInfo]);
        _playsFetchedResultsController = nil;
	}
    
    return _playsFetchedResultsController;
}

@end
