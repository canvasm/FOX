//
//  FSPUFCPreEventCell.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCPreEventCell.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPUFCPreEventCell ()

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *rowLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *dataLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *fighterNames;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *fighterNickNames;

@end

@implementation FSPUFCPreEventCell


@synthesize rowLabels;
@synthesize dataLabels;
@synthesize fighterNames;
@synthesize fighterNickNames;
@synthesize fightProgress;
@synthesize fighterOneName;
@synthesize fighterTwoName;
@synthesize fighterOneImage;
@synthesize fighterTwoImage;
@synthesize fighterOneNick;
@synthesize fighterTwoNick;
@synthesize fighterOneWLD;
@synthesize fighterTwoWLD;
@synthesize fighterOneHeight;
@synthesize fighterTwoHeight;
@synthesize fighterOneWeight;
@synthesize fighterTwoWeight;
@synthesize fighterOneReach;
@synthesize fighterTwoReach;
@synthesize fighterOneAge;
@synthesize fighterTwoAge;
@synthesize fighterOneHometown;
@synthesize fighterTwoHometown;
@synthesize fighterOneFightsOutOf;
@synthesize fighterTwoFightsOutOf;
@synthesize fighterOneStrikesLandedPerMinute;
@synthesize fighterTwoStrikesLandedPerMinute;
@synthesize fighterOneStrikingAccuracy;
@synthesize fighterTwoStrikingAccuracy;
@synthesize fighterOneStrikesAbsorbedPerMinute;
@synthesize fighterTwoStrikesAbsorbedPerMinute;
@synthesize fighterOneStrikeDefense;
@synthesize fighterTwoStrikeDefense;
@synthesize fighterOneTakedownAverage;
@synthesize fighterTwoTakedownAverage;
@synthesize fighterOneTakedownAccuracy;
@synthesize fighterTwoTakedownAccuracy;
@synthesize fighterOneTakedownDefense;
@synthesize fighterTwoTakedownDefense;
@synthesize fighterOneSubmissionAverage;
@synthesize fighterTwoSubmissionAverage;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPUFCPreEventCell" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
    return [self init];
}

- (void)awakeFromNib;
{
    CGFloat fontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = 14.0f;
    } else {
        fontSize = 14.0f;
    }

    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];

    [self.fightProgress setBackgroundImage:[[UIImage imageNamed:@"red_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 3.0)] forState:UIControlStateNormal];
    self.fightProgress.titleLabel.font = font;
    [self.fightProgress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIColor *color = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.rowLabels) {
        label.textColor = color;
        label.font = font;
    }
    
    color = [UIColor whiteColor];
    for (UILabel *label in self.dataLabels) {
        label.textColor = color;
        label.font = font;
    }
        
    for (UILabel *label in self.fighterNickNames) {
        label.textColor = color;
        label.font = font;
    }
    
    font = [UIFont fontWithName:FSPUScoreRGKFontName size:16];
    for (UILabel *label in self.fighterNames) {
        label.textColor = color;
        label.font = font;
    }

}

- (void)prepareForReuse;
{
    
    for (UILabel *label in self.dataLabels) {
        label.text = nil;
    }

    for (UILabel *label in self.fighterNames) {
        label.text = nil;
    }

    for (UILabel *label in self.fighterNickNames) {
        label.text = nil;
    }

    self.fighterOneImage.image = nil;
    self.fighterTwoImage.image = nil;

}

@end
