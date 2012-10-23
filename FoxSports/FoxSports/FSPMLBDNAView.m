//
//  FSPMLBDNAView.m
//  FoxSports
//
//  Created by Jeremy Eccles on 2012-10-17.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBDNAView.h"
#import "UIFont+FSPExtensions.h"

@interface FSPMLBDNAView ()

@end

@implementation FSPMLBDNAView

@synthesize _tableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPMLBDNAView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 89, 18)];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gt_mlb_gamedna_inningheader"]];
    CGRect frame = backgroundImageView.frame;
    frame.origin.y = 1;
    [backgroundImageView setFrame:frame];
    [headerView addSubview:backgroundImageView];

    UIImageView *topDividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gt_mlb_gamedna_horizontaldivider"]];
    [headerView addSubview:topDividerImageView];

    UIImageView *bottomDividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gt_mlb_gamedna_horizontaldivider"]];
    frame = bottomDividerImageView.frame;
    frame.origin.y = 17;
    [bottomDividerImageView setFrame:frame];
    [headerView addSubview:bottomDividerImageView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 83, 10)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:83/255.0 green:83/255.0 blue:83/255.0 alpha:1.0]];
    [titleLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:10]];
    [headerView addSubview:titleLabel];

    switch (section) {
        case 0:
            [titleLabel setText:@"9TH"];
            break;

        case 1:
            [titleLabel setText:@"8TH"];
            break;

        case 2:
            [titleLabel setText:@"7TH"];
            break;

        case 3:
            [titleLabel setText:@"6TH"];
            break;

        case 4:
            [titleLabel setText:@"5TH"];
            break;

        case 5:
            [titleLabel setText:@"4TH"];
            break;

        case 6:
            [titleLabel setText:@"3RD"];
            break;

        case 7:
            [titleLabel setText:@"2ND"];
            break;

        case 8:
            [titleLabel setText:@"1ST"];
            break;

        default:
            break;
    }

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return cell;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
