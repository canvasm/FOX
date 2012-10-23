//
//  FSPSoccerMatchStatsCell.m
//  FoxSports
//
//  Created by Matthew Fay on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerMatchStatsCell.h"
#import "FSPSoccerGame.h"
#import "FSPSoccerGoal.h"
#import "FSPSoccerCard.h"
#import "FSPSoccerSub.h"
#import "FSPSoccerPlayer.h"
#import "FSPStatIndicatorView.h"
#import "FSPGameDetailSectionHeader.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

const CGFloat FSPGoalHeight = 40.0f;
const CGFloat FSPCardHeight = 40.0f;
const CGFloat FSPSubsHeight = 60.0f;
const CGFloat FSPStatsHeight = 30.0f;
const CGFloat FSPCenterWidthIpad = 111;
const CGFloat FSPCenterWidthIphone = 80;
const CGFloat FSPHeaderHeightIphone = 25;

const NSUInteger FSPLeftAlignImageIpad = 23;
const NSUInteger FSPLeftAlignImageIphone = 8;
const NSUInteger FSPLeftAlignTimeIpad = 56;
const NSUInteger FSPLeftAlignTimeIphone = 30;
const NSUInteger FSPLeftAlignNameIpad = 87;
const NSUInteger FSPLeftAlignNameIphone = 55;

const NSUInteger FSPRightAlignImageIpad = 608;
const NSUInteger FSPRightAlignImageIphone = 289;
const NSUInteger FSPRightAlignTimeIpad = 571;
const NSUInteger FSPRightAlignTimeIphone = 265;
const NSUInteger FSPRightAlignNameIpad = 403;
const NSUInteger FSPRightAlignNameIphone = 160;

@implementation FSPSoccerMatchStatsCell

+ (CGFloat)heightForSoccerGame:(FSPSoccerGame *)game atIndex:(NSUInteger)idx
{
    CGFloat height = 0;
    switch (idx) {
        case 0:
            height += ((game.homeGoals.count > game.awayGoals.count ? game.homeGoals.count : game.awayGoals.count) * FSPGoalHeight);
            if (height == 0) height = FSPGoalHeight;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) height += FSPHeaderHeightIphone;
            break;
            
        case 1:
            height += ((game.homeCards.count > game.awayCards.count ? game.homeCards.count : game.awayCards.count) * FSPCardHeight);
            if (height == 0) height = FSPCardHeight;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) height += FSPHeaderHeightIphone;
            break;
            
        case 2:
            height += ((game.homeSubs.count > game.awaySubs.count ? game.homeSubs.count : game.awaySubs.count) * FSPSubsHeight);
            if (height == 0) height = FSPSubsHeight;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) height += FSPHeaderHeightIphone;
            break;
            
        case 3:
            height = 215;
            break;
            
        default:
            height = 0;
            break;
    }
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)populateCellWithIndex:(NSUInteger)idx forSoccerGame:(FSPSoccerGame *)game
{
    //center divider
    [self centerDividerForGame:game forIndex:idx];
    
    switch (idx) {
        case 0:
            //Goals
            [self populateCellWithGoalsFromGame:game];
            break;
            
        case 1:
            //Cards
            [self populateCellWithCardsFromGame:game];
            break;
            
        case 2:
            //Subs
            [self populateCellWithSubsFromGame:game];
            break;
            
        case 3:
            //Stats
            [self populateCellWithMatchStatsFromGame:game];
            break;
            
        default:
            break;
    }
}

- (void)centerDividerForGame:(FSPSoccerGame *)game forIndex:(NSUInteger)idx
{
    BOOL isIpad;
    UIView *center;
    NSUInteger centerAdjust = 0;
    CGFloat cellHeight = [FSPSoccerMatchStatsCell heightForSoccerGame:game atIndex:idx];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isIpad = YES;
        center = [[UIView alloc] init];
        center.backgroundColor = [UIColor fsp_colorWithIntegralRed:124 green:183 blue:255 alpha:0.1f];
        [self addSubview:center];
        center.frame = CGRectMake(269, 0, FSPCenterWidthIpad, cellHeight-2);
    } else {
        isIpad = NO;
        center = self;
        centerAdjust = 120;
        FSPGameDetailSectionHeader *header = [[FSPGameDetailSectionHeader alloc]init];
        [center addSubview:header];
        header.frame = CGRectMake(0, 0, self.frame.size.width, 25);
    }
    
    if (idx == 3) {
        for (NSUInteger i = 0; i < 6; ++i) {
            UILabel *title = [[UILabel alloc] init];
            title.adjustsFontSizeToFitWidth = YES;
            title.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0f];
            title.textAlignment = UITextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor fsp_lightBlueColor];
            switch (i) {
                case 0:
                    title.text = @"Goals";
                    break;
                case 1:
                    title.text = @"Assists";
                    break;
                case 2:
                    title.text = @"Shots";
                    break;
                case 3:
                    title.text = @"Shots on Goal";
                    break;
                case 4:
                    title.text = @"Saves";
                    break;
                case 5:
                    title.text = @"Corner Kicks";
                    break;
                    
                default:
                    break;
            }
            [center addSubview:title];
            title.frame = CGRectMake(centerAdjust, (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 27, isIpad ? FSPCenterWidthIpad : FSPCenterWidthIphone, 20);
        }
    } else {
        UILabel *title = [[UILabel alloc] init];
        title.textAlignment = UITextAlignmentCenter;
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0f];
        title.textColor = [UIColor fsp_lightBlueColor];
        
        switch (idx) {
            case 0:
                title.text = @"Goals";
                break;
                
            case 1:
                title.text = @"Cards";
                break;
                
            case 2:
                title.text = @"Substitutions";
                break;
                
            default:
                break;
        }
        
        [center addSubview:title];
        title.frame = CGRectMake(0, isIpad ? (cellHeight / 2) - 10 : 5, isIpad ? FSPCenterWidthIpad : self.frame.size.width, 20);
    }
}

- (void)populateCellWithGoalsFromGame:(FSPSoccerGame *)game
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSUInteger goals = 0;
    NSArray *goalsScored;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"minute" ascending:YES];
    goalsScored = [game.awayGoals sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerGoal *goal in goalsScored) {
        //Image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soccer_ball"]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPLeftAlignImageIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 19, 19);
        else
            imageView.frame = CGRectMake(FSPLeftAlignImageIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 19, 19);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", goal.minute];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //Name
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", goal.goalScorer.firstName, goal.goalScorer.lastName];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        if (isIpad) {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            nameLabel.frame = CGRectMake(FSPLeftAlignNameIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 159, 20);
        } else {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            nameLabel.frame = CGRectMake(FSPLeftAlignNameIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        goals++;
    }
    
    goals = 0;
    goalsScored = [game.homeGoals sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerGoal *goal in goalsScored) {
        //Image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soccer_ball"]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPRightAlignImageIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 19, 19);
        else
            imageView.frame = CGRectMake(FSPRightAlignImageIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 19, 19);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", goal.minute];
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //Name
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", goal.goalScorer.firstName, goal.goalScorer.lastName];
        nameLabel.textAlignment = UITextAlignmentRight;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        if (isIpad) {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            nameLabel.frame = CGRectMake(FSPRightAlignNameIpad, (FSPGoalHeight * goals) + (FSPGoalHeight / 4), 159, 20);
        } else {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            nameLabel.frame = CGRectMake(FSPRightAlignNameIphone, (FSPGoalHeight * goals) + (FSPGoalHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        goals++;
    }
}

- (void)populateCellWithCardsFromGame:(FSPSoccerGame *)game
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSUInteger cards = 0;
    NSArray *carded;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"minute" ascending:YES];
    carded = [game.awayCards sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerCard *card in carded) {
        //Image
        NSString *imageType;
        if ([card.cardType isEqualToString:FSPRedCard])
            imageType = @"red_card";
        else if ([card.cardType isEqualToString:FSPYellowCard])
            imageType = @"yellow_card";
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageType]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPLeftAlignImageIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 19, 19);
        else
            imageView.frame = CGRectMake(FSPLeftAlignImageIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 19, 19);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", card.minute];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //Name
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", card.player.firstName, card.player.lastName];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        if (isIpad) {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            nameLabel.frame = CGRectMake(FSPLeftAlignNameIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 159, 20);
        } else {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            nameLabel.frame = CGRectMake(FSPLeftAlignNameIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        cards++;
    }
    
    cards = 0;
    carded = [game.homeCards sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerCard *card in carded) {
        //Image
        NSString *imageType;
        if ([card.cardType isEqualToString:FSPRedCard])
            imageType = @"red_card";
        else if ([card.cardType isEqualToString:FSPYellowCard])
            imageType = @"yellow_card";
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageType]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPRightAlignImageIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 19, 19);
        else
            imageView.frame = CGRectMake(FSPRightAlignImageIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 19, 19);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", card.minute];
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //Name
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", card.player.firstName, card.player.lastName];
        nameLabel.textAlignment = UITextAlignmentRight;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        if (isIpad) {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            nameLabel.frame = CGRectMake(FSPRightAlignNameIpad, (FSPCardHeight * cards) + (FSPCardHeight / 4), 159, 20);
        } else {
            nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            nameLabel.frame = CGRectMake(FSPRightAlignNameIphone, (FSPCardHeight * cards) + (FSPCardHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        cards++;
    }
}

- (void)populateCellWithSubsFromGame:(FSPSoccerGame *)game
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    NSUInteger subs = 0;
    NSArray *substitutions;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"minute" ascending:YES];
    substitutions = [game.awaySubs sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerSub *sub in substitutions) {
        //Image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_arrow"]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPLeftAlignImageIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 19, 38);
        else
            imageView.frame = CGRectMake(FSPLeftAlignImageIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 19, 38);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", sub.minute];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPLeftAlignTimeIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //In Player
        UILabel *inNameLabel = [[UILabel alloc] init];
        inNameLabel.adjustsFontSizeToFitWidth = YES;
        inNameLabel.text = [NSString stringWithFormat:@"%@ %@", sub.inPlayer.firstName, sub.inPlayer.lastName];
        inNameLabel.backgroundColor = [UIColor clearColor];
        inNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:inNameLabel];
        if (isIpad) {
            inNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            inNameLabel.frame = CGRectMake(FSPLeftAlignNameIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 159, 20);
        } else {
            inNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            inNameLabel.frame = CGRectMake(FSPLeftAlignNameIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        //Out Player
        UILabel *outNameLabel = [[UILabel alloc] init];
        outNameLabel.adjustsFontSizeToFitWidth = YES;
        outNameLabel.text = [NSString stringWithFormat:@"%@ %@", sub.outPlayer.firstName, sub.outPlayer.lastName];
        outNameLabel.backgroundColor = [UIColor clearColor];
        outNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:outNameLabel];
        if (isIpad) {
            outNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            outNameLabel.frame = CGRectMake(FSPLeftAlignNameIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 2) + 4, 159, 20);
        } else {
            outNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            outNameLabel.frame = CGRectMake(FSPLeftAlignNameIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 2) + 4 + FSPHeaderHeightIphone, 105, 20);
        }
        
        subs++;
    }
    
    subs = 0;
    substitutions = [game.homeSubs sortedArrayUsingDescriptors:@[sort]];
    for (FSPSoccerSub *sub in substitutions) {
        //Image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_arrow"]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        if (isIpad)
            imageView.frame = CGRectMake(FSPRightAlignImageIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 19, 38);
        else
            imageView.frame = CGRectMake(FSPRightAlignImageIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 19, 38);
        
        //Time
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@'", sub.minute];
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor fsp_yellowColor];
        [self addSubview:timeLabel];
        if (isIpad) {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 24, 20);
        } else {
            timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            timeLabel.frame = CGRectMake(FSPRightAlignTimeIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 24, 20);
        }
        
        //In Player
        UILabel *inNameLabel = [[UILabel alloc] init];
        inNameLabel.adjustsFontSizeToFitWidth = YES;
        inNameLabel.text = [NSString stringWithFormat:@"%@ %@", sub.inPlayer.firstName, sub.inPlayer.lastName];
        inNameLabel.textAlignment = UITextAlignmentRight;
        inNameLabel.backgroundColor = [UIColor clearColor];
        inNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:inNameLabel];
        if (isIpad) {
            inNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            inNameLabel.frame = CGRectMake(FSPRightAlignNameIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 4), 159, 20);
        } else {
            inNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            inNameLabel.frame = CGRectMake(FSPRightAlignNameIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 4) + FSPHeaderHeightIphone, 105, 20);
        }
        
        //Out Player
        UILabel *outNameLabel = [[UILabel alloc] init];
        outNameLabel.adjustsFontSizeToFitWidth = YES;
        outNameLabel.text = [NSString stringWithFormat:@"%@ %@", sub.outPlayer.firstName, sub.outPlayer.lastName];
        outNameLabel.textAlignment = UITextAlignmentRight;
        outNameLabel.backgroundColor = [UIColor clearColor];
        outNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:outNameLabel];
        if (isIpad) {
            outNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
            outNameLabel.frame = CGRectMake(FSPRightAlignNameIpad, (FSPSubsHeight * subs) + (FSPSubsHeight / 2) + 4, 159, 20);
        } else {
            outNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:13.0f];
            outNameLabel.frame = CGRectMake(FSPRightAlignNameIphone, (FSPSubsHeight * subs) + (FSPSubsHeight / 2) + 4 + FSPHeaderHeightIphone, 105, 20);
        }
        
        subs++;
    }
}

- (void)populateCellWithMatchStatsFromGame:(FSPSoccerGame *)game
{
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0f];
    
    if (isIpad) {
        UIView *titleLine = [[UIView alloc] init];
        titleLine.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        [self addSubview:titleLine];
        titleLine.frame = CGRectMake(0, 20, 650, 1);
    }
    
    UILabel *totAway = [[UILabel alloc] init];
    totAway.text = [NSString stringWithFormat:@"TOT"];
    totAway.font = font;
    totAway.textAlignment = UITextAlignmentLeft;
    totAway.backgroundColor = [UIColor clearColor];
    totAway.textColor = [UIColor fsp_lightMediumBlueColor];
    [self addSubview:totAway];
    if (isIpad)
        totAway.frame = CGRectMake(232, 2, 30, 20);
    else
        totAway.frame = CGRectMake(94, 4, 30, 20);
    
    UILabel *totHome = [[UILabel alloc] init];
    totHome.text = [NSString stringWithFormat:@"TOT"];
    totHome.font = font;
    totHome.textAlignment = UITextAlignmentRight;
    totHome.backgroundColor = [UIColor clearColor];
    totHome.textColor = [UIColor fsp_lightMediumBlueColor];
    [self addSubview:totHome];
    if (isIpad)
        totHome.frame = CGRectMake(388, 2, 30, 20);
    else
        totHome.frame = CGRectMake(196, 4, 30, 20);
    
    for (NSUInteger i = 0; i < 6; i++) {
        UILabel * awayNumStat = [[UILabel alloc] init];
        awayNumStat.text = [NSString stringWithFormat:@"%@", [self statForGame:game forIndex:i isHome:NO]];
        awayNumStat.font = font;
        awayNumStat.textAlignment = UITextAlignmentCenter;
        awayNumStat.backgroundColor = [UIColor clearColor];
        awayNumStat.textColor = [UIColor fsp_lightMediumBlueColor];
        [self addSubview:awayNumStat];
        if (isIpad)
            awayNumStat.frame = CGRectMake(236,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 27, 17, 20);
        else
            awayNumStat.frame = CGRectMake(99,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 27, 17, 20);
        
        FSPStatIndicatorView *awayIndicator = [[FSPStatIndicatorView alloc] initWithTeam:game.awayTeam withNumber:[self statForGame:game forIndex:i isHome:NO] withDirection:FSPLeftDirection];
        [self addSubview:awayIndicator];
        if (isIpad)
            awayIndicator.frame = CGRectMake(isIpad ? FSPLeftAlignImageIpad : FSPLeftAlignImageIphone, (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 25, 208, 20);
        else
            awayIndicator.frame = CGRectMake(isIpad ? FSPLeftAlignImageIpad : FSPLeftAlignImageIphone, (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 25, 87, 20);
        
        UILabel * homeNumStat = [[UILabel alloc] init];
        homeNumStat.text = [NSString stringWithFormat:@"%@", [self statForGame:game forIndex:i isHome:YES]];
        homeNumStat.font = font;
        homeNumStat.textAlignment = UITextAlignmentCenter;
        homeNumStat.backgroundColor = [UIColor clearColor];
        homeNumStat.textColor = [UIColor fsp_lightMediumBlueColor];
        [self addSubview:homeNumStat];
        if (isIpad)
            homeNumStat.frame = CGRectMake(396,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 27, 17, 20);
        else
            homeNumStat.frame = CGRectMake(204,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 27, 17, 20);
        
        FSPStatIndicatorView *homeIndicator = [[FSPStatIndicatorView alloc] initWithTeam:game.homeTeam withNumber:[self statForGame:game forIndex:i isHome:YES] withDirection:FSPRightDirection];
        [self addSubview:homeIndicator];
        if (isIpad)
            homeIndicator.frame = CGRectMake(418,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 25, 208, 20);
        else
            homeIndicator.frame = CGRectMake(225,  (i * FSPStatsHeight) + (FSPStatsHeight / 4) + 25, 87, 20);
    }
}

- (NSNumber *)statForGame:(FSPSoccerGame *)game forIndex:(NSUInteger)idx isHome:(BOOL)home
{
    NSNumber *stat;
    switch (idx) {
        case 0:
            stat = home ? game.homeGoalsNum : game.awayGoalsNum;
            break;
        case 1:
            stat = home ? game.homeAssists : game.awayAssists;
            break;
        case 2:
            stat = home ? game.homeShots : game.awayShots;
            break;
        case 3:
            stat = home ? game.homeShotsOnGoal : game.awayShotsOnGoal;
            break;
        case 4:
            stat = home ? game.homeSaves : game.awaySaves;
            break;
        case 5:
            stat = home ? game.homeCornerKicks : game.awayCornerKicks;
            break;
            
        default:
            break;
    }
    return stat;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat bottomDividerTopY = CGRectGetMaxY(rect) - 2;
    CGFloat maxX = CGRectGetMaxX(rect);
    
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, bottomDividerTopY, maxX, 1.0f)];
    [[UIColor blackColor] set];
    [path fill];
    
    CGContextTranslateCTM(context, 0.0f, 1.0f);
    [[UIColor colorWithWhite:1.0f alpha:0.1f] set];
    [path fill];
    
    CGContextRestoreGState(context);
}

- (void)prepareForReuse
{
    for (UIView *view in self.subviews)
        [view removeFromSuperview];
}

@end
