//
//  FSPNFLTeamLeadersCell.h
//  FoxSports
//
//  Created by Stephen Spring on 7/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPGameStatCell.h"

extern NSString * const FSPNFLTeamLeadersRowCellReuseIdentifier;
extern NSString * const FSPNFLTeamLeadersRowCellNibName;

@interface FSPNFLTeamLeadersCell : FSPGameStatCell

@property (nonatomic, strong) NSSet *players;

- (void)populateTopPerformers;
+ (CGFloat)topPerformerViewHeight;

@end
