//
//  FSPMLBPlayByPlayFooterView.m
//  FoxSports
//
//  Created by greay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPlayByPlayFooterCell.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

CGFloat const FSPPlayByPlayFooterHeight = 35;


@interface FSPMLBPlayByPlayFooterCell ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation FSPMLBPlayByPlayFooterCell
@synthesize title = _title;
@synthesize textLabel;

- (void)setTitle:(NSString *)title
{
    self.textLabel.textColor = [UIColor fsp_yellowColor];
    self.textLabel.text = title;
    self.textLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
    self.textLabel.backgroundColor = [UIColor clearColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.bounds.size.width-20, self.bounds.size.height)];
        [self addSubview:self.textLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
