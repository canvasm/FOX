//
//  FSPFightingStandingsCell.m
//  FoxSports
//
//  Created by Matthew Fay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFightingStandingsCell.h"
#import "FSPUFCTitleHolderView.h"

NSString * const FSPFightingStandingsCellReuseIdeintifier = @"FSPFightingStandingsCell";

@interface FSPFightingStandingsCell ()

@property (nonatomic, strong) FSPUFCTitleHolderView * left;
@property (nonatomic, strong) FSPUFCTitleHolderView * center;
@property (nonatomic, strong) FSPUFCTitleHolderView * right;

@end

@implementation FSPFightingStandingsCell
@synthesize left, center, right;

- (void)populateWithFighters:(NSArray *)fighters;
{
    switch ([fighters count]) {
        case 3:
            self.right = [[FSPUFCTitleHolderView alloc] init];
            [self.right populateWithTitleHolder:[fighters objectAtIndex:2]];
            [self addSubview:self.right];
            self.right.frame = CGRectMake((self.right.frame.size.width + 2) * 2, 0, self.right.frame.size.width, self.right.frame.size.height);
            
        case 2:
            self.center = [[FSPUFCTitleHolderView alloc] init];
            [self.center populateWithTitleHolder:[fighters objectAtIndex:1]];
            [self addSubview:self.center];
            self.center.frame = CGRectMake(self.center.frame.size.width + 2, 0, self.center.frame.size.width, self.center.frame.size.height);
            
        case 1:
            self.left = [[FSPUFCTitleHolderView alloc] init];
            [self.left populateWithTitleHolder:[fighters objectAtIndex:0]];
            [self addSubview:self.left];
            self.left.frame = CGRectMake(2, 0, self.left.frame.size.width, self.left.frame.size.height);
            break;
            
        default:
            break;
    }
}

- (void)prepareForReuse;
{
    [self.right removeFromSuperview];
    [self.center removeFromSuperview];
    [self.left removeFromSuperview];
    
    self.left = nil;
    self.center = nil;
    self.right = nil;
    
}

@end
