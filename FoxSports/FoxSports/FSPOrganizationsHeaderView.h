//
//  FSPOrganizationsHeaderView.h
//  FoxSports
//
//  Created by Matthew Fay on 6/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FSPOrganizationsPersistentCellsSection = 0,
 	FSPOrganizationFavoritesSection,
    FSPOrganizationAllSection,
	FSPOrganizationChannelsSection,
    FSPOrganizationViewControllerSectionCount
};

@interface FSPOrganizationsHeaderView : UIView

@property (nonatomic, strong, readonly) UIImageView *star;

- (void)selectHeaderForSection:(int)section;

@end
