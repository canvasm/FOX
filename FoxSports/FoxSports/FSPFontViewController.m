//
//  FSPFontViewController.m
//  FoxSports
//
//  Created by greay on 5/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFontViewController.h"

#include "FSPStoryViewController.h"

@interface FSPFontViewController ()

- (IBAction)selectedSmallSize:(id)sender;
- (IBAction)selectedMediumSize:(id)sender;
- (IBAction)selectedLargeSize:(id)sender;

@end

@implementation FSPFontViewController

@synthesize delegate;
@synthesize smallFontButton;
@synthesize mediumFontButton;
@synthesize largeFontButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateFontButton;
{
    if ([self.delegate isKindOfClass:[FSPStoryViewController class]]) {
        CGFloat fontSize = [(FSPStoryViewController *)self.delegate fontSize];
        if (fontSize == FSP_LARGE_FONT_SIZE) {
            [smallFontButton setImage:[UIImage imageNamed:@"Aa-sm-unselected"] forState:UIControlStateNormal];
            [mediumFontButton setImage:[UIImage imageNamed:@"Aa-m-unselected"] forState:UIControlStateNormal];
            [largeFontButton setImage:[UIImage imageNamed:@"Aa-lg-selected"] forState:UIControlStateNormal];
        } else if (fontSize == FSP_SMALL_FONT_SIZE) {
            [smallFontButton setImage:[UIImage imageNamed:@"Aa-sm-selected"] forState:UIControlStateNormal];
            [mediumFontButton setImage:[UIImage imageNamed:@"Aa-m-unselected"] forState:UIControlStateNormal];
            [largeFontButton setImage:[UIImage imageNamed:@"Aa-lg-unselected"] forState:UIControlStateNormal];
        } else {
            [smallFontButton setImage:[UIImage imageNamed:@"Aa-sm-unselected"] forState:UIControlStateNormal];
            [mediumFontButton setImage:[UIImage imageNamed:@"Aa-m-selected"] forState:UIControlStateNormal];
            [largeFontButton setImage:[UIImage imageNamed:@"Aa-lg-unselected"] forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = self.view.bounds.size;
    [smallFontButton setImage:[UIImage imageNamed:@"Aa-sm-selected"] forState:UIControlStateHighlighted];
    [mediumFontButton setImage:[UIImage imageNamed:@"Aa-m-selected"] forState:UIControlStateHighlighted];
    [largeFontButton setImage:[UIImage imageNamed:@"Aa-lg-selected"] forState:UIControlStateHighlighted];

}

- (void)viewDidUnload
{
    [self setSmallFontButton:nil];
    [self setMediumFontButton:nil];
    [self setLargeFontButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}


- (IBAction)selectedSmallSize:(id)sender {
	[self.delegate fontViewController:self didSelectFontSize:FSP_SMALL_FONT_SIZE];
    [self updateFontButton];
}

- (IBAction)selectedMediumSize:(id)sender {
	[self.delegate fontViewController:self didSelectFontSize:FSP_MEDIUM_FONT_SIZE];
    [self updateFontButton];
}

- (IBAction)selectedLargeSize:(id)sender {
	[self.delegate fontViewController:self didSelectFontSize:FSP_LARGE_FONT_SIZE];
    [self updateFontButton];
}


@end
