//
//  FSPUFCFightCardView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-16.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFightCardView.h"

@implementation FSPUFCFightCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCFightCardView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
