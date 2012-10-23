//
//  FSPPlayerDetailViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPlayerDetailViewController.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPPGAGolferDetailView.h"

@interface FSPPlayerDetailViewController ()

@end

@implementation FSPPlayerDetailViewController

@synthesize nameLabel = _nameLabel;
@synthesize titleLabels = _titleLabels;
@synthesize valueLabels = _valueLabels;
@synthesize headshotImageView = _headshotImageView;
@synthesize contentScrollView = _contentScrollView;
@synthesize playerStandingsNib = _playerStandingsNib;

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
	
    [[UIBarButtonItem appearanceWhenContainedIn:[FSPPlayerDetailViewController class], nil] setTintColor:[UIColor grayColor]];
}

- (IBAction)closeDetailViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)styleLabels
{
    self.nameLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:18.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    for (UILabel *label in self.titleLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:12.0];
        label.textColor = [UIColor whiteColor];
        CGSize labelTextSize = [label.text sizeWithFont:label.font];
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelTextSize.width, label.frame.size.height);
    }
    
    for (UILabel *label in self.valueLabels) {
        label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:12.0];
        label.textColor = [UIColor fsp_lightBlueColor];
        
        UILabel *titleLabel = [self.titleLabels objectAtIndex:[self.valueLabels indexOfObject:label]];
        CGFloat valueLabelMargin = CGRectGetMaxX(titleLabel.frame) + 7.0;
        label.frame = CGRectMake(valueLabelMargin, label.frame.origin.y, self.view.frame.size.width - valueLabelMargin, label.frame.size.height);
    }
}

@end
