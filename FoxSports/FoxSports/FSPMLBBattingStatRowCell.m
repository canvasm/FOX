//
//  FSPMLBStatRowCell.m
//  FoxSports
//
//  Created by Matthew Fay on 6/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBBattingStatRowCell.h"
#import "FSPBaseballPlayer.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"

NSString * const FSPMLBBattingStatRowCellReuseIdentifier = @"FSPMLBBattingStatRowCellReuseIdentifier";
NSString * const FSPMLBBattingStatRowCellNibName = @"FSPMLBBattingStatRowCell";

@interface FSPMLBBattingStatRowCell ()

@property (nonatomic, weak) IBOutlet UILabel * playerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * atBatInningPitchedLabel;
@property (nonatomic, weak) IBOutlet UILabel * runsLabel;
@property (nonatomic, weak) IBOutlet UILabel * hitsLabel;
@property (nonatomic, weak) IBOutlet UILabel * RBILabel;
@property (nonatomic, weak) IBOutlet UILabel * walkLabel;
@property (nonatomic, weak) IBOutlet UILabel * strikeOutLabel;
@property (nonatomic, weak) IBOutlet UILabel * stolenBaseLabel;
@property (nonatomic, weak) IBOutlet UILabel * battingAverageLabel;

@end

@implementation FSPMLBBattingStatRowCell {
    NSUInteger indent;
}

@synthesize playerNameLabel;
@synthesize atBatInningPitchedLabel;
@synthesize runsLabel;
@synthesize hitsLabel;
@synthesize RBILabel;
@synthesize walkLabel;
@synthesize strikeOutLabel;
@synthesize stolenBaseLabel;
@synthesize battingAverageLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPMLBBattingStatRowCellNibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

- (void)awakeFromNib
{
    CGFloat fontSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = 13.0f;
        indent = 22;
    } else {
        fontSize = 14.0f;
        indent = 50;
    }
    
    self.playerNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    UIColor *color = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.requiredLabels) {
        label.font = font;
        label.textColor = color;
    }
}

- (void)prepareForReuse
{
    self.playerNameLabel.text = nil;
    
    for (UILabel *label in self.requiredLabels) {
        label.text = nil;
    }
}

- (void)populateWithPlayer:(FSPTeamPlayer *)player
{
    if ([player isKindOfClass:[FSPBaseballPlayer class]]) {
        FSPBaseballPlayer * baseballPlayer = (FSPBaseballPlayer *)player;
        
        self.playerNameLabel.text = [NSString stringWithFormat:@"%@ %@", [player abbreviatedName], player.position];
        if (baseballPlayer.subBatting.boolValue) {
            self.playerNameLabel.frame = CGRectMake(indent, self.playerNameLabel.frame.origin.y, self.playerNameLabel.frame.size.width, self.playerNameLabel.frame.size.height);
        }
        
		//hitting stats
		self.atBatInningPitchedLabel.text = [[baseballPlayer atBats] fsp_stringValue];
		self.runsLabel.text = [[baseballPlayer runs] fsp_stringValue];
		self.hitsLabel.text = [[baseballPlayer hits] fsp_stringValue];
		self.RBILabel.text = [[baseballPlayer runsBattedIn] fsp_stringValue];
		self.walkLabel.text = [[baseballPlayer walks] fsp_stringValue];
		self.strikeOutLabel.text = [[baseballPlayer strikeOuts] fsp_stringValue];
		self.stolenBaseLabel.text = [[baseballPlayer stolenBases] fsp_stringValue];
		if ([[baseballPlayer battingAverage] floatValue] >= 0.0) {
			self.battingAverageLabel.text = [[NSString stringWithFormat:@"%.3f", [[baseballPlayer battingAverage] floatValue]] substringFromIndex:1];
		} else {
			self.battingAverageLabel.text = @"--";
		}
    }
}

@end
