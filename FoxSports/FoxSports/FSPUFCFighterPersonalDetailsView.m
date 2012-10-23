//
//  FSPUFCFighterPersonalDetailsView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-05.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFighterPersonalDetailsView.h"
#import "FSPUFCFightTraxViewController.h"
#import "FSPImageFetcher.h"

@interface FSPUFCFighterPersonalDetailsView()


@end

@implementation FSPUFCFighterPersonalDetailsView

@synthesize fighterName;
@synthesize fighterNickName;
@synthesize fighterStats;
@synthesize viewProfileButton;
@synthesize fighterProfileImage;
@synthesize currentFighter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCFighterPersonalDetailsView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    
    return self;
}

//UNTESTED
- (void)setFighterInfo:(FSPUFCPlayer *)fighter
{
    currentFighter = fighter;
    
    if (!currentFighter)
    {
        NSLog(@"Fighter could not be set!");
        return;
    }
    
    fighterName.text =  currentFighter.fullName;
    fighterNickName.text = currentFighter.nickname;
    fighterStats.text = [currentFighter getFormattedStats];
    
    //download image
    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:currentFighter.photoURL]withCallback:^(UIImage *image)
    {
        if (image)
            fighterProfileImage.image = image;
        else //set to default if download returns nothing
            fighterProfileImage.image = [UIImage imageNamed:@"Default_Headshot_UFC@2x"];
    }];
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