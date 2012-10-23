//
//  FSPNFLTeamLeadersCell.m
//  FoxSports
//
//  Created by Stephen Spring on 7/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLTeamLeadersCell.h"
#import "FSPGameTopPlayerViewNFL.h"
#import "FSPFootballPlayer.h"

NSString * const FSPNFLTeamLeadersRowCellReuseIdentifier = @"FSPNFLTeamLeadersRowCellReuseIdentifier";
NSString * const FSPNFLTeamLeadersRowCellNibName = @"FSPNFLTeamLeadersCell";

@interface FSPNFLTeamLeadersCell()

@property (strong, nonatomic) FSPGameTopPlayerViewNFL *topPasserView;
@property (strong, nonatomic) FSPGameTopPlayerViewNFL *topRusherView;
@property (strong, nonatomic) FSPGameTopPlayerViewNFL *topReceiverView;

@end

@implementation FSPNFLTeamLeadersCell

@synthesize topPasserView = _topPasserView;
@synthesize topRusherView = _topRusherView;
@synthesize topReceiverView = _topReceiverView;
@synthesize players = _players;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)populateTopPerformers
{    
    if ([self.players count] > 0) {
        
        NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
                
        NSSortDescriptor *topPassersSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsPassing" ascending:NO];
        NSArray *topPassers = [self.players sortedArrayUsingDescriptors:@[topPassersSortDescriptor, lastNameSortDescriptor]];
        FSPFootballPlayer *topPasser = [topPassers objectAtIndex:0];
        if (topPasser.foxPointsPassing.intValue > 0) {
            NSArray *topPasserStatTypes = @[@"YPG", @"TD", @"INT", @"QB RAT"];
            NSArray *topPasserStatValues = @[topPasser.passingYards, topPasser.passingTouchdowns, topPasser.passingInterceptions, topPasser.quarterbackRating];
            [self.topPasserView populateWithPlayer:topPasser statTypes:topPasserStatTypes statValues:topPasserStatValues];
        }
        else {
            [self.topPasserView populateWithPlayer:nil statTypes:nil statValues:nil];
        }
        
        NSSortDescriptor *topRusherSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsRushing" ascending:NO];
        NSArray *topRushers = [self.players sortedArrayUsingDescriptors:@[topRusherSortDescriptor, lastNameSortDescriptor]];
        FSPFootballPlayer *topRusher = [topRushers objectAtIndex:0];
        if (topRusher.foxPointsRushing.intValue > 0) {
            NSArray *topRusherStatTypes = @[@"YPG", @"TD", @"LG", @"ATT"];
            NSArray *topRusherStatValues = @[topRusher.rushingYards, topRusher.rushingTouchdowns, topRusher.rushingLongestLength, topRusher.rusingAttempts];
            [self.topRusherView populateWithPlayer:topRusher statTypes:topRusherStatTypes statValues:topRusherStatValues];
        }
        else {
            [self.topRusherView populateWithPlayer:nil statTypes:nil statValues:nil];
        }
        
        NSSortDescriptor *topReceiverSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"foxPointsReceiving" ascending:NO];
        NSArray *topReceivers = [self.players sortedArrayUsingDescriptors:@[topReceiverSortDescriptor, lastNameSortDescriptor]];
        FSPFootballPlayer *topReceiver = [topReceivers objectAtIndex:0];
        if (topReceiver.foxPointsReceiving.intValue > 0) {
            NSArray *topReceiverStatTypes = @[@"YPG", @"TD", @"LG", @"REC"];
            NSArray *topReceiverStatValues = @[topReceiver.receptionYards, topReceiver.rushingTouchdowns, topReceiver.receptionLongestLength, topReceiver.receptions];
            [self.topReceiverView populateWithPlayer:topReceiver statTypes:topReceiverStatTypes statValues:topReceiverStatValues];
        }
        else {
            [self.topReceiverView populateWithPlayer:nil statTypes:nil statValues:nil];
        }
    }
    
    [self setTopPerformerFrames];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addTopPerformersViews];
}

- (void)addTopPerformersViews
{        
    self.topPasserView = [[FSPGameTopPlayerViewNFL alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    [self addSubview:self.topPasserView];
    
    self.topRusherView = [[FSPGameTopPlayerViewNFL alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    [self addSubview:self.topRusherView];
    
    self.topReceiverView = [[FSPGameTopPlayerViewNFL alloc] initWithDirection:FSPGamePlayerDirectionLeft];
    [self addSubview:self.topReceiverView]; 
    
    [self setTopPerformerFrames];
}

- (void)setTopPerformerFrames
{
    CGFloat topPerformerMargin;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        topPerformerMargin = 22.0f;
    } else {
        topPerformerMargin = 0.0f;
    }
    self.topPasserView.frame = CGRectMake(topPerformerMargin, 0.0f, [self topPerformerViewWidth], [FSPNFLTeamLeadersCell topPerformerViewHeight]);
    self.topRusherView.frame = CGRectMake(CGRectGetMaxX(self.topPasserView.frame), 0.0f, [self topPerformerViewWidth], [FSPNFLTeamLeadersCell topPerformerViewHeight]);
    self.topReceiverView.frame = CGRectMake(CGRectGetMaxX(self.topRusherView.frame), 0.0f, [self topPerformerViewWidth], [FSPNFLTeamLeadersCell topPerformerViewHeight]);
}

- (CGFloat)topPerformerViewWidth
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 216.0f;
    } else {
        return 106.0f;
    }
}

+ (CGFloat)topPerformerViewHeight
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 130.0f;
    } else {
        return 232.0f;
    }
}

- (void)populateWithPlayer:(FSPTeamPlayer *)player
{
    //Do Nothing
}

- (void)prepareForReuse
{
    [self.topPasserView populateWithPlayer:nil statTypes:nil statValues:nil];
    [self.topRusherView populateWithPlayer:nil statTypes:nil statValues:nil];
    [self.topReceiverView populateWithPlayer:nil statTypes:nil statValues:nil];
}

@end
