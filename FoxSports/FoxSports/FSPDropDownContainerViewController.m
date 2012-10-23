//
//  FSPDropDownContainerViewController.m
//  FoxSports
//
//  Created by Steven Stout on 7/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownContainerViewController.h"
#import "UIColor+FSPExtensions.h"


// Accessibility Labels
NSString * const FSPDropDownToggleHideLabel = @"hide event menu";
NSString * const FSPDropDownToggleShowLabel = @"show event menu";

NSString * const FSPDropDownExtendedKey = @"FSPDropDownExtendedKey";


@interface FSPDropDownContainerViewController ()

@property (nonatomic, strong) UIBarButtonItem *menuButton;

@end


@implementation FSPDropDownContainerViewController {
    BOOL isMenuExtended;
}

#pragma mark - Properties
@synthesize subViewController = _subViewController;
@synthesize dropDownMenu = _dropDownMenu;
@synthesize menuButton = _menuButton;
@synthesize dropDownContainerDelegate;


#pragma mark - Custom getters and setters
- (BOOL)isDropDownMenuExtended;
{
    return isMenuExtended;
}

- (void)setSubViewController:(UIViewController *)subViewController
{
    if (_subViewController) {
        [_subViewController willMoveToParentViewController:nil];
        [_subViewController.view removeFromSuperview];
        [_subViewController removeFromParentViewController];
        _subViewController = nil;
    }
    
    _subViewController = subViewController;
    
	[_subViewController viewWillAppear:YES];
    [self.view addSubview:_subViewController.view];
	[_subViewController viewDidAppear:YES];
	
	isMenuExtended = !isMenuExtended;
	[self setDropDownMenuExtended:!isMenuExtended animated:NO];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor fsp_lightGrayColor];
    
    [self setupDropdown];
    
	isMenuExtended = YES;
    [self setDropDownMenuExtended:NO animated:NO];
	
    // setup a button to switch the menu
    self.menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron_up"] 
                                                       style:UIBarButtonItemStyleBordered 
                                                      target:self 
                                                      action:@selector(menuButtonWasTapped:)];
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"button_background_dkblue"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.menuButton.accessibilityLabel = NSLocalizedString(FSPDropDownToggleHideLabel, nil);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    CGRect dropDownFrame;
    if ([self.dropDownMenu.segments count] == 1) {
        dropDownFrame = CGRectZero;
    } else {
        dropDownFrame = self.dropDownMenu.frame;
    }
	
	CGFloat dropDownHeight = CGRectGetMaxY(dropDownFrame);
    self.subViewController.view.frame = CGRectMake(0, dropDownHeight, self.view.bounds.size.width, self.view.bounds.size.height - dropDownHeight);
    
	if (self.dropDownMenu.sectionsHeight <= 0) {
		[self.navigationItem setRightBarButtonItem:nil animated:animated];
	} else {
		[self.navigationItem setRightBarButtonItem:self.menuButton animated:animated];
	}
    
	[self setDropDownMenuExtended:[[NSUserDefaults standardUserDefaults] boolForKey:FSPDropDownExtendedKey] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.dropDownMenu = nil;
		self.menuButton = nil;
		self.subViewController = nil;
	}
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.dropDownMenu = nil;
    self.menuButton = nil;
    self.subViewController = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - :: Drop Down Menu ::
- (NSArray *)dropDownSections
{
    return nil; // Subclasses should override and implement.
}

- (NSArray *)dropDownSegments
{
    return nil; // Subclasses should override and implement.
}

- (void)setupDropdown
{
	[self.dropDownMenu removeFromSuperview];
	
    self.dropDownMenu = [FSPDropDownMenu dropDownMenuWithSections:[self dropDownSections] segments:[self dropDownSegments]];
    self.dropDownMenu.delegate = self;
    [self.view addSubview:self.dropDownMenu];
	
	UISwipeGestureRecognizer *dropDownMenuSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDropDownMenuState:)];
    dropDownMenuSwipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.dropDownMenu addGestureRecognizer:dropDownMenuSwipeUp];
    for (UIView *subview in [self.dropDownMenu subviews])
        [subview addGestureRecognizer:dropDownMenuSwipeUp];
}

- (void)toggleDropDownMenuState:(id)sender
{
    BOOL showMenu = !self.isDropDownMenuExtended;
    [self setDropDownMenuExtended:showMenu animated:YES];
    
    if (self.dropDownContainerDelegate && [self.dropDownContainerDelegate respondsToSelector:@selector(dropDownContainerViewController:didChangeDropDownMenuState:)]) {
        [self.dropDownContainerDelegate dropDownContainerViewController:self didChangeDropDownMenuState:showMenu];
    }
}

- (void)setDropDownMenuExtended:(BOOL)extended animated:(BOOL)animated
{
	[[NSUserDefaults standardUserDefaults] setBool:extended forKey:FSPDropDownExtendedKey];
	
    static NSTimeInterval duration =  0.17;
    if (extended == isMenuExtended)
        return;
    
    self.menuButton.image = extended ? [UIImage imageNamed:@"chevron_up"] : [UIImage imageNamed:@"chevron_down"];
    self.menuButton.accessibilityLabel = extended ? NSLocalizedString(FSPDropDownToggleHideLabel, nil) : NSLocalizedString(FSPDropDownToggleShowLabel, nil);
    
    isMenuExtended = !isMenuExtended;
    CGFloat delta;
    CGPoint destinationPoint;
    if (extended) {
        // Want the menu origin to be at (0,0)
        delta = -self.dropDownMenu.frame.origin.y;
        destinationPoint = CGPointZero;
    } else {
        // want the destinationPoint to be at (0,0)
        destinationPoint = CGPointMake(0, -self.dropDownMenu.sectionsHeight);
        delta = destinationPoint.y - self.dropDownMenu.frame.origin.y;
    }
    
	void (^animations)() = ^{
        CGRect menuFrame = self.dropDownMenu.frame;
        menuFrame.origin = destinationPoint;
        self.dropDownMenu.frame = menuFrame;
        
        // Update the tableview
        CGRect contentFrame;
		CGRectDivide(self.view.bounds, &menuFrame, &contentFrame, CGRectGetMaxY(menuFrame), CGRectMinYEdge);
        self.subViewController.view.frame = contentFrame;
    };
	
	if (animated) {
		[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:animations completion:nil];
	} else {
		animations();
	}
}

- (void)menuButtonWasTapped:(id)sender;
{
    BOOL extend = !isMenuExtended;
    [self setDropDownMenuExtended:extend animated:YES];
}


@end
