//
//  FSPMLBGameTraxPlayerView.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxPlayerView.h"

@implementation FSPMLBGameTraxPlayerView

@synthesize view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxPlayerView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxPlayerView" owner:self options:nil];
    [self addSubview:self.view];

}

@end
