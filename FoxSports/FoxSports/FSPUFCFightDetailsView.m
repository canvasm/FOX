//
//  FSPUFCFightDetailsView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-17.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFightDetailsView.h"

@interface FSPUFCFightDetailsView()
{
    IBOutlet UISegmentedControl *roundOrFightSelection;
    
    IBOutlet UILabel *fighterOneDMGHead;
    IBOutlet UILabel *fighterOneDMGBody;
    IBOutlet UILabel *fighterOneDMGLegs;
    
    IBOutlet UILabel *fighterTwoDMGHead;
    IBOutlet UILabel *fighterTwoDMGBody;
    IBOutlet UILabel *fighterTwoDMGLegs;
    
    IBOutlet UIButton *testButton;
}

@end

@implementation FSPUFCFightDetailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FSPUFCFightDetailsView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
        
        [roundOrFightSelection addTarget:self
                                  action:@selector(roundOrFightControlClicked:)
                                    forControlEvents:UIControlEventValueChanged];
        
        
    }
    return self;
}

- (void)roundOrFightControlClicked:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    //TEMP
    //NSLog(@"%@", [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]]);
    //NSLog(@"%@%@", NSStringFromCGRect(damageToHeadLabel.frame), NSStringFromCGPoint(damageToHeadLabel.center));
    
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + 30, self.frame.size.height);
    
    if ([segmentedControl selectedSegmentIndex] == 0)
    {
        //TODO ROUND
    }
    else if ([segmentedControl selectedSegmentIndex] == 1)
    {
        //TODO FIGHT
    }
}

- (void)incrementFighterDamage:(int)fighterNumber:(enum FSPUFCDamageType)damageType
{
    switch (damageType)
    {
        case Head:
            NSLog(@"HEAD");
            break;
            
        case Body:
            NSLog(@"BODY");
            break;
            
        case Legs:
            NSLog(@"Legs");
            break;
            
        default:
            break;
    }
}

- (void)setFighterDamage:(int)newDamageValue:(int)fighterNumber:(enum FSPUFCDamageType)damageType
{
    switch (damageType)
    {
        case Head:
            NSLog(@"HEAD");
            break;
            
        case Body:
            NSLog(@"BODY");
            break;
            
        case Legs:
            NSLog(@"Legs");
            break;
            
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
*/

@end
