//
//  FSPPGALeaderBoardCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGALeaderBoardCell.h"
#import "FSPGolfer.h"
#import "FSPGolfRound.h"
#import "FSPPGAEvent.h"
#import "FSPPGAGolferDetailView.h"

@interface FSPPGALeaderBoardCell()

@property (strong, nonatomic) UINib *golferDetailNib;
@property (strong, nonatomic) FSPGolfer *golfer;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *thruLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *round1Label;
@property (weak, nonatomic) IBOutlet UILabel *round2Label;
@property (weak, nonatomic) IBOutlet UILabel *round3Label;
@property (weak, nonatomic) IBOutlet UILabel *round4Label;
@property (weak, nonatomic) IBOutlet UILabel *strokesLabel;

@end

@implementation FSPPGALeaderBoardCell

@synthesize golferDetailNib = _golferDetailNib;
@synthesize golfer = _golfer;
@synthesize scoreLabel = _scoreLabel;
@synthesize thruLabel = _thruLabel;
@synthesize todayLabel = _todayLabel;
@synthesize round1Label = _roundOneLabel;
@synthesize round2Label = _round2Label;
@synthesize round3Label = _round3Label;
@synthesize round4Label = _round4Label;
@synthesize strokesLabel = _strokesLabel;

- (void)awakeFromNib
{
    self.golferDetailNib = [UINib nibWithNibName:@"FSPPGAGolferDetailView" bundle:nil];
    
    [super awakeFromNib];
    
}

- (void)populateWithPlayer:(FSPPlayer *)player
{
    [super populateWithPlayer:player];
    
    self.golfer = (FSPGolfer *)player;
        
    self.positionLabel.text = [self.golfer.place stringValue];
    
    NSString *scoreLabelText = @"--";
    if ([self.golfer.thruHole intValue] > 0) {
        scoreLabelText = [self.golfer.totalScore stringValue];
    }
    self.scoreLabel.text = scoreLabelText;
    
    
    // Still appearing as --
    NSString *throughLabelText = @"--";
    if ([self.golfer.thruHole intValue] != 0) {
        if ([[self.golfer.thruHole stringValue] isEqualToString:@"18"]) {
            throughLabelText = @"F";
        } else {
            throughLabelText = [self.golfer.thruHole stringValue];
        }
    }
    self.thruLabel.text = throughLabelText;
    
    NSString *todayLabelText = @"--";
    if ([self.golfer.todayScore intValue] > 0) {
        todayLabelText = [self.golfer.todayScore stringValue];
    }
    self.todayLabel.text = todayLabelText;
    
    NSString *defaultRoundText = @"--";
    self.round1Label.text = [self roundForNumber:@1] ? [self roundForNumber:@1] : defaultRoundText;
    self.round2Label.text = [self roundForNumber:@2] ? [self roundForNumber:@2] : defaultRoundText;
    self.round3Label.text = [self roundForNumber:@3] ? [self roundForNumber:@3] : defaultRoundText;
    self.round4Label.text = [self roundForNumber:@4] ? [self roundForNumber:@4] : defaultRoundText;
    
    // Still appearing as --
    NSString *strokesText = @"--";
    if (self.golfer.golfEvent.eventStarted && [self.golfer.totalStrokes intValue] > 0) {
        strokesText = [self.golfer.totalStrokes stringValue];
    }
    self.strokesLabel.text = strokesText;
}

- (void)setDisclosureViewVisible:(BOOL)visible
{    
    if (visible) {
        NSArray *topLevelObjects = [self.golferDetailNib instantiateWithOwner:self options:nil];
        FSPPGAGolferDetailView *golferDetailView;
        for (UIView *view in topLevelObjects) {
            if ([view isKindOfClass:[FSPPGAGolferDetailView class]]) {
                golferDetailView = [topLevelObjects objectAtIndex:[topLevelObjects indexOfObject:view]];
            }
        }
        CGFloat leftMargin = 6.0;
        golferDetailView.frame = CGRectMake(leftMargin, [FSPPGALeaderBoardCell unselectedRowHeight], golferDetailView.frame.size.width, golferDetailView.frame.size.height);
        [golferDetailView populateWithGolfer:self.golfer];
        [self.contentView addSubview:golferDetailView];
    }
    
    [super setDisclosureViewVisible:visible];
}

- (void)setLabelFonts
{
    [super setLabelFonts];
}

- (NSString *)roundForNumber:(NSNumber *)number
{
    for (FSPGolfRound *golfRound in self.golfer.rounds) {
        if ([golfRound.round isEqualToNumber:number]) {
            return [golfRound.strokes stringValue];
        }
    }
    return nil;
}

- (Class)playerDetailViewClass
{
    return [FSPPGAGolferDetailView class];
}

+ (CGFloat)minimumRowHeight
{
    return 134.0;
}

+ (CGFloat)playerDetailViewHeight
{
    return 118.0;
}

@end
