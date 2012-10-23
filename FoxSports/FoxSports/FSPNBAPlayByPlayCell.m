//
//  FSPNBAPlayByPlayCell.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBAPlayByPlayCell.h"
#import "FSPGamePlayByPlayItem.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPNBAPlayByPlayCell

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
	[super populateWithPlayByPlayItem:playByPlayItem];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		CGRect descriptionFrame = self.descriptionLabel.frame;
		if ([playByPlayItem.abbreviatedSummary isEqualToString:@"--"]) {
			self.playLabel.hidden = YES;
			descriptionFrame.origin.y = 6;
		} else {
			self.playLabel.hidden = NO;
			descriptionFrame.origin.y = 27;
		}
		self.descriptionLabel.frame = descriptionFrame;
	}
}

+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem
{
    NSString *summary = playByPlayItem.summaryPhrase;
    CGFloat fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 14.0 : 13.0;
    UIFont *summaryFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    CGFloat summaryWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 366.0 : 172.0;
    CGSize summaryDisplaySize = [summary sizeWithFont:summaryFont constrainedToSize:CGSizeMake(summaryWidth, kMaximumDescriptionLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat verticalPadding = 9.0 + 1.0;
    CGFloat minimumCellHeight = 44.0;
    CGFloat calculatedCellHeight = summaryDisplaySize.height + verticalPadding;
    
    if (calculatedCellHeight > minimumCellHeight) {
        return calculatedCellHeight;
    } else {
        return minimumCellHeight;
    };
}

@end
