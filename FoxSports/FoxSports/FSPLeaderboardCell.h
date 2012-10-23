//
//  FSPNASCARLeaderboardCell.h
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPPlayer;

@interface FSPLeaderboardCell : UITableViewCell

@property (strong, nonatomic) FSPPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *toggleIndicatorImageView;

/*!
 @abstract Styles the labels with proper font and text color
 */
- (void)setLabelFonts;

/*!
 @abstract Populates a FSPLeaderboardCell instance with data from the FSPPlayer passed in.
 @param player The player to populate the cell with.
 @discussion Subclasses must implement this method.
 */
- (void)populateWithPlayer:(FSPPlayer *)player;

/*!
 @abstract Sets the cell's player detail view visible.
 @param visible The visibility of the player detail view
 @discussion This is only valid for iPad and needs to be overridden by subclasses.
 */
- (void)setDisclosureViewVisible:(BOOL)visible;

/*!
 @abstract Returns the class of the player detail view that is revealed when opening up the cell.
 @return The class of the player detail view that is revealed when opening up the cell
 @discussion Used to remove the view from the superview when closing the cell. Should be overridden by subclasses.
 */
- (Class)playerDetailViewClass;

/*!
 @abstract Returns the height the row should be when it is unselected and closed.
 @discussion Used for figuring out the height the cell should be in the table view delegate's heightForRowAtIndexPath method.
 */
+ (CGFloat)unselectedRowHeight;


/*!
 @abstract Returns the smallest height the row can be.
 @discussion Used for figuring out the height the cell should be in the table view delegate's heightForRowAtIndexPath method.
 */
+ (CGFloat)minimumRowHeight;

/*!
 @abstract Returns the height of the player detail view inside the cell.
 @discussion Used for figuring out the height the cell should be in the table view delegate's heightForRowAtIndexPath method.
 */
+ (CGFloat)playerDetailViewHeight;

@end
