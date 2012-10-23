//
//  FSPChipsContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPChipsContainerViewController.h"
#import "FSPRootViewController.h"
#import "FSPEventsViewController.h"

@interface FSPChipsContainerViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *gestureInterceptView;

- (void)startDrag:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)toggleChipsHidden;

@end

@implementation FSPChipsContainerViewController

#pragma mark - Properties
@synthesize hidden = _hidden;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize gestureInterceptView = _gestureInterceptView;
@synthesize chipsContainerDelegate;


- (void)setHidden:(BOOL)hidden
{
    if (_hidden != hidden) {
        _hidden = hidden;
        ((FSPEventsViewController *)self.subViewController).tableView.userInteractionEnabled = !hidden;
        if (hidden) {
            [self.view addSubview:self.gestureInterceptView];
            [self.view bringSubviewToFront:self.gestureInterceptView];
        } else {
            [self.gestureInterceptView removeFromSuperview];
        }
    }
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = @"eventsSection";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(startDrag:)];
        
        UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleButton.frame = CGRectMake(0, 0, 40, 40);
        toggleButton.accessibilityIdentifier = @"menuToggle";
        [toggleButton setImage:[UIImage imageNamed:@"dropdown_icon"] forState:UIControlStateNormal];
        [toggleButton addGestureRecognizer:panGesture];
        [toggleButton addTarget:self action:@selector(toggleChipsHidden) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *chipsToggleButton = [[UIBarButtonItem alloc] initWithCustomView:toggleButton];
        self.navigationItem.leftBarButtonItem = chipsToggleButton;
        
        self.gestureInterceptView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleChipsHidden)];
        [self.gestureInterceptView addGestureRecognizer:self.tapGestureRecognizer];
        
        UIGestureRecognizer *backPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(startDrag:)];
        [self.gestureInterceptView addGestureRecognizer:backPanGesture];
        
        ((FSPEventsViewController *)self.subViewController).tableView.userInteractionEnabled = !self.hidden;
    }
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.clipsToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 1.0f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.frame].CGPath;
}


#pragma mark - Gestures
- (void)startDrag:(UIPanGestureRecognizer *)gestureRecognizer;
{
    if (self.chipsContainerDelegate && [self.chipsContainerDelegate respondsToSelector:@selector(chipsContainerViewController:didPanWithGesture:)]) {
        [self.chipsContainerDelegate chipsContainerViewController:self didPanWithGesture:gestureRecognizer];
    }
}

- (void)toggleChipsHidden;
{
	if ([FSPRootViewController rootViewController].organizationsViewController.tableView.isEditing) {
		[[FSPRootViewController rootViewController] exitCustomizationModeAnimated:YES];
		return;
	}

    if (self.chipsContainerDelegate && [self.chipsContainerDelegate respondsToSelector:@selector(chipsContainerViewControllerToggleHidden:)])
        [self.chipsContainerDelegate chipsContainerViewControllerToggleHidden:self];
}


@end
