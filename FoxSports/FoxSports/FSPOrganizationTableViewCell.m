//
//  FSPChannelTableViewCell.m
//  FoxSports
//
//  Created by Jason Whitford on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPOrganizationTableViewCell.h"
#import "FSPChannelCellSelectedBackgroundView.h"
#import "UIFont+FSPExtensions.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+FSPExtensions.h"

@implementation FSPOrganizationTableViewCell

@synthesize showsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        FSPChannelCellSelectedBackgroundView *selectedBackgroundView = [[FSPChannelCellSelectedBackgroundView alloc] init];
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			self.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16];
			self.textLabel.numberOfLines = 1;
		} else {
			self.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
			self.textLabel.numberOfLines = 2;
		}
		
        self.selectedBackgroundView = selectedBackgroundView;
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    UIBezierPath *topLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, self.bounds.size.height-2, self.bounds.size.width, 1.0f)];
    [[UIColor fsp_colorWithIntegralRed:12 green:12 blue:12 alpha:1.0] set];
    [topLine fill];

    UIBezierPath *bottomLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, self.bounds.size.height-1, self.bounds.size.width, 1.0f)];
    [[UIColor fsp_colorWithIntegralRed:51 green:51 blue:51 alpha:1.0] set];
    [bottomLine fill];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
	CGRect imageRect = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && imageRect.size.width > 48) {
		imageRect = CGRectMake(0, 0, 48, 48);
	}		

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !self.imageView.image &&
        [self.superview isKindOfClass:[UITableView class]] && !((UITableView *)self.superview).isEditing) {
        
		if (CGRectContainsRect(self.contentView.bounds, imageRect)) {
			imageRect.origin.x = floorf((self.contentView.bounds.size.width - imageRect.size.width) / 2);
			imageRect.origin.y = floorf((self.contentView.bounds.size.height - imageRect.size.height) / 2);
			self.imageView.frame = imageRect;
		} else {
			self.imageView.frame = self.contentView.bounds;
		}
		
		self.textLabel.frame = self.contentView.bounds;
		
		self.textLabel.textAlignment = UITextAlignmentCenter;

    } else {
    
        CGFloat iconWidth;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			iconWidth = 48;
		} else if (self.contentView.bounds.size.width < 100) {
			iconWidth = self.imageView.image.size.width + 10;
		} else {
			iconWidth = 100;
		}
		CGRect iconRect, labelRect;
		CGRectDivide(self.contentView.bounds, &iconRect, &labelRect, iconWidth, CGRectMinXEdge);
		if (CGRectContainsRect(self.contentView.bounds, imageRect)) {
			imageRect.origin.x = floorf((iconRect.size.width - imageRect.size.width) / 2);
			imageRect.origin.y = floorf((iconRect.size.height - imageRect.size.height) / 2);
		} else {
			imageRect = iconRect;
		}
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			imageRect.origin.x += 5;
			
			labelRect = CGRectInset(labelRect, 10, 0);
			labelRect.origin.y = 5;
			labelRect.size.height -= 5;
		}

		self.imageView.frame = imageRect;
		self.textLabel.frame = labelRect;
		
		self.textLabel.textAlignment = UITextAlignmentLeft;

	}
}

- (void)prepareForReuse;
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
