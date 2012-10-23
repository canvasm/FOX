//
//  FSPFightingStandingsCell.h
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FSPFightingStandingsCellReuseIdeintifier;

@interface FSPFightingStandingsCell : UITableViewCell

//The max number of fighters passed in should be 3
- (void)populateWithFighters:(NSArray *)fighters;

@end
