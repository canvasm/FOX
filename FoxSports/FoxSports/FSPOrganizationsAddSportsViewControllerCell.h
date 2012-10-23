//
//  FSPOrganizationsAddSportsViewControllerCell.h
//  FoxSports
//
//  Created by Ed McKenzie on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPOrganizationsAddSportsTableCellCheckmarkView.h"

@interface FSPOrganizationsAddSportsViewControllerCell : UITableViewCell

@property (nonatomic, strong) IBOutlet FSPOrganizationsAddSportsTableCellCheckmarkView *checkmarkView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIButton *addTeamButton;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)setDisclosureText:(NSString *)text;

@end
