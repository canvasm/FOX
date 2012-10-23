//
//  FSPNASCARLeaderboardResultsCell.m
//  FoxSports
//
//  Created by Stephen Spring on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardResultsCell.h"
#import "FSPNASCARPlayerStandingsView.h"
#import "FSPImageFetcher.h"

NSString * const FSPNASCARLeaderboardResultsCellIdentifier = @"FSPNASCARLeaderboardResultsCellIdentifier";

@interface FSPNASCARLeaderboardResultsCell()

@property (weak, nonatomic) IBOutlet UIImageView *headshotImageView;
@property (strong, nonatomic) UINib *playerStandingsNib;

@end

@implementation FSPNASCARLeaderboardResultsCell

@synthesize headshotImageView = _headshotImageView;


- (void)awakeFromNib
{
    self.playerStandingsNib = [UINib nibWithNibName:@"FSPNASCARPlayerStandingsView" bundle:nil];

    [super awakeFromNib];
}

- (void)alignDisclosureIndicatorToNameLabel
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize nameSize = [self.playerNameLabel.text sizeWithFont:self.playerNameLabel.font constrainedToSize:CGSizeMake(123.0, self.playerNameLabel.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation];
        self.playerNameLabel.frame = CGRectMake(self.playerNameLabel.frame.origin.x, self.playerNameLabel.frame.origin.y, nameSize.width, self.playerNameLabel.frame.size.height);
        self.numberImageView.frame = CGRectMake(CGRectGetMaxX(self.playerNameLabel.frame) + 10.0, self.numberImageView.frame.origin.y, self.numberImageView.frame.size.width, self.numberImageView.frame.size.height);
        self.toggleIndicatorImageView.frame = CGRectMake(CGRectGetMaxX(self.numberImageView.frame) + 10.0, self.numberImageView.frame.origin.y, self.toggleIndicatorImageView.frame.size.width, self.toggleIndicatorImageView.frame.size.height);
    }
}

- (void)setDisclosureViewVisible:(BOOL)visible
{
    [super setDisclosureViewVisible:visible];
    
    if (visible) {
        NSArray *playerStandings = [self.driver.seasons allObjects];
        
        for (FSPRacingSeasonStats *stats in playerStandings) {
            NSArray *topLevelObjects = [self.playerStandingsNib instantiateWithOwner:self options:nil];
            FSPNASCARPlayerStandingsView *playerStandingsView = [topLevelObjects objectAtIndex:0];
            NSInteger playerStandingsViewIndex = [playerStandings indexOfObject:stats];
            CGFloat leftMargin = CGRectGetMaxX(self.headshotImageView.frame) + 6.0;
            CGFloat topMargin = 34.0;
            CGFloat playerStandingsViewY = (playerStandingsView.frame.size.height * playerStandingsViewIndex) + topMargin;
            playerStandingsView.frame = CGRectMake(leftMargin, playerStandingsViewY, playerStandingsView.bounds.size.width, playerStandingsView.bounds.size.height);
            [self.contentView addSubview:playerStandingsView];
            [playerStandingsView populateWithStats:stats];
        }
        
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:self.driver.photoURL]
                                           withCallback:^(UIImage *image) {
                                               if (image) {
                                                   self.headshotImageView.image = image;
                                               } else {
                                                   self.headshotImageView.image = [UIImage imageNamed:@"Default_Headshot_NASCAR"];
                                               }
                                           }];
    } else {        
        self.headshotImageView.image = nil;
    }
}

- (Class)playerDetailViewClass
{
    return [FSPNASCARPlayerStandingsView class];
}

+ (CGFloat)unselectedRowHeight
{
    return 34.0;
}

+ (CGFloat)minimumRowHeight
{
    return 134.0;
}

+ (CGFloat)playerDetailViewHeight
{
    return 82.0;
}

@end
