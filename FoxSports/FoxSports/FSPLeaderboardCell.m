//
//  FSPNASCARLeaderboardCell.m
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLeaderboardCell.h"
#import "FSPRacingPlayer.h"
#import "FSPNASCARPlayerStandingsView.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPRacingSeasonStats.h"
#import "FSPImageFetcher.h"

@interface FSPLeaderboardCell()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *iphoneStatsLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *eventValuesLabels;
@property (nonatomic) BOOL cellOpen;

@end

@implementation FSPLeaderboardCell

@synthesize player = _player;
@synthesize toggleIndicatorImageView = _toggleIndicatorImageView;
@synthesize positionLabel = _positionLabel;


@synthesize iphoneStatsLabels = _iphoneStatsLabels;
@synthesize playerNameLabel = _playerNameLabel;
@synthesize eventValuesLabels = _eventValuesLabels;
@synthesize cellOpen = _cellOpen;

- (void)awakeFromNib
{
    [self setLabelFonts];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}

- (void)populateWithPlayer:(FSPPlayer *)player
{
    self.player = player;
    self.playerNameLabel.text = [self playerName];
    
    [self alignDisclosureIndicatorToNameLabel];
}

- (void)alignDisclosureIndicatorToNameLabel
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize nameSize = [self.playerNameLabel.text sizeWithFont:self.playerNameLabel.font constrainedToSize:CGSizeMake(123.0, self.playerNameLabel.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation];
        self.playerNameLabel.frame = CGRectMake(self.playerNameLabel.frame.origin.x, self.playerNameLabel.frame.origin.y, nameSize.width, self.playerNameLabel.frame.size.height);
        self.toggleIndicatorImageView.frame = CGRectMake(CGRectGetMaxX(self.playerNameLabel.frame) + 10.0, self.playerNameLabel.frame.origin.y, self.toggleIndicatorImageView.frame.size.width, self.toggleIndicatorImageView.frame.size.height);
    }
}

- (NSString *)playerName
{
    NSString *playerName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        playerName = [NSString stringWithFormat:@"%@ %@", self.player.firstName, self.player.lastName];
    } else {
        NSString *firstNameFirstInitial = [self.player.firstName substringToIndex:1];
        playerName = [NSString stringWithFormat:@"%@ %@", firstNameFirstInitial, self.player.lastName];
    }
    return playerName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];  
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor fsp_blueCellColor];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setLabelFonts
{
    self.playerNameLabel.adjustsFontSizeToFitWidth = NO;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.playerNameLabel.textColor = [UIColor whiteColor];
        self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
        
        for (UILabel *label in _eventValuesLabels) {
            label.font = [UIFont fontWithName:FSPClearViewBoldFontName size:12.0];
            label.textColor = [UIColor fsp_lightBlueColor];
        }
    } else {
        UIColor *blueLabelColor = [UIColor fsp_lightBlueColor];
        self.playerNameLabel.textColor = [UIColor whiteColor];
        self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];

        for (UILabel *label in _iphoneStatsLabels) {
            label.font = [UIFont fontWithName:FSPClearViewMediumFontName size:14.0];
            label.textColor = blueLabelColor;
        }
    } 
}

- (void)setDisclosureViewVisible:(BOOL)visible
{
    if (visible) {
        self.cellOpen = YES;
        self.contentView.backgroundColor = [UIColor fsp_blueCellColor];
        self.toggleIndicatorImageView.image = [UIImage imageNamed:@"nascar_up_arrow"];
    }
    
    else {
        self.cellOpen = NO;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.toggleIndicatorImageView.image = [UIImage imageNamed:@"nascar_down_arrow"];

        for (UIView *view in [self.contentView subviews]) {
            if ([view isKindOfClass:[self playerDetailViewClass]]) {
                [view removeFromSuperview];
            }
        }
    }
    
    [self sizeToFit];
}

- (Class)playerDetailViewClass
{
    return nil;
}

#pragma mark - Class Methods

+ (CGFloat)unselectedRowHeight
{
    return 34.0;
}

+ (CGFloat)minimumRowHeight
{
    return 44.0;
}

+ (CGFloat)playerDetailViewHeight
{
    return 0.0;
}

@end
