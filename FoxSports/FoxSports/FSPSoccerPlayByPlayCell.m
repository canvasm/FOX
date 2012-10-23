//
//  FSPSoccerPlayByPlayCell.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/24/12
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerPlayByPlayCell.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPTeam.h"
#import "FSPGame.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"

@interface FSPSoccerPlayByPlayCell ()
@property (nonatomic, weak) IBOutlet UILabel *minuteLabel;
@property (nonatomic, weak) IBOutlet UILabel *summaryLabel;
@property (nonatomic, weak) IBOutlet UIImageView *substitutionImage;
@end

@implementation FSPSoccerPlayByPlayCell {
    CGFloat largeFontSize;
    CGFloat smallFontSize;
}
@synthesize minuteLabel, summaryLabel, substitutionImage;

- (void)awakeFromNib
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        smallFontSize = 13.0f;
        largeFontSize = 13.0f;
    } else {
        smallFontSize = 12.0f;
        largeFontSize = 14.0f;
    }
    
	self.minuteLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:smallFontSize];
    self.minuteLabel.textColor = [UIColor fsp_yellowColor];
	self.summaryLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:smallFontSize];
    self.summaryLabel.textColor = [UIColor fsp_lightBlueColor];
    self.substitutionImage.hidden = YES;
    
}

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
	[super populateWithPlayByPlayItem:playByPlayItem];
    self.minuteLabel.text = [NSString stringWithFormat:@"%@'", playByPlayItem.minute.stringValue];
    self.summaryLabel.text = playByPlayItem.summaryPhrase;
    self.substitutionImage.hidden = YES;
    self.substitutionImage.image = nil;
    if (playByPlayItem.substitution) {
        self.substitutionImage.image = [UIImage imageNamed:@"sub_arrows_soccer"];
        self.substitutionImage.hidden = NO;
    } else if (playByPlayItem.penalty.intValue == 1) {
        self.substitutionImage.image = [UIImage imageNamed:@"yellow_card"];
        self.substitutionImage.hidden = NO;
    } else if (playByPlayItem.penalty.intValue == 2) {
        self.substitutionImage.image = [UIImage imageNamed:@"red_card"];
        self.substitutionImage.hidden = NO;
    } else if (playByPlayItem.baseRunners.intValue == 1) {
        self.substitutionImage.image = [UIImage imageNamed:@"soccer_ball"];
        self.substitutionImage.hidden = NO;
    }

}

- (void)prepareForReuse
{
    self.minuteLabel.text = nil;
    self.summaryLabel.text = nil;
    self.substitutionImage.hidden = YES;
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    NSString *summary = playByPlayItem.summaryPhrase;
    CGFloat fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 14.0 : 13.0;
    UIFont *summaryFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    CGFloat summaryWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 349.0 : 213.0;
    CGSize summaryDisplaySize = [summary sizeWithFont:summaryFont constrainedToSize:CGSizeMake(summaryWidth, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat verticalPadding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0 + 8.0 : 22.0 + 2.0;
    CGFloat minimumCellHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 52.0 : 84.0;
    CGFloat calculatedCellHeight = summaryDisplaySize.height + verticalPadding;
    
    if (calculatedCellHeight > minimumCellHeight) {
        return calculatedCellHeight;
    } else {
        return minimumCellHeight;
    };
}

@end
