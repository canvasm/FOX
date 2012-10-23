//
//  FSPMLBPlayByPlayCell.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPlayByPlayCell.h"
#import "FSPMLBPlayByPlayGameStateView.h"
#import "FSPGamePlayByPlayItem.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

#define kDescriptionLabelFontSize 14.0

@interface FSPMLBPlayByPlayCell ()
@end

@implementation FSPMLBPlayByPlayCell
@synthesize gameStateView;

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
	[super populateWithPlayByPlayItem:playByPlayItem];
	self.gameStateView.outs = [playByPlayItem.outs integerValue];
	self.gameStateView.baseRunnersMask = [playByPlayItem.baseRunners integerValue];
	self.playLabel.text = [playByPlayItem eventPBPString];
    [self.playLabel setNumberOfLines:1];
	
	if ([playByPlayItem.eventCode isEqualToString:@"E1"]) {
		self.gameStateView.hidden = YES;
	} else {
		self.gameStateView.hidden = NO;
	}
	self.playLabel.textColor = [UIColor whiteColor];
    self.playLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    
    [self.descriptionLabel setNumberOfLines:3];
    self.descriptionLabel.textColor = [UIColor fsp_lightBlueColor];
    self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:kDescriptionLabelFontSize];
    
//	self.layer.borderColor = [UIColor whiteColor].CGColor;
//	self.layer.borderWidth = 1.0;
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    NSString *summary = playByPlayItem.summaryPhrase;
    UIFont *summaryFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:kDescriptionLabelFontSize];
    CGFloat summaryWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 286.0 : 176.0;
    CGSize summaryDisplaySize = [summary sizeWithFont:summaryFont constrainedToSize:CGSizeMake(summaryWidth, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat verticalPadding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 13.0 + 5.0 : 26.0 + 5.0;
    CGFloat minimumCellHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 52.0 : 84.0;
    CGFloat calculatedCellHeight = summaryDisplaySize.height + verticalPadding;
    
    if (calculatedCellHeight > minimumCellHeight) {
        return calculatedCellHeight;
    } else {
        return minimumCellHeight;
    };
}

@end
