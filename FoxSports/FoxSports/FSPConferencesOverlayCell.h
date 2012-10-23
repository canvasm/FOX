//
//  FSPConferencesOverlayCell.h
//  FoxSports
//
//  Created by greay on 8/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPConferencesOverlayCell;
@class FSPOrganization;

@protocol FSPConferencesOverlayCellDelegate <NSObject>

- (void)cell:(FSPConferencesOverlayCell *)cell didSelectConference:(FSPOrganization *)conference;

@end



@interface FSPConferencesOverlayCell : UITableViewCell

@property (nonatomic, assign) id <FSPConferencesOverlayCellDelegate> delegate;

- (void)populateWithConferences:(NSArray *)conferences selected:(NSManagedObjectID *)selectedOrgID;
- (void)setButtonsTarget:(id)target action:(SEL)selector;


@end
