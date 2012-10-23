//
//  FSPNASCARLeaderboardSectionHeaderView.m
//  FoxSports
//
//  Created by Stephen Spring on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNASCARLeaderboardSectionHeaderView.h"
#import "FSPGameDetailSectionHeader.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailSectionHeader.h"

@interface FSPNASCARLeaderboardSectionHeaderView()


@end

@implementation FSPNASCARLeaderboardSectionHeaderView

@synthesize topHeaderView = _topHeaderView;
@synthesize titleLabel = _titleLabel;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame type:(FSPNASCARLeaderboardSectionHeaderType)type
{ 
    self = [super initWithFrame:frame];
    if (self) {
        NSString *nibName = nil;
        switch (type) {
            case FSPNASCARLeaderboardSectionHeaderTypeResults:
                nibName = @"FSPNASCARLeaderboardResultsSectionHeaderView";
                break;
            case FSPNASCARLeaderboardSectionHeaderTypeQualifying:
                nibName = @"FSPNASCARLeaderboardQualifyingSectionHeaderView";
                break;
        }
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        for (id view in views) {
            if ([view isKindOfClass:[self class]]) {
                self = (FSPNASCARLeaderboardSectionHeaderView *)view;
            }
        }
        self.type = type;
        [self addTopView];
        [super styleHeader];
    }
    return self;
}

- (void)addTopView
{
    switch (self.type) {
        case FSPNASCARLeaderboardSectionHeaderTypeResults:
            self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 65.0);
            [super addTopView];
            break;
        case FSPNASCARLeaderboardSectionHeaderTypeQualifying:
            self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 29.0);
            break;
        default:
            self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 29.0);
            break;
    }
}

+ (CGFloat)headerHeightForType:(FSPNASCARLeaderboardSectionHeaderType)type
{
    switch (type) {
        case FSPNASCARLeaderboardSectionHeaderTypeResults:
            return 65.0;
        case FSPNASCARLeaderboardSectionHeaderTypeQualifying:  
            return 29.0;
        default:
            return 0.0;
    }
}

@end
