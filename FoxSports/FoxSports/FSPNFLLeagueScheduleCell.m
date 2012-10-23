//
//  FSPNFLLeagueScheduleCell.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLLeagueScheduleCell.h"
#import "FSPFootballGame.h"
#import "FSPTeam.h"
#import "FSPScheduleNFLGame.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailSectionDrawing.h"

static CGFloat const FSPLabelHeight = 21;

static CGFloat const FSPTopRowYOrigin = 5;

static CGFloat const FSPTopPasserHeaderX = 259;
static CGFloat const FSPTopRusherHeaderX = 397;
static CGFloat const FSPTopReceiverHeaderX = 525;

@interface FSPNFLLeagueScheduleCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *channelLabel;
@property (nonatomic, strong) UILabel *topReceivierLabel;
@property (nonatomic, strong) FSPScheduleNFLGame *footballGame;
@property (nonatomic, weak) IBOutlet UIView *gameContentView;
@end

@implementation FSPNFLLeagueScheduleCell

@synthesize dateLabel;
@synthesize timeLabel;
@synthesize channelLabel;
@synthesize topReceivierLabel;
@synthesize showDateHeader;
@synthesize footballGame;
@synthesize gameContentView;

+(NSDateFormatter *) scheduleCellDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE M/d/yy";
    });
    return formatter;
}

+ (CGFloat) heightForEvent:(FSPScheduleNFLGame *)game
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (game.showDateLabel) {
            return 60;
        }
        return 30;
    }
    else {
        if (game.showDateLabel) {
            return 129;
        }
        else {
            return 101;
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIColor *color = [UIColor fsp_colorWithIntegralRed:225 green:116 blue:0 alpha:1.0];
    self.dateLabel.font = font;
    self.dateLabel.textColor = color;
    self.dateLabel.hidden = YES;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dateLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = font;
    self.timeLabel.textColor = color;
    self.timeLabel.hidden = YES;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.timeLabel];
    
    self.channelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.channelLabel.font = font;
    self.channelLabel.textColor = color;
    self.channelLabel.hidden = YES;
    self.channelLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.channelLabel];
    
    self.topReceivierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topReceivierLabel.font = font;
    self.topReceivierLabel.textColor = color;
    self.topReceivierLabel.hidden = YES;
    self.topReceivierLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.topReceivierLabel];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {        
        self.dateLabel.frame = CGRectMake(self.col0Label.frame.origin.x, FSPTopRowYOrigin, self.col0Label.frame.size.width, FSPLabelHeight);
        self.channelLabel.frame = CGRectMake(self.col2Label.frame.origin.x, FSPTopRowYOrigin, self.col2Label.frame.size.width, FSPLabelHeight);
    }
}

- (void)layoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self pinViewToBottom:self.col0Label];
        [self pinViewToBottom:self.col1Label];
        [self pinViewToBottom:self.col2Label];
        [self pinViewToBottom:self.col3Label];
        self.dateLabel.frame = CGRectMake(self.col0Label.frame.origin.x, FSPTopRowYOrigin, self.col0Label.frame.size.width, FSPLabelHeight);
        self.timeLabel.frame = CGRectMake(self.col1Label.frame.origin.x, FSPTopRowYOrigin, self.col1Label.frame.size.width, FSPLabelHeight);
        self.channelLabel.frame = CGRectMake(self.col2Label.frame.origin.x, FSPTopRowYOrigin, self.col2Label.frame.size.width, FSPLabelHeight);
        self.topReceivierLabel.frame = CGRectMake(self.col3Label.frame.origin.x, FSPTopRowYOrigin, self.col3Label.frame.size.width, FSPLabelHeight);
    }
    else {
        [self pinViewToBottom:self.gameContentView];
    }
}

// This keeps the view on the bottom of the cell, regardless of cell height
- (void)pinViewToBottom:(UIView *)view
{
    CGRect newFrame = view.frame;
    newFrame.origin.y = CGRectGetMaxY(self.bounds) - view.frame.size.height;
    view.frame = newFrame;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIColor *shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];

    self.dateLabel.shadowColor = shadowColor;
    self.timeLabel.shadowColor = shadowColor;
    self.channelLabel.shadowColor = shadowColor;
    self.topReceivierLabel.shadowColor = shadowColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (rect.size.height/1 == 60) {
            CGRect halfHeightRect = rect;
            halfHeightRect.size.height = rect.size.height / 2;
            
            FSPDrawGrayWhiteDividerLine(context, halfHeightRect);
            
        }
    }
    else {
        if (rect.size.height/1 == 129) {
            CGRect headerRect = rect;
            headerRect.size.height = 28;
            FSPDrawGrayWhiteDividerLine(context, headerRect);
        }
    }
}

- (void)populateWithGame:(FSPScheduleNFLGame *)game;
{
	[super populateWithGame:game];
    self.footballGame = game;

	if (!self.isFuture) {
        
        NSString *awayTeamString = [game.homeTeam.primaryRank intValue] > 0 ? [NSString stringWithFormat:@"%@ %@ %@", game.awayTeam.primaryRank, game.awayTeamName, game.awayTeamScore] : [NSString stringWithFormat:@"%@ %@", game.awayTeamName, game.awayTeamScore];
        NSString *homeTeamString = [game.awayTeam.primaryRank intValue] > 0 ? [NSString stringWithFormat:@"%@ %@ %@", game.homeTeam.primaryRank, game.homeTeamName, game.homeTeamScore] : [NSString stringWithFormat:@"@ %@ %@", game.homeTeamName, game.homeTeamScore];
        
        if ([game.homeTeamScore intValue] > [game.awayTeamScore intValue]) {
            self.col0Label.text = [NSString stringWithFormat:@"%@, %@",homeTeamString, awayTeamString];
        }
        else {
            self.col0Label.text = [NSString stringWithFormat:@"%@ %@",awayTeamString, homeTeamString];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.col1Label.text = game.topGamePasserStats;
            self.col2Label.text = game.topGameRusherStats;
            self.col3Label.text = game.topGameReceiverStats;
        }
        else {
            self.col1Label.text = [NSString stringWithFormat:@"Top Passer: %@",game.topGamePasserStats];
            self.col2Label.text = [NSString stringWithFormat:@"Top Rusher: %@",game.topGameRusherStats];
            self.col3Label.text = [NSString stringWithFormat:@"Top Receiver: %@",game.topGameReceiverStats];
        }
        
        if (self.footballGame.showDateLabel) {
            self.dateLabel.hidden = NO;
            self.dateLabel.text = [[FSPNFLLeagueScheduleCell scheduleCellDateFormatter] stringFromDate:game.normalizedStartDate];
            self.timeLabel.hidden = NO;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.timeLabel.text = @"Top Passer";
                self.channelLabel.hidden = NO;
                self.channelLabel.text = @"Top Rusher";
                self.topReceivierLabel.hidden = NO;
                self.topReceivierLabel.text = @"Top Receiver";
            }
        }
        else {
            self.dateLabel.text = nil;
            self.dateLabel.hidden = YES;
            self.timeLabel.hidden = YES;
            self.channelLabel.hidden = YES;
            self.topReceivierLabel.hidden = YES;
        }
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // Handle case where the game label might wrap.  If this isn't done, then a one-line game label will not
            // line up properly with the time/tv info.
            CGSize labelSize = [self.col0Label.text sizeWithFont:self.col0Label.font constrainedToSize:CGSizeMake(148, MAXFLOAT)];
            self.col0Label.frame = CGRectMake(12, 9, 148, labelSize.height);
        }
        if (self.footballGame.showDateLabel) {
            self.dateLabel.hidden = NO;
            self.dateLabel.text = [[FSPNFLLeagueScheduleCell scheduleCellDateFormatter] stringFromDate:game.normalizedStartDate];
            self.timeLabel.hidden = NO;
            self.timeLabel.text = [NSString stringWithFormat:@"Time (%@)", [[NSTimeZone localTimeZone] abbreviation]];
            self.channelLabel.hidden = NO;
            self.channelLabel.text = @"Time/TV";
        }
        else {
            self.dateLabel.text = nil;
            self.dateLabel.hidden = YES;
            self.timeLabel.hidden = YES;
            self.channelLabel.hidden = YES;
            self.topReceivierLabel.hidden = YES;
        }
    }
}

- (void)updateSubviewPositions
{
    [super updateSubviewPositions];
    if (!self.isFuture) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //Lay out the cell for 3 labels
            CGRect topPasserFrame = self.col1Label.frame;
            topPasserFrame.origin.x = FSPTopPasserHeaderX;
            self.col1Label.frame = topPasserFrame;
            self.timeLabel.frame = topPasserFrame;
            
            CGRect topRusherFrame = self.col2Label.frame;
            topRusherFrame.origin.x = FSPTopRusherHeaderX;
            self.col2Label.frame = topRusherFrame;
            self.channelLabel.frame = topPasserFrame;
            
            CGRect topReceiverFrame = self.col3Label.frame;
            topReceiverFrame.origin.x = FSPTopReceiverHeaderX;
            self.col3Label.frame = topReceiverFrame;
            self.topReceivierLabel.frame = topReceiverFrame;
            
            self.col3Label.hidden = NO;
            self.topReceivierLabel.hidden = NO;
        }
        else {
            self.col2Label.frame = self.col1Label.frame;
            self.col2Label.frame = CGRectOffset(self.col1Label.frame, 0, self.col1Label.frame.size.height);
            self.col1Label.hidden = NO;
            self.col3Label.hidden = NO;
        }
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.col1Label.hidden = YES;
            self.col3Label.hidden = YES;
        }
    }
}

#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *label;
    if (self.isFuture) {
        label = [NSString stringWithFormat:@"%@, on %@, at %@", self.col0Label.text, self.col1Label.text, self.col2Label.text];
    } else {
        label = [NSString stringWithFormat:@"%@, top passer %@, top rusher %@, top receiver %@", self.col0Label.text, self.col1Label.text, self.col2Label.text, self.col3Label.text];
    }
    return label;
}

- (NSString *)gameDateStringFromGame:(FSPScheduleGame *)game;
{
    NSString *displayString;
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM:dd";
    });
    displayString = [[formatter stringFromDate:game.startDate] lowercaseString];
    
    return displayString;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dateLabel.text = nil;
    self.timeLabel.text = nil;
    self.channelLabel.text = nil;
    self.showDateHeader = NO;
    self.topReceivierLabel.text = nil;
}

@end
