//
//  FSPUFCFighterProfilePopoverView.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-10.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFighterProfilePopoverView.h"
#import "FSPUFCPlayer.h"
#import "UIFont+FSPExtensions.h"

@interface FSPUFCFighterProfilePopoverView()

@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UILabel *reachLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *stanceLabel;

@property (strong, nonatomic) IBOutlet UILabel *homeTownLabel;
@property (strong, nonatomic) IBOutlet UILabel *fightsOutOfLabel;
@property (strong, nonatomic) IBOutlet UILabel *fightCampLabel;



@property (retain, nonatomic) UILabel *heightValue;
@property (retain, nonatomic) UILabel *weightValue;
@property (retain, nonatomic) UILabel *reachValue;
@property (retain, nonatomic) UILabel *ageValue;
@property (retain, nonatomic) UILabel *stanceValue;

@property (retain, nonatomic) UILabel *homeTownValue;
@property (retain, nonatomic) UILabel *fightsOutOfValue;
@property (retain, nonatomic) UILabel *fightCampValue;

@end

@implementation FSPUFCFighterProfilePopoverView

@synthesize heightValue, weightValue, reachValue, ageValue, stanceValue, homeTownValue, fightsOutOfValue, fightCampValue;

const int textPadding = 5;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = self.view.frame.size; //keep the popover size same as our view
    
    heightValue = [self createAndLayoutLabel:self.heightLabel];
    weightValue = [self createAndLayoutLabel:self.weightLabel];
    reachValue = [self createAndLayoutLabel:self.reachLabel];
    ageValue = [self createAndLayoutLabel:self.ageLabel];
    stanceValue = [self createAndLayoutLabel:self.stanceLabel];
    
    homeTownValue = [self createAndLayoutLabel:self.homeTownLabel];
    fightsOutOfValue = [self createAndLayoutLabel:self.fightsOutOfLabel];
    fightCampValue = [self createAndLayoutLabel:self.fightCampLabel];
}

-(void)setFighterInfo:(FSPUFCPlayer *)fighter
{
    if (!fighter)
    {
        NSLog(@"Error getting fighter info");
        return;
    }
    
    self.heightValue.text = fighter.height.stringValue;
    self.weightValue.text = fighter.weight.stringValue;
    self.reachValue.text = fighter.reach.stringValue;
    self.ageValue.text = fighter.age.stringValue;
    
    self.stanceValue.text = @"NO DATA";
    
    self.homeTownValue.text = fighter.homeTown;
    self.fightsOutOfValue.text = fighter.fightsOutOf;
    
    self.fightCampValue.text = @"NO DATA";
}

-(UILabel *)createAndLayoutLabel:(UILabel *)labelToLayoutFrom
{
    UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(labelToLayoutFrom.frame.origin.x + labelToLayoutFrom.frame.size.width + textPadding, labelToLayoutFrom.frame.origin.y, 200, labelToLayoutFrom.frame.size.height)];
    
    [self.view addSubview:created];
    created.backgroundColor = [UIColor clearColor];
    [created setFont:[UIFont boldSystemFontOfSize:17]];
    //[created setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:17]];
    return created;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setHeightValue:nil];
    [self setWeightValue:nil];
    [self setReachValue:nil];
    [self setAgeValue:nil];
    [self setStanceValue:nil];
    [self setHomeTownValue:nil];
    [self setFightsOutOfValue:nil];
    [self setFightCampValue:nil];
    [super viewDidUnload];
}

@end