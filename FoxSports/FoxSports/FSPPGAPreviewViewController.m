//
//  FSPPGAPreviewViewController.m
//  FoxSports
//
//  Created by Laura Savino on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAPreviewViewController.h"
#import "FSPPGAEvent.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPPGAPreviewViewController ()

@property (nonatomic, weak) IBOutlet UILabel *parLabel;
@property (nonatomic, weak) IBOutlet UILabel *winnerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *previousWinnerLabel;
@property (nonatomic, weak) IBOutlet UILabel *yardsLabel;
@property (nonatomic, weak) IBOutlet UILabel *purseLabel;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *tournamentDetailKeyLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *tournamentDetailValueLabels;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *tournamentPreviewHeaderBoxViews;

@end

@implementation FSPPGAPreviewViewController

@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;


- (id)initWithPGAEvent:(FSPPGAEvent *)event;
{
    self = [super init];
    if(!self) return nil;

    self.currentEvent = event;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for(UIView *view in self.tournamentPreviewHeaderBoxViews)
    {
        view.backgroundColor = [UIColor fsp_lightGrayColor];
    }
    
    self.previousWinnerLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
    self.previousWinnerLabel.textColor = [UIColor fsp_lightBlueColor];
    self.previousWinnerLabel.backgroundColor = [UIColor clearColor];
    
    self.winnerNameLabel.font = [UIFont fontWithName:FSPClearViewMediumFontName size:14];
    self.winnerNameLabel.textColor = [UIColor whiteColor];
    self.winnerNameLabel.backgroundColor = [UIColor clearColor];
    
    for (UILabel *label in self.tournamentDetailKeyLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        label.textColor = [UIColor fsp_lightBlueColor];
        label.backgroundColor = [UIColor colorWithRed:0.00f green:0.23f blue:0.56f alpha:1.00f];
    }
    
    for (UILabel *label in self.tournamentDetailValueLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
        label.textColor = [UIColor fsp_lightBlueColor];
        label.backgroundColor = [UIColor colorWithRed:0.00f green:0.23f blue:0.56f alpha:1.00f];
    }
}

- (void)setCurrentEvent:(FSPPGAEvent *)event;
{
    if(event == _currentEvent)
        return;

    self.winnerNameLabel.text = event.winnerName;
    self.parLabel.text = event.winnerStrokesUnder.stringValue;
    self.yardsLabel.text = event.winnerScore.stringValue;
    self.purseLabel.text = event.winnerPrizeMoney.stringValue;

    _currentEvent = event;
}

@end
