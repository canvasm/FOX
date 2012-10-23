//
//  FSPPGALeaderboardTableViewSectionHeader.m
//  FoxSports
//
//  Created by Jason Whitford on 3/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGALeaderboardTableViewSectionHeader.h"
#import "UIFont+FSPExtensions.h"
#import "FSPGameDetailSectionHeader.h"
#import "UIColor+FSPExtensions.h"

@interface FSPPGALeaderboardTableViewSectionHeader()

@end

@implementation FSPPGALeaderboardTableViewSectionHeader

- (id)init
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FSPPGALeaderboardTableViewSectionHeader" owner:nil options:nil];
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            self = (FSPPGALeaderboardTableViewSectionHeader *)view;
        }
    }
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self styleHeader];
}

+ (CGFloat)headerHeight
{
    return 65.0;
}

@end
