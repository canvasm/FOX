//
//  FSPOrganizationCustomizationViewController.h
//  FoxSports
//
//  Created by Chase Latta on 5/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSPOrganization;

@interface FSPOrganizationCustomizationViewController : UITableViewController

- (id)initWithOrganization:(FSPOrganization *)org;
// Pass yes if this displays teams only
- (id)initWithOrganization:(FSPOrganization *)org isShowingTeams:(BOOL)yesNo;

@end
