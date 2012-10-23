//
//  FSPNHLLeagueScheduleHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLLeagueScheduleHeaderView.h"

@implementation FSPNHLLeagueScheduleHeaderView

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"FSPNHLLeagueScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

+ (CGFloat)headerHeght
{
    return 60;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
	[super setEvent:event];
    
	if (!self.isFuture) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.columnOneLabel.text = @"Top Performer";
			self.columnTwoLabel.hidden = YES;
			self.columnThreeLabel.hidden = YES;
		} else {
			self.columnOneLabel.hidden = YES;
			self.columnTwoLabel.hidden = YES;
			self.columnThreeLabel.hidden = YES;
		}
	}
}

@end
