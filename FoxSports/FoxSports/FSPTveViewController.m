//
//  FSPTveViewController.m
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/9/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import "FSPTveViewController.h"
#import "FSPTveAuthManager.h"

@interface FSPTveViewController ()

@end

@implementation FSPTveViewController

@synthesize previousViewController = _previousViewController;

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
    [self setBackBarButtonItemTitle:@"Back"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeModal)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//------------------------------------------------------------------------------
// MARK: - API
//------------------------------------------------------------------------------

- (void)setBackBarButtonItemTitle:(NSString *)title
{
    self.previousViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                                                    style:UIBarButtonItemStylePlain
                                                                                                   target:nil
                                                                                                   action:nil];
}

- (void)closeModal
{
    [[FSPTveAuthManager sharedManager] cancelLogin];
    [self dismissModalViewControllerAnimated:YES];
}

@end
