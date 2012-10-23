//
//  FSPVideoTableViewCell.h
//  FoxSports
//
//  Created by Stephen Spring on 6/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPVideoTableViewCell : UITableViewCell

/*!
 @abstract Use this method to populate the cell with videos.
 @param videos An array of FSPVideo objects (no more than three).
 */
-(void)configureWithVideos:(NSArray *)videos;

@end
