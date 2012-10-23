//
//  FSPOrganizationsAddSportsViewControllerCell.m
//  FoxSports
//
//  Created by Ed McKenzie on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationsAddSportsViewControllerCell.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPOrganizationsAddSportsViewControllerCell

@synthesize checkmarkView = _checkmarkView;
@synthesize label = _label;
@synthesize addTeamButton = _addTeamButton;
@synthesize indexPath = _anotherIndexPath;    // UITableViewCell already has a private _indexPath

- (void)awakeFromNib {
    self.label.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
	UIImage *bkg = [[UIImage imageNamed:@"Gray_disclosure_button_background"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
	[self.addTeamButton setBackgroundImage:bkg forState:UIControlStateNormal];
	
	[self.addTeamButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.addTeamButton.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12];
	self.addTeamButton.titleEdgeInsets = UIEdgeInsetsMake(6, 6, 4, 20);
//	self.addTeamButton.titleLabel.layer.borderColor = [UIColor greenColor].CGColor;
//	self.addTeamButton.titleLabel.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDisclosureText:(NSString *)text
{
	[self.addTeamButton setTitle:text forState:UIControlStateNormal];
	CGSize size = [text sizeWithFont:self.addTeamButton.titleLabel.font];
	UIEdgeInsets insets = self.addTeamButton.titleEdgeInsets;
	size.width += insets.left + insets.right;
	CGRect f = self.addTeamButton.frame;
	self.addTeamButton.frame = CGRectMake(CGRectGetMaxX(f) - size.width, f.origin.y, size.width, f.size.height);
}

@end
