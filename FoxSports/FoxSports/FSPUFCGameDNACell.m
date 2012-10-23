//
//  FSPUFCGameDNACell.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-22.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCGameDNACell.h"

@interface FSPUFCGameDNACell()

@property (strong, nonatomic) IBOutlet UIImageView *roundImage;

@end

@implementation FSPUFCGameDNACell

@synthesize roundImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCGameDNACell" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
}

- (void)setRound:(NSInteger)round
{
    if (round < 0)
        round = 0;
    if (round > 4)
        round = 4;
    
    NSString *imageName = [NSString stringWithFormat:@"%@%d", @"gt_ufc_gamedna_round", (round + 1)]; //+1 because it returns a 0 based index. image names start at 1
    self.roundImage.image = [UIImage imageNamed:imageName];
    self.roundImage.frame = CGRectMake(0, 0, roundImage.image.size.width, roundImage.image.size.height);
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
