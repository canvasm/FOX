//
//  FSPUFCDNAView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCDNAView.h"
#import "FSPUFCGameDNACell.h"

@interface FSPUFCDNAView ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *roundCellArray;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

@end

@implementation FSPUFCDNAView

@synthesize scrollView;
@synthesize roundCellArray;
@synthesize infoButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCDNAView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
        
        self.roundCellArray = [[NSMutableArray alloc] initWithCapacity:5];
        
        for (int x = 0; x < 5; x++)
        {
            FSPUFCGameDNACell *newCell = [[FSPUFCGameDNACell alloc] initWithFrame:CGRectMake(0,
                                                                                             300 * x,
                                                                                             90,
                                                                                             300)];
            [newCell setRound:x];
            [self.roundCellArray addObject:newCell];
            [self.scrollView addSubview:newCell];
        }
        
        [self.scrollView setContentSize:CGSizeMake(90, 300 * 5)];
        [self.infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)infoButtonClicked:(UIButton *)sender
{
    NSLog(@"INFO");
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
