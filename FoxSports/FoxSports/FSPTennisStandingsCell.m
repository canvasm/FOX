//
//  FSPTennisStandingsCell.m
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisStandingsCell.h"
#import "FSPTennisSeasonStats.h"
#import "FSPImageFetcher.h"
#import "UIFont+FSPExtensions.h"

@interface FSPTennisStandingsCell ()

@property (nonatomic, weak) IBOutlet UILabel * rankLabel;
@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * earningsLabel;
@property (nonatomic, weak) IBOutlet UIImageView * flagView;

@end

@implementation FSPTennisStandingsCell
@synthesize rankLabel;
@synthesize nameLabel;
@synthesize pointsLabel;
@synthesize earningsLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (void)populateWithStats:(FSPTennisSeasonStats *)stats;
{
    self.rankLabel.text = stats.rank.stringValue;
    self.nameLabel.text = stats.playerName;
    self.pointsLabel.text = stats.points.stringValue;
    self.earningsLabel.text = [NSString stringWithFormat:@"$%@",stats.earnings.stringValue];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:stats.flagURL]
                                           withCallback:^(UIImage *image) {
                                               self.flagView.image = image;
                                           }];
    }
}


@end
