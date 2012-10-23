//
//  FSPMLBLeagueScheduleHeaderView.m
//  FoxSports
//
//  Created by Chase Latta on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBLeagueScheduleHeaderView.h"

@implementation FSPMLBLeagueScheduleHeaderView

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPMLBLeagueScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}


- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];

	if (!self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.columnOneLabel.text = @"WIN";
			self.columnTwoLabel.text = @"LOSS";
			self.columnThreeLabel.text = @"SAVE";
			self.columnThreeLabel.hidden = NO;
		} else {
			self.columnOneLabel.hidden = YES;
			self.columnTwoLabel.hidden = YES;
			self.columnThreeLabel.hidden = YES;
		}
	}
}

@end
