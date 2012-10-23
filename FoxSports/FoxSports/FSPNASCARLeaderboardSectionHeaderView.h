//
//  FSPNASCARLeaderboardSectionHeaderView.h
//  FoxSports
//
//  Created by Stephen Spring on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPLeaderboardSectionHeaderView.h"

/*!
 @abstract Determines the type of header view to use. Each type has it's own NIB.
 */
typedef enum {
    FSPNASCARLeaderboardSectionHeaderTypeResults = 0, // Includes top part of header with label
    FSPNASCARLeaderboardSectionHeaderTypeQualifying // Doesn't include top part of header
} FSPNASCARLeaderboardSectionHeaderType;

@class FSPStandingsSectionHeaderView;

@interface FSPNASCARLeaderboardSectionHeaderView : FSPLeaderboardSectionHeaderView

@property (weak, nonatomic) FSPStandingsSectionHeaderView *topHeaderView;
@property (assign, nonatomic) FSPNASCARLeaderboardSectionHeaderType type;

/*!
 @abstract Initializes with the desired type of header
 @param type The type of header to initialize
 @return Returns an instance of the specified type
 */
- (id)initWithFrame:(CGRect)frame type:(FSPNASCARLeaderboardSectionHeaderType)type;

+ (CGFloat)headerHeightForType:(FSPNASCARLeaderboardSectionHeaderType)type;

@end
