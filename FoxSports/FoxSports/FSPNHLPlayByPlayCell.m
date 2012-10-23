//
//  FSPMLBPlayByPlayCell.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLPlayByPlayCell.h"
#import "FSPMLBPlayByPlayGameStateView.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPTeam.h"
#import "FSPGame.h"
#import "FSPTeamColorLabel.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"

@interface FSPNHLPlayByPlayCell ()

@end

@implementation FSPNHLPlayByPlayCell {
    CGFloat largeFontSize;
    CGFloat smallFontSize;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        smallFontSize = 13.0f;
        largeFontSize = 13.0f;
    } else {
        smallFontSize = 12.0f;
        largeFontSize = 14.0f;
    }
    
	self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:largeFontSize];
	self.descriptionLabel.textColor = [UIColor whiteColor];
	
//	self.layer.borderColor = [UIColor greenColor].CGColor;
//	self.layer.borderWidth = 1.0;
}

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
	[super populateWithPlayByPlayItem:playByPlayItem];

    self.descriptionLabel.textColor = [UIColor fsp_lightBlueColor];
    self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:largeFontSize];
	self.playLabel.textColor = [UIColor whiteColor];
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    NSString *summary = playByPlayItem.summaryPhrase;
    CGFloat fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 14.0 : 13.0;
    UIFont *summaryFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    CGFloat summaryWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 366.0 : 172.0;
    CGSize summaryDisplaySize = [summary sizeWithFont:summaryFont constrainedToSize:CGSizeMake(summaryWidth, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat verticalPadding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 11.0 + 7.0 : 22.0 + 2.0;
    CGFloat minimumCellHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 52.0 : 84.0;
    CGFloat calculatedCellHeight = summaryDisplaySize.height + verticalPadding;
    
    if (calculatedCellHeight > minimumCellHeight) {
        return calculatedCellHeight;
    } else {
        return minimumCellHeight;
    };
}

@end
