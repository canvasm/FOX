//
//  FSPUFCFightersAndRoundInfoView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-22.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFightersAndRoundInfoView.h"
#import "FSPImageFetcher.h"

@implementation FSPUFCFightersAndRoundInfoView

//FIGHTER ONE
@synthesize fighter1;
@synthesize fighterOneName;
@synthesize fighterOneNickName;
@synthesize fighterOneStats;
@synthesize viewFighterOneProfileButton;
@synthesize fighterOneProfileImage;

//FIGHTER TWO
@synthesize fighter2;
@synthesize fighterTwoName;
@synthesize fighterTwoNickName;
@synthesize fighterTwoStats;
@synthesize viewFighterTwoProfileButton;
@synthesize fighterTwoProfileImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //adds the correct xib
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCFightersAndRoundInfoView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
}

- (void)setFightersInfo:(FSPUFCPlayer *)fighterOne:(FSPUFCPlayer *)fighterTwo
{
    fighter1 = fighterOne;
    fighter2 = fighterTwo;
    
    if (fighter1)
    {
        self.fighterOneName.text =  fighter1.fullName;
        self.fighterOneNickName.text = fighter1.nickname;
        self.fighterOneStats.text = [fighter1 getFormattedStats];
        
        //download image
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:fighter1.photoURL]withCallback:^(UIImage *image)
         {
             if (image)
                 self.fighterOneProfileImage.image = image;
             else //set to default if download returns nothing
                 self.fighterOneProfileImage.image = [UIImage imageNamed:@"Default_Headshot_UFC@2x"];
         }];
    }
    
    if (fighter2)
    {
        self.fighterTwoName.text =  fighter2.fullName;
        self.fighterTwoNickName.text = fighter2.nickname;
        self.fighterTwoStats.text = [fighter2 getFormattedStats];
        
        //download image
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:fighter2.photoURL]withCallback:^(UIImage *image)
         {
             if (image)
                 self.fighterTwoProfileImage.image = image;
             else //set to default if download returns nothing
                 self.fighterTwoProfileImage.image = [UIImage imageNamed:@"Default_Headshot_UFC@2x"];
         }];
    }
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
