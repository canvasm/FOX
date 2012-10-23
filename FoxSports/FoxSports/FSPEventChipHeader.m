//
//  FSPEventChipHeader.m
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventChipHeader.h"
#import "FSPEventChipCell.h"
#import "FSPEvent.h"
#import "NSDate+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"
#import "FSPLabel.h"

@interface FSPEventChipHeader ()
@property (nonatomic, weak) IBOutlet FSPLabel *networkLabel;
@property (nonatomic, weak) IBOutlet FSPLabel *gameStateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *playImageView;
@property (nonatomic, weak) IBOutlet UIView *nowPlayingContainer;
@property (nonatomic, weak) IBOutlet FSPLabel *nowPlayingLabel;
@end

@implementation FSPEventChipHeader
@synthesize networkLabel = _networkLabel;
@synthesize gameStateLabel = _gameStateLabel;
@synthesize playImageView = _playImageView;
@synthesize streamable = _streamable;
@synthesize inProgress = _inProgress;
@synthesize completed = _completed;
@synthesize nowPlayingContainer = _nowPlayingContainer;
@synthesize nowPlayingLabel = _nowPlayingLabel;
@synthesize labelsToToggleOnSelection = _labelsToToggleOnSelection;
@synthesize selected = _selected;

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"FSPEventChipHeader" bundle:nil];
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    self = [nibObjects lastObject];
    
    if(!self) return nil;

    self.frame = frame;
    self.streamable = YES;
    self.inProgress = YES;
    return self;
}

- (void)awakeFromNib
{
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12];
    self.networkLabel.font = font;
    self.networkLabel.text = @"";
    self.networkLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.networkLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];

    self.gameStateLabel.font = font;
    self.gameStateLabel.text = @"";
    self.gameStateLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.gameStateLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    
    self.nowPlayingLabel.font = font;
    self.nowPlayingLabel.text = @"NOW PLAYING";
    self.nowPlayingLabel.backgroundColor = [UIColor clearColor];
    self.nowPlayingLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.nowPlayingLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    
    CGPoint centerPoint = self.nowPlayingContainer.center;
    centerPoint.y -= 3.0f;
    centerPoint.x -= 5.0f;
    self.nowPlayingLabel.center = centerPoint;
    self.nowPlayingLabel.frame = CGRectIntegral(self.nowPlayingLabel.frame);
    self.nowPlayingLabel.shadowColor = [UIColor clearColor];
    
    self.nowPlayingContainer.layer.borderColor = [UIColor colorWithRed:0/255.0 green:69/255.0 blue:133/255.0 alpha:1.0].CGColor;
    self.nowPlayingContainer.layer.borderWidth = 1.0;
    self.nowPlayingContainer.layer.cornerRadius = 4.0;
}

- (void)setStreamable:(BOOL)streamable;
{
    if (_streamable != streamable) {
        _streamable = streamable;
        [self setNeedsLayout];
    }
}

- (void)setInProgress:(BOOL)inProgress;
{
    if (_inProgress != inProgress) {
        _inProgress = inProgress;
        [self setNeedsLayout];
    }
}

- (void)setCompleted:(BOOL)completed;
{
    if(_completed != completed)
    {
        _completed = completed;
        [self setNeedsLayout];
    }
}

- (void)populateWithEvent:(FSPEvent *)event;
{
    BOOL gameInProgress = [event.eventStarted boolValue];
    BOOL eventCompleted = [event.eventCompleted boolValue];
    BOOL inOvertime = [event isOvertime];
    self.inProgress = gameInProgress && !eventCompleted;
    self.completed = eventCompleted;
    self.streamable = [event.streamable boolValue];
    self.networkLabel.text = event.channelDisplayName;
    
    self.gameStateLabel.text = event.eventState;
    
    if (gameInProgress) {
        self.gameStateLabel.text = event.timeStatus;
    } else if (eventCompleted) {
        self.gameStateLabel.text = event.eventState;
    } else {
        self.gameStateLabel.text = [event.startDate fsp_lowercaseMeridianDateString];
    }
    
    switch (event.viewType) {
        case FSPBaseballViewType:
            if (eventCompleted && inOvertime)
                self.gameStateLabel.text = [NSString stringWithFormat:@"%@ %d", self.gameStateLabel.text, event.numberOfOvertimes];
            break;
        case FSPBasketballViewType:
            if (gameInProgress && inOvertime) {
                self.gameStateLabel.text = [NSString stringWithFormat:@"OT%d %@", event.numberOfOvertimes, self.gameStateLabel.text];
            } else if (eventCompleted && inOvertime) {
                self.gameStateLabel.text = [NSString stringWithFormat:@"%@ %dOT", self.gameStateLabel.text, event.numberOfOvertimes];
            }
            break;
        case FSPHockeyViewType:
            if ((gameInProgress || eventCompleted) && inOvertime) {
                self.gameStateLabel.text = [NSString stringWithFormat:@"%@ OT", self.gameStateLabel.text];
            }
            break;
        case FSPNFLViewType:
        case FSPNCAAFViewType:
            if (gameInProgress && inOvertime)
                self.gameStateLabel.text = @"OT";
            break;
        default:
            break;
    }
    
    if (self.streamable) {
        if (self.inProgress)
            self.playImageView.image = [UIImage imageNamed:@"B_play_blue"];
        else
            self.playImageView.image = [UIImage imageNamed:@"B_play_gray"];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGFloat statusLabelX;
    if (self.streamable) {
        self.playImageView.hidden = NO;
        statusLabelX = CGRectGetMaxX(self.playImageView.frame) + 8.0;
    } else {
        statusLabelX = CGRectGetMinX(self.playImageView.frame);
        self.playImageView.hidden = YES;
    }
    CGRect frame = self.gameStateLabel.frame;
    frame.origin.x = statusLabelX;
    self.gameStateLabel.frame = frame;
    
    BOOL nowPlaying = self.selected && self.inProgress && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    self.nowPlayingContainer.hidden = !nowPlaying;
    self.playImageView.hidden = nowPlaying;
    self.gameStateLabel.hidden = nowPlaying;
}

@end
