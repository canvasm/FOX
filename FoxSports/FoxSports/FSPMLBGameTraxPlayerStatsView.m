//
//  FSPMLBGameTraxPlayerStatsView.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxPlayerStatsView.h"

@implementation FSPMLBGameTraxPlayerStatsView

@synthesize view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxPlayerStatsView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxPlayerStatsView" owner:self options:nil];
    [self addSubview:self.view];
    
}

@end
