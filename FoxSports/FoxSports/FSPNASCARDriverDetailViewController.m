//
//  FSPNASCARDriverDetailViewController.m
//  FoxSports
//
//  Created by Stephen Spring on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARDriverDetailViewController.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPRacingPlayer.h"
#import "FSPRacingSeasonStats.h"
#import "FSPNASCARPlayerStandingsView.h"
#import "FSPImageFetcher.h"

@interface FSPNASCARDriverDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *driverNumberImageView;
@property (weak, nonatomic) IBOutlet UILabel *stLabel;
@property (weak, nonatomic) IBOutlet UILabel *makeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;
@property (strong, nonatomic) NSArray *driverSeasons;

@end

@implementation FSPNASCARDriverDetailViewController

@synthesize driverNumberImageView = _driverNumberImageView;
@synthesize stLabel = _stLabel;
@synthesize makeLabel = _makeLabel;
@synthesize lapsLabel = _lapsLabel;
@synthesize pointsLabel = _pointsLabel;
@synthesize statusLabel = _statusLabel;
@synthesize winningsLabel = _winningsLabel;
@synthesize driverSeasons = _driverSeasons;
@synthesize driver = _driver;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self populateWithDriver];
}

- (void)viewDidUnload
{
    [self setHeadshotImageView:nil];
    [self setDriverNumberImageView:nil];
    [self setTitleLabels:nil];
    [self setValueLabels:nil];
    [self setNameLabel:nil];
    [self setStLabel:nil];
    [self setMakeLabel:nil];
    [self setLapsLabel:nil];
    [self setPointsLabel:nil];
    [self setStatusLabel:nil];
    [self setWinningsLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)populateWithDriver
{
    self.driverSeasons = [self.driver.seasons allObjects];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.driver.firstName, self.driver.lastName];
    self.stLabel.text = [self.driver.raceStartPosition stringValue];
    self.makeLabel.text = self.driver.vehicleDescription;
    self.lapsLabel.text = [self.driver.laps stringValue];
    self.pointsLabel.text = [NSString stringWithFormat:@"%@/%@", [self.driver.points stringValue], [self.driver.bonus stringValue]];
    self.statusLabel.text = self.driver.status;
    self.winningsLabel.text = [self.driver winningsInCurrencyFormat];
    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:self.driver.photoURL]
                                       withCallback:^(UIImage *image) {
                                           if (image) {
                                               self.headshotImageView.image = image;
                                           } else {
                                               self.headshotImageView.image = [UIImage imageNamed:@"Default_Headshot_NASCAR"];
                                           }
                                       }];
    [self styleLabels];
    [self populateSeasons];
}

- (void)populateSeasons
{
    self.playerStandingsNib = [UINib nibWithNibName:@"FSPNASCARPlayerStandingsView" bundle:nil];
    CGFloat topMargin = CGRectGetMaxY(self.headshotImageView.frame);
    CGRect finalFrame = self.view.frame;
    for (FSPRacingSeasonStats *stats in self.driverSeasons) {
        NSArray *topLevelObjects = [self.playerStandingsNib instantiateWithOwner:self options:nil];
        FSPNASCARPlayerStandingsView *playerStandingsView = [topLevelObjects objectAtIndex:0];
        NSInteger playerStandingsViewIndex = [self.driverSeasons indexOfObject:stats];
        CGFloat playerStandingsViewY = topMargin + (playerStandingsView.frame.size.height * playerStandingsViewIndex);
        playerStandingsView.frame = CGRectMake(0.0, playerStandingsViewY, playerStandingsView.bounds.size.width, playerStandingsView.bounds.size.height);
        [self.contentScrollView addSubview:playerStandingsView];
        [playerStandingsView populateWithStats:stats];
        finalFrame = playerStandingsView.frame;
    }
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(finalFrame));
}

@end
