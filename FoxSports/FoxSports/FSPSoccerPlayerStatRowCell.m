//
//  FSPSoccerStatRowCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerPlayerStatRowCell.h"
#import "FSPSoccerPlayer.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UILabel+FSPExtensions.h"

NSString * const FSPSoccerPlayerStatRowCellReuseIdentifier = @"FSPSoccerPlayerStatRowCellReuseIdentifier";
NSString * const FSPSoccerPlayerStatRowCellNibName = @"FSPSoccerPlayerStatRowCell";

@interface FSPSoccerPlayerStatRowCell ()
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *minuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *shotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *shotsOnGoalLabel;
@property (weak, nonatomic) IBOutlet UILabel *fcLabel;
@property (weak, nonatomic) IBOutlet UILabel *fdLabel;
@end

@implementation FSPSoccerPlayerStatRowCell
@synthesize playerNameLabel;
@synthesize positionLabel;
@synthesize minuteLabel;
@synthesize shotsLabel;
@synthesize shotsOnGoalLabel;
@synthesize fcLabel;
@synthesize fdLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPSoccerPlayerStatRowCell" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

- (void)awakeFromNib
{
    self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.playerNameLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
    UIColor *color = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.requiredLabels) {
        label.font = font;
        label.textColor = color;
    }
}

- (void)prepareForReuse
{
    self.playerNameLabel.text = nil;
}

- (void)populateWithPlayer:(FSPSoccerPlayer *)player;
{
    if (player.position.length > 2) {
        self.positionLabel.text = @"--";
    } else {
        self.positionLabel.text = player.position;
    }
    self.playerNameLabel.text = [player abbreviatedName];
    self.minuteLabel.text = player.minutesPlayed.stringValue;
    self.shotsLabel.text = player.shots.stringValue;
    self.shotsOnGoalLabel.text = player.shotsOnGoal.stringValue;
    self.fcLabel.text = player.foulsCommitted.stringValue;
    self.fdLabel.text = player.foulsSuffered.stringValue;
    
    for(UILabel *label in self.requiredLabels)
        [label fsp_indicateNoData];
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

@end
