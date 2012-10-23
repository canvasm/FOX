//
//  FSPMLBPlayByPlayCell.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLPlayByPlayCell.h"
#import "FSPMLBPlayByPlayGameStateView.h"
#import "FSPGamePlayByPlayItem.h"
#import "FSPTeam.h"
#import "FSPGame.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"

@interface FSPNFLPlayByPlayCell ()
@property (nonatomic, weak) IBOutlet UILabel *yardLabel;
@property (nonatomic, weak) IBOutlet UILabel *goalLabel;
@end

@implementation FSPNFLPlayByPlayCell {
    CGFloat largeFontSize;
    CGFloat smallFontSize;
}
@synthesize yardLabel, goalLabel;

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
    
	self.yardLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:smallFontSize];
	self.goalLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:smallFontSize];
	self.playLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:largeFontSize];
	self.playLabel.textColor = [UIColor whiteColor];
}

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
	[super populateWithPlayByPlayItem:playByPlayItem];
	self.playLabel.text = [playByPlayItem eventPBPString];
	
    self.descriptionLabel.textColor = [UIColor fsp_lightBlueColor];
    self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:largeFontSize];

	
	self.yardLabel.text = [NSString stringWithFormat:@"%@ & %@", [playByPlayItem.down fsp_ordinalStringValue], playByPlayItem.yardsToGo];
	self.goalLabel.text = [playByPlayItem yardsFromGoalString];
	
	// TODO: this is temporary logic. use event codes once those are implemented. possibly add other play types?
	if ([playByPlayItem.eventPBPString isEqualToString:@"Kickoff"] || [playByPlayItem.eventPBPString isEqualToString:@"PAT"] || [playByPlayItem.down integerValue] == 0) {
		self.yardLabel.hidden = YES;
		self.goalLabel.hidden = YES;
	} else {
		self.yardLabel.hidden = NO;
		self.goalLabel.hidden = NO;
	}
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    NSString *summary = playByPlayItem.summaryPhrase;
    CGFloat fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 14.0 : 13.0;
    UIFont *summaryFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    CGFloat summaryWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 366.0 : 172.0;
    CGSize summaryDisplaySize = [summary sizeWithFont:summaryFont constrainedToSize:CGSizeMake(summaryWidth, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat verticalPadding = 11.0 + 7.0;
    CGFloat minimumCellHeight = 52.0;
    CGFloat calculatedCellHeight = summaryDisplaySize.height + verticalPadding;
    
    if (calculatedCellHeight > minimumCellHeight) {
        return calculatedCellHeight;
    } else {
        return minimumCellHeight;
    };
}

@end
