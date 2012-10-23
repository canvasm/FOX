//
//  FSPNBAPlayByPlayCell.h
//  FoxSports
//
//  Created by Jason Whitford on 2/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMaximumDescriptionLabelHeight 200.0 // Used for dynamically resizing descriptionLabel height.

@class FSPTeamColorLabel, FSPGamePlayByPlayItem;

@interface FSPPlayByPlayCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet FSPTeamColorLabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *playLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeScoreLabel;

@property (nonatomic, assign) BOOL showScore;

- (void)populateWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem;

/*!
 @abstract Returns the appropriate height for the cell and it's content.
 @param playByPlayItem The FSPGamePlayByPlayItem used to populat the cell with.
 @return Returns the appropriate height for the cell given the data passed in.
 @discussion Used to properly calculate the cell height so that there is room to properly display all of the content. Subclasses should override this method. Implementation values come from the cass' XIB file.
 */
+ (CGFloat)heightForCellWithPlayByPlayItem:(FSPGamePlayByPlayItem *)playByPlayItem;

@end
