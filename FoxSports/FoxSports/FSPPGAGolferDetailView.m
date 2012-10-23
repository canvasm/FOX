//
//  FSPPGAGolferDetailView.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAGolferDetailView.h"
#import "FSPSecondarySegmentedControl.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGolfer.h"
#import "FSPGolfRound.h"
#import "FSPGolfHole.h"

typedef enum {
    GolfRound1 = 0,
    GolfRound2,
    GolfRound3,
    GolfRound4
} GolfRound;

@interface FSPPGAGolferDetailView()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *rowTitleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *inAndOutLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *valueLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *parValueLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *roundButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *scoreValueLabels;
@property (weak, nonatomic) IBOutlet UILabel *scorecardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *parOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *parInLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreOutLabel;
@property (strong, nonatomic) FSPGolfer *golfer;
@property (strong, nonatomic) FSPGolfRound *golfRound;
@property (weak, nonatomic) IBOutlet UILabel *scoreInLabel;
@property (strong, nonatomic) IBOutlet UIImageView *buttonSelectionImageView;

@end

@implementation FSPPGAGolferDetailView
@synthesize scoreInLabel = _scoreInLabel;
@synthesize buttonSelectionImageView = _buttonSelectionImageView;
@synthesize rowTitleLabels = _rowTitleLabels;
@synthesize inAndOutLabels = _inAndOutLabels;
@synthesize valueLabels = _valueLabels;
@synthesize parValueLabels = _parValueLabels;
@synthesize roundButtons = _roundButtons;
@synthesize scoreValueLabels = _scoreValueLabels;
@synthesize scorecardTitleLabel = _scorecardTitleLabel;
@synthesize parOutLabel = _parOutLabel;
@synthesize parInLabel = _parInLabel;
@synthesize scoreOutLabel = _scoreOutLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSArray *)parValueLabels
{
    NSArray *sortedParValueLabels = [_parValueLabels sortedArrayUsingComparator:^(UILabel *labelA, UILabel *labelB) {
        if (labelA.tag > labelB.tag) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (labelA.tag < labelB.tag) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sortedParValueLabels;
}

- (void)awakeFromNib
{
    [self setupUserInterface];
}

- (void)populateWithGolfer:(FSPGolfer *)golfer
{
    self.golfer = golfer;
    
    for (UIButton *button in self.roundButtons) {
        if (button.tag == 1) {
            [self switchRound:button];
        }
    }
}

- (void)populateViewForSelectedRound:(GolfRound)round
{
    NSArray *golferRounds = [FSPPGAGolferDetailView sortedGolferRounds:self.golfer];
    
    if ([golferRounds count] > round) {
        self.golfRound = [golferRounds objectAtIndex:round];
        
        NSArray *roundHoles = [self.golfRound.holes allObjects];
        for (FSPGolfHole *golfHole in roundHoles) {
            NSString *golfHoleName = [golfHole.label lowercaseString];
            if ([golfHoleName isEqualToString:@"in"]) {
                self.scoreInLabel.text = [golfHole.strokes stringValue];
                self.parInLabel.text = [golfHole.par stringValue];
                continue;
            }
            if ([golfHoleName isEqualToString:@"out"]) {
                self.scoreOutLabel.text = [golfHole.strokes stringValue];
                self.parOutLabel.text = [golfHole.par stringValue];
                continue;
            }
            for (UILabel *label in self.scoreValueLabels) {
                NSInteger labelIndex = [self.scoreValueLabels indexOfObject:label];
                NSNumber *labelIndexNumber =[NSNumber numberWithInt:labelIndex + 1];
                NSString *labelIndexString = [labelIndexNumber stringValue];
                if ([golfHoleName isEqualToString:labelIndexString]) {
                    UILabel *label = [self.scoreValueLabels objectAtIndex:labelIndex];
                    label.text = [golfHole.strokes stringValue];
                    continue;
                }
            }
            for (UILabel *label in self.parValueLabels) {
                NSInteger labelIndex = [self.parValueLabels indexOfObject:label];
                NSNumber *labelIndexNumber = [NSNumber numberWithInt:labelIndex + 1];
                NSString *labelIndexString = [labelIndexNumber stringValue];
                if ([golfHoleName isEqualToString:labelIndexString]) {
                    UILabel *label = [self.parValueLabels objectAtIndex:labelIndex];
                    label.text = [golfHole.par stringValue];
                    continue;
                }
            }
        }
    } else {
        [self setDefaultsForRound];
    }
}

- (void)setDefaultsForRound
{
    NSString *defaultTextValue = @"--";
    self.scoreInLabel.text = defaultTextValue;
    self.scoreOutLabel.text = defaultTextValue;

    for (UILabel *label in self.scoreValueLabels) {
        label.text = defaultTextValue;
    }
}

+ (NSArray *)sortedGolferRounds:(FSPGolfer *)golfer
{
    return [[golfer.rounds allObjects] sortedArrayUsingComparator:^(FSPGolfRound *roundA, FSPGolfRound *roundB) {
        
        if ([roundA.round integerValue] > [roundB.round integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([roundA.round integerValue] < [roundB.round integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

- (IBAction)switchRound:(UIButton *)sender
{
    NSInteger round = sender.tag;
    switch (round) {
        case 1:
            [self populateViewForSelectedRound:GolfRound1];
            break;
        case 2:
            [self populateViewForSelectedRound:GolfRound2];
            break;
        case 3:
            [self populateViewForSelectedRound:GolfRound3];
            break;
        case 4:
            [self populateViewForSelectedRound:GolfRound4];
            break;
    }
    
    for (UIButton *button in self.roundButtons) {
        if ([button isEqual:sender]) {
            [button setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            self.buttonSelectionImageView.frame = CGRectMake(button.bounds.origin.x, button.bounds.size.height - self.buttonSelectionImageView.frame.size.height, self.buttonSelectionImageView.frame.size.width, self.buttonSelectionImageView.frame.size.height);
            [button addSubview:self.buttonSelectionImageView];
        } else {
            [button setTitleColor:[UIColor fsp_lightBlueColor] forState:UIControlStateNormal];
        }
    }
}

- (void)setupUserInterface
{
    self.scorecardTitleLabel.textColor = [UIColor whiteColor];
    self.scorecardTitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    
    [self styleInAndOutLabels];
    [self styleRowTitleLabels];
    [self styleValueLabels];
    [self styleButtonLabels];
}

- (void)styleValueLabels
{
    for (UILabel *label in self.valueLabels) {
        label.font = [UIFont fontWithName:FSPClearViewRegularFontName size:14.0];
        label.textColor = [UIColor fsp_lightBlueColor];
    }
}

- (void)styleRowTitleLabels
{
    for (UILabel *label in self.rowTitleLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
        label.textColor = [UIColor fsp_yellowColor];
    }
}

- (void)styleInAndOutLabels
{
    for (UILabel *label in self.inAndOutLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0];
        label.textColor = [UIColor whiteColor];
    }
}

- (void)styleButtonLabels
{
    for (UIButton *button in self.roundButtons) {
        [button setTitleColor:[UIColor fsp_lightBlueColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14.0]];
    }
}

@end
