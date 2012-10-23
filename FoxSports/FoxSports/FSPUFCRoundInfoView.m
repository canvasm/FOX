//
//  FSPUFCRoundInfoView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-09.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCRoundInfoView.h"

@implementation FSPUFCRoundInfoView

@synthesize roundNumber;
@synthesize roundTimeLeft;
@synthesize currentPositionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCRoundInfoView" owner:self options:nil];
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
