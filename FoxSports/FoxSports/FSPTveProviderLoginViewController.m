//
//  FSPTveProviderLoginViewController.m
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/3/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import "FSPTveProviderLoginViewController.h"
#import "FSPTveAuthManager.h"

@interface FSPTveProviderLoginViewController ()

@end

@implementation FSPTveProviderLoginViewController

@synthesize providerName= _providerName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"TV Provider Sign In";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackBarButtonItemTitle:@"Change Provider"];
    [self.view addSubview:[FSPTveAuthManager sharedManager].providerWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [FSPTveAuthManager sharedManager].providerWebView.frame = self.view.frame;   
}

-(void)viewDidDisappear:(BOOL)animated
{
    // Load a blank page into the web view, so that if the user backs out to the provider selection page and picks
    // a new provider, the previously selected provider's web page is not still visible while the new page loads.
    [[FSPTveAuthManager sharedManager].providerWebView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)closeModal
{
    [super closeModal];
}

@end
