//
//  FSPNascarPlayerStandingsView.m
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARPlayerStandingsView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPRacingSeasonStats.h"

@interface FSPNASCARPlayerStandingsView()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *driverEventValuesLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *driverEventTitleLabels;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *behindLabel;
@property (weak, nonatomic) IBOutlet UILabel *startsLabel;
@property (weak, nonatomic) IBOutlet UILabel *polesLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *top5Label;
@property (weak, nonatomic) IBOutlet UILabel *top10Label;
@property (weak, nonatomic) IBOutlet UILabel *lapsLedLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (strong, nonatomic) FSPRacingSeasonStats *stats;

@end

@implementation FSPNASCARPlayerStandingsView

@synthesize driverEventValuesLabel = _driverEventValuesLabel;
@synthesize driverEventTitleLabels = _driverEventTitleLabels;
@synthesize rankLabel = _rankLabel;
@synthesize pointsLabel = _pointsLabel;
@synthesize behindLabel = _behindLabel;
@synthesize startsLabel = _startsLabel;
@synthesize polesLabel = _polesLabel;
@synthesize winsLabel = _winsLabel;
@synthesize top5Label = _top5Label;
@synthesize top10Label = _top10Label;
@synthesize lapsLedLabel = _lapsLedLabel;
@synthesize winningLabel = _winningLabel;
@synthesize eventNameLabel = _eventNameLabel;
@synthesize stats = _stats;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self setLabelFonts];
}

- (void)populateWithStats:(FSPRacingSeasonStats *)stats
{
    self.stats = stats;  
    self.eventNameLabel.text = [stats.name uppercaseString];
    self.rankLabel.text = [stats.rank stringValue];
    self.pointsLabel.text = [stats.points stringValue];
    self.behindLabel.text = [stats.behind stringValue];
    self.startsLabel.text = [stats.starts stringValue];
    self.polesLabel.text = [stats.poles stringValue];
    self.winsLabel.text = [stats.wins stringValue];
    self.top5Label.text = [stats.top5 stringValue];
    self.top10Label.text = [stats.top10 stringValue];
    self.lapsLedLabel.text = [stats.lapsLed stringValue];
    self.winningLabel.text = [stats winningsInCurrencyFormat];;
}

- (void)setLabelFonts
{
    _eventNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
    _eventNameLabel.textColor = [UIColor whiteColor];
    
    for (UILabel *label in _driverEventTitleLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
        label.textColor = [UIColor fsp_yellowColor];
    }
    
    for (UILabel *label in _driverEventValuesLabel) {
        label.font = [UIFont fontWithName:FSPClearViewMediumFontName size:12.0];
        label.textColor = [UIColor fsp_lightBlueColor];
    }
}

@end
