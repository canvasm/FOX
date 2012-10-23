//
//  FSPMLBStatRowCell.m
//  FoxSports
//
//  Created by Matthew Fay on 6/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBPitchingStatRowCell.h"
#import "FSPBaseballPlayer.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "NSNumber+FSPExtensions.h"

NSString * const FSPMLBPitchingStatRowCellReuseIdentifier = @"FSPMLBPitchingStatRowCellReuseIdentifier";
NSString * const FSPMLBPitchingStatRowCellNibName = @"FSPMLBPitchingStatRowCell";

@interface FSPMLBPitchingStatRowCell ()

@property (nonatomic, weak) IBOutlet UILabel * playerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * inningsPitchedLabel;
@property (nonatomic, weak) IBOutlet UILabel * runsLabel;
@property (nonatomic, weak) IBOutlet UILabel * hitsLabel;
@property (nonatomic, weak) IBOutlet UILabel * earnedRunsLabel;
@property (nonatomic, weak) IBOutlet UILabel * walkLabel;
@property (nonatomic, weak) IBOutlet UILabel * strikeOutLabel;
@property (nonatomic, weak) IBOutlet UILabel * pitchCountLabel;

@end

@implementation FSPMLBPitchingStatRowCell {
    NSUInteger indent;
}

@synthesize playerNameLabel;
@synthesize inningsPitchedLabel;
@synthesize runsLabel;
@synthesize hitsLabel;
@synthesize earnedRunsLabel;
@synthesize walkLabel;
@synthesize strikeOutLabel;
@synthesize pitchCountLabel;

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:FSPMLBPitchingStatRowCellNibName bundle:nil];
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
        
        self.playerNameLabel.text = [NSString stringWithFormat:@"%@ %@", [player abbreviatedName], [player position]];
        if (baseballPlayer.subPitching.boolValue) {
            self.playerNameLabel.frame = CGRectMake(indent, self.playerNameLabel.frame.origin.y, self.playerNameLabel.frame.size.width, self.playerNameLabel.frame.size.height);
        }
        
		//pitching stats
		self.inningsPitchedLabel.text = [baseballPlayer.inningsPitched fsp_stringValue];
		self.hitsLabel.text = [baseballPlayer.hitsAgainst fsp_stringValue];
		self.runsLabel.text = [baseballPlayer.runsAllowed fsp_stringValue];
		self.earnedRunsLabel.text = [baseballPlayer.earnedRuns fsp_stringValue];
		self.walkLabel.text = [baseballPlayer.walksThrown fsp_stringValue];
		self.strikeOutLabel.text = [baseballPlayer.strikeOutsThrown fsp_stringValue];

		self.pitchCountLabel.text = [baseballPlayer.pitchCount fsp_stringValue];
    }
}

@end
