//
//  FSPMLBGameTraxBDHViewController.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxBDHViewController.h"

@interface FSPMLBGameTraxBDHViewController ()

@end

@implementation FSPMLBGameTraxBDHViewController

@synthesize fieldNavBaserunnersButton, fieldNavDefenseButton, fieldNavHitChartButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interaction

- (IBAction)fieldNavBaserunnersButtonPressed:(id)sender {
    [fieldNavBaserunnersButton setSelected:YES];
    [fieldNavDefenseButton setSelected:NO];
    [fieldNavHitChartButton setSelected:NO];
}

- (IBAction)fieldNavDefenseButtonPressed:(id)sender {
    [fieldNavBaserunnersButton setSelected:NO];
    [fieldNavDefenseButton setSelected:YES];
    [fieldNavHitChartButton setSelected:NO];
}

- (IBAction)fieldNavHitChartButtonPressed:(id)sender {
    [fieldNavBaserunnersButton setSelected:NO];
    [fieldNavDefenseButton setSelected:NO];
    [fieldNavHitChartButton setSelected:YES];
}

@end
