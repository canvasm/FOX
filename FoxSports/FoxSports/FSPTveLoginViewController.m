//
//  FSPTveLoginViewController.m
//  FoxSportsTVEHarness
//
//  Created by Joshua Dubey on 5/3/12.
//  Copyright (c) 2012 Übermind, Inc. All rights reserved.
//

#import "FSPTveLoginViewController.h"
#import "FSPTveProviderButton.h"
#import "FSPTveProviderLoginViewController.h"
#import "FSPTveAuthManager.h"
#import "FSPLogging.h"
//#import "FSPTveMoreProvidersViewController.h"
//#import "FSPTveAccountSignUpViewController.h"
//#import "FSPTveLoginOptionsViewController.h"

#import <QuartzCore/QuartzCore.h>

#define kFSPTveProviderXImageSize 112
#define kFSPTveProviderYImageSize 33
#define kFSPTveProviderYImagePadding 20
#define kFSPTveProviderXImagePadding 30
#define kFSPTveProviderXButtonSpacing 18
#define kFSPTveProviderYButtonSpacing 8
#define kFSPTveContactButtonWidth 300
#define kFSPTveContactButtonHeight 30
#define kFSPTveOptionButtonHeight 45
#define kFSPTveOptionButtonWidth 270


@interface FSPTveLoginViewController ()
@property (nonatomic, strong) UIView *providerView;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)layoutProviderView:(NSArray *)providers;

@end

@implementation FSPTveLoginViewController

@synthesize providers = _providers;
@synthesize providerView = _providerView;
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Select a Television Provider";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _providerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.providerView];
    [self.view addSubview:self.scrollView];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutProviderView:self.providers];
}

//------------------------------------------------------------------------------
// MARK: - FSPTveAuthManager delegate
//------------------------------------------------------------------------------

- (void)layoutProviderView:(NSArray *)providers
{    
    self.providers = providers;
    self.scrollView.frame = self.view.frame;
    self.providerView.frame = self.view.frame;
    UIView *matrixView = [[UIView alloc] initWithFrame:CGRectZero];
    matrixView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    matrixView.layer.cornerRadius = 4.0;
    
    int providerCount = 0;
    
    int padding = 15;
    NSUInteger row = 0;
    NSUInteger invalidItems = 0;
    for (NSUInteger i = 0; i < [providers count]; i++) 
    {
        FSPTveProviderButton *providerButton = [[FSPTveProviderButton alloc] initWithFrame:CGRectZero];
        providerButton.provider = [providers objectAtIndex:i];
        [providerButton setTitle:[[providers objectAtIndex:i] displayName] forState:UIControlStateNormal];
        [providerButton addTarget:self
                           action:@selector(selectProvider:)
                 forControlEvents:UIControlEventTouchDown];
        
        NSUInteger mod = (i - invalidItems) % 3;
        row = (((i - invalidItems) - mod) / 3);
        providerButton.frame = CGRectMake(padding + (kFSPTveProviderXImageSize + kFSPTveProviderXImagePadding + kFSPTveProviderXButtonSpacing) * mod,
                                          padding + (kFSPTveProviderYImageSize + kFSPTveProviderYImagePadding + kFSPTveProviderYButtonSpacing) * row,
                                          kFSPTveProviderXImageSize + kFSPTveProviderXImagePadding,
                                          kFSPTveProviderYImageSize + kFSPTveProviderYImagePadding);
        
        [matrixView addSubview:providerButton];
        providerCount++;
        
    }
    
    CGFloat w = (padding + kFSPTveProviderXImageSize + kFSPTveProviderXImagePadding) * 3 + kFSPTveProviderXButtonSpacing;
    matrixView.frame = CGRectMake((self.view.bounds.size.width - w) / 2,
                                  110.0,
                                  w,
                                  padding * 2 + (kFSPTveProviderYImageSize + kFSPTveProviderYImagePadding + kFSPTveProviderYButtonSpacing) * row + kFSPTveProviderYImageSize + kFSPTveProviderYImagePadding);
    [self.providerView addSubview:matrixView];
    
    UIButton *moreOptionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat buttonHeight = kFSPTveOptionButtonHeight;
    CGFloat buttonWidth = kFSPTveOptionButtonWidth;
    moreOptionsButton.frame = CGRectMake((540. - buttonWidth)/2., CGRectGetMaxY(matrixView.frame) + 25., buttonWidth, buttonHeight);
    moreOptionsButton.titleLabel.font = [UIFont fontWithName:@"TradeGothicLTStd-Bold" size:20];
    moreOptionsButton.titleLabel.shadowColor = [UIColor whiteColor];
    moreOptionsButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [moreOptionsButton setTitle:@"More" forState:UIControlStateNormal];

        
    
    UIButton *temporaryPreviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    temporaryPreviewButton.frame = CGRectMake((540 - kFSPTveOptionButtonWidth)/2, CGRectGetMaxY(moreOptionsButton.frame) + 10, kFSPTveOptionButtonWidth, kFSPTveOptionButtonHeight);
    temporaryPreviewButton.titleLabel.font = [UIFont fontWithName:@"TradeGothicLTStd-Bold" size:20];
    temporaryPreviewButton.titleLabel.shadowColor = [UIColor whiteColor];
    temporaryPreviewButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [temporaryPreviewButton setTitle:@"Temporary Preview" forState:UIControlStateNormal];

    // and.. adjust the position of the label :/
    UIEdgeInsets insets = moreOptionsButton.titleEdgeInsets;
    insets.top += 4;
    moreOptionsButton.titleEdgeInsets = insets;
    
    [moreOptionsButton addTarget:self
                        action:@selector(moreOptions)
              forControlEvents:UIControlEventTouchUpInside];
    
    temporaryPreviewButton.titleEdgeInsets = insets;
    
    [temporaryPreviewButton addTarget:self
                        action:@selector(temporaryPreview)
              forControlEvents:UIControlEventTouchUpInside];

    
    [self.scrollView addSubview:moreOptionsButton];
    [self.scrollView addSubview:temporaryPreviewButton];
    
    [(UIScrollView *)self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(moreOptionsButton.frame))];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)selectProvider:(FSPTveProviderButton *)button
{    
    FSPLogTve(@"Provider Selected: %@", button.provider.ID);
    [[[FSPTveAuthManager sharedManager] providerWebView] removeFromSuperview];
    FSPTveProviderLoginViewController *providerViewController = [[FSPTveProviderLoginViewController alloc] initWithNibName:nil bundle:nil];
    providerViewController.previousViewController = self;
    [self.navigationController pushViewController:providerViewController animated:YES];
    
    [[FSPTveAuthManager sharedManager] setSelectedProvider:button.provider.ID];
}

-(void)closeModal
{
    [[FSPTveAuthManager sharedManager] cancelLogin];
    [super closeModal];
}

- (void)temporaryPreview
{
//    FSPTveMoreProvidersViewController *moreProvidersViewController = [[FSPTveMoreProvidersViewController alloc] initWithNibName:@"FSPTveMoreProvidersViewController" bundle:nil];
//    moreProvidersViewController.providers = self.providers;
//    moreProvidersViewController.headerLabelText = @"Select your current television provider!";
//    moreProvidersViewController.isPreview = YES;
//    moreProvidersViewController.previousViewController = self;
//    [self.navigationController pushViewController:moreProvidersViewController animated:YES];
}

- (void)moreOptions
{
//    FSPTveLoginOptionsViewController *loginOptionsViewController = [[FSPTveLoginOptionsViewController alloc] initWithNibName:@"FSPTveLoginOptionsViewController"
//                                                                                                                  bundle:nil];
//    loginOptionsViewController.previousViewController = self;
//    [self.navigationController pushViewController:loginOptionsViewController
//                                         animated:YES];
}
@end
