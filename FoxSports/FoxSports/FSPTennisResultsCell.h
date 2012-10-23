//
//  FSPTennisResultsCell.h
//  FoxSports
//
//  Created by greay on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPTennisMatch;

@interface FSPTennisResultsCell : UITableViewCell

- (void)populateWithMatch:(FSPTennisMatch *)match;

@end
