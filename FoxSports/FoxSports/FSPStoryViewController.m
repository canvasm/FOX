//
//  FSPStoryViewController.m
//  FoxSports
//
//  Created by Laura Savino on 3/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStoryViewController.h"
#import "FSPNetworkClient.h"
#import "FSPDataCoordinator+EventUpdating.h"
#import "NSDate+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPPatternedToolbar.h"
#import "FSPEventDetailBackgroundView.h"
#import "FSPCoreDataManager.h"
#import "FSPCTView.h"
#import "FSPImageFetcher.h"
#import "FSPEvent.h"

#import "JREngage+FSPExtensions.h"
#import "JREngage.h"

#import <CoreText/CoreText.h>

@interface FSPStoryViewController ()
@property (weak, nonatomic) IBOutlet FSPEventDetailBackgroundView *storyScrollingContainer;
@property (weak, nonatomic) IBOutlet UIWebView *storyBodyTextView;
@property (weak, nonatomic) FSPPatternedToolbar *headerView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic, readonly) NSMutableDictionary *storyPositionsMap;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;


/**
 * Updates subviews with story elements; causes a network request if necessary.
 */
- (void)updateStoryForEvent;
- (void)updateStoryDetails;

@end

@implementation FSPStoryViewController

@synthesize story = _story;

@synthesize storyScrollingContainer = _storyScrollingContainer;
@synthesize storyBodyTextView = _storyBodyTextView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentEvent = _currentEvent;
@synthesize storyType = _storyType;
@synthesize headerView;

@dynamic storyPositionsMap;

@synthesize popover;

@synthesize fontSize;


- (id)initWithStoryType:(FSPStoryType)storyType
{
    self = [super initWithNibName:@"FSPStoryViewController" bundle:nil];
    if(!self) return nil;

    self.storyType = storyType;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *savedSize = [defaults valueForKey:@"storyFontSize"];
    if (savedSize)
        self.fontSize = [savedSize floatValue];
    else
        self.fontSize = FSP_SMALL_FONT_SIZE;
	
    return self;
}

- (void)viewDidLoad
{
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
	self.storyBodyTextView.scrollView.scrollEnabled = NO;
	
    if (self.storyType == FSPStoryTypeNews) {
		UIButton *fontButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[fontButton setImage:[UIImage imageNamed:@"button_font"] forState:UIControlStateNormal];
		[fontButton sizeToFit];
		[fontButton addTarget:self action:@selector(showFontSizePopover:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *fontItem = [[UIBarButtonItem alloc] initWithCustomView:fontButton];
		fontItem.width = 40;
		
		UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[actionButton setImage:[UIImage imageNamed:@"C_Actions"] forState:UIControlStateNormal];
		[actionButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[actionButton sizeToFit];
		UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
		shareItem.width = 40;

		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			FSPPatternedToolbar *toolbar = [[FSPPatternedToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32.0)];
			self.headerView = toolbar;
					
			UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			NSArray *items = @[shareItem, fontItem, spacer];
			[self.headerView.toolbar setItems:items];
		
			[self.view addSubview:self.headerView];
		
			CGRect toolbarRect, bodyRect;
			CGRectDivide(self.storyBodyTextView.frame, &toolbarRect, &bodyRect, 44, CGRectMinYEdge);
			self.storyBodyTextView.frame = bodyRect;
		} else {
			UIView *buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, actionButton.bounds.size.height)];
			[buttonsView addSubview:actionButton];
			[buttonsView addSubview:fontButton];
			
			CGRect fontFrame = fontButton.frame;
			fontFrame.origin.x = 44;
			fontButton.frame = fontFrame;
			UIBarButtonItem *buttonsItem = [[UIBarButtonItem alloc] initWithCustomView:buttonsView];
			[self.navigationItem setRightBarButtonItem:buttonsItem];
		}
	}
	
	for (UIScrollView *webScrollView in [self.storyBodyTextView subviews]) {
		if ([webScrollView isKindOfClass:[UIScrollView class]]) {
			for (UIView *subview in [webScrollView subviews]) {
				if ([subview isKindOfClass:[UIImageView class]]) {
					((UIImageView *)subview).image = nil;
					subview.backgroundColor = [UIColor clearColor];
				}
			}
		}
	}
	if (self.story) {
		[self updateStoryDetails];
	}

//	self.storyBodyTextView.layer.borderColor = [UIColor greenColor].CGColor;
//	self.storyBodyTextView.layer.borderWidth = 1.0;
//
//	self.storyScrollingContainer.layer.borderColor = [UIColor redColor].CGColor;
//	self.storyScrollingContainer.layer.borderWidth = 1.0;

}

- (void)viewDidUnload {
    [self setStoryBodyTextView:nil];
    [super viewDidUnload];
}

- (CGSize)storyViewSize
{
	return self.storyBodyTextView.bounds.size;
}

- (BOOL)scrollEnabled {
	return self.storyScrollingContainer.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	self.storyScrollingContainer.scrollEnabled = scrollEnabled;
	self.storyScrollingContainer.drawsBackground = scrollEnabled;
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent
{
    if(_currentEvent == currentEvent)
        return;

    _currentEvent = currentEvent;
    [self updateStoryForEvent];
    
    [self.storyBodyTextView.scrollView scrollRectToVisible:CGRectZero animated:NO];
}

- (void)setStory:(FSPNewsStory *)story
{
    if (_story && _story.title) {
        [self.storyPositionsMap setObject:[NSValue valueWithCGPoint:self.storyBodyTextView.scrollView.contentOffset]
                                   forKey:_story.title];
    }

	if ((story != _story) && (![story isEqual:_story])) {
		_story = story;
		[self updateStoryDetails];

        if (story) {
            NSValue *previousPositionInStory = [self.storyPositionsMap objectForKey:story.title];
            if (previousPositionInStory) {
                [self.storyBodyTextView.scrollView setContentOffset:previousPositionInStory.CGPointValue animated:NO];
            } else {
                [self.storyBodyTextView.scrollView setContentOffset:CGPointZero animated:NO];
            }
        }
	}
}

- (void)updateStoryForEvent;
{
    if (!self.currentEvent) {
        return;
    }
     
    [[FSPDataCoordinator defaultCoordinator] asynchronouslyLoadNewsStoryForEvent:self.currentEvent.objectID storyType:(self.currentEvent.eventCompleted ? FSPStoryTypeRecap : FSPStoryTypePreview) success:^(FSPNewsStory *story) {
        if (story.title) {
            self.story = story;
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching story for event %@ :%@", self.currentEvent.branch, error);
        // set story to nil so we update to show that we don't have a story
        self.story = nil;
    }];
}

- (void)updateStoryDetails
{
	if (![self isViewLoaded]) {
		return;
	}
    self.storyBodyTextView.opaque = NO;
    self.storyBodyTextView.backgroundColor = [UIColor clearColor];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.headerView.titleLabel.text = [self.story.publishedDate fsp_lowercaseMeridianDateString];
	}

	if (self.story && self.story.fullText.length > 0) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"storyTemplate" ofType:@"html"];
		
		NSError *error = nil;
		NSString *templateString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
		if (error) {
			NSLog(@"error loading story template:%@", error);
			return;
		}
		
		NSString *htmlString = [templateString stringByReplacingOccurrencesOfString:@"{{HEADLINE_FONT_SIZE}}" withString:[NSString stringWithFormat:@"%fpx", floorf(self.fontSize * 1.6)]];
		htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{{BODY_FONT_SIZE}}" withString:[NSString stringWithFormat:@"%fpx", self.fontSize]];

		NSString *storyTitle = self.story.title ? self.story.title : @"";
		htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- HEADLINE -->" withString:storyTitle];

		NSString *byLine = self.story.author ? [NSString stringWithFormat:@"By %@", self.story.author] : @"";
		htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- BYLINE -->" withString:byLine];
		
		NSString *imageTag = (self.story.imageURL) ? [NSString stringWithFormat:@"<img src=\"%@\"", self.story.imageURL] : @"";
		htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- IMAGE -->" withString:imageTag];

		NSArray *paras = [self.story.fullText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSMutableString *body = [NSMutableString string];
		for (NSString *para in paras) {
			[body appendFormat:@"<p>%@</p>", para];
		}
		htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- CONTENT GOES HERE -->" withString:body];
	
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			htmlString = [htmlString stringByReplacingOccurrencesOfString:@"650px" withString:@"320px"];
			htmlString = [htmlString stringByReplacingOccurrencesOfString:@"336px" withString:@"146px"];
		}

		[self.storyBodyTextView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
		
	} else {
		[self.storyBodyTextView loadHTMLString:@"" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	}

	[self.storyBodyTextView sizeToFit];
}

// This was put in since things weren't laying out properly on first load, but it seems to no longer be needed.
- (void)viewDidLayoutSubviews
{
//	[self updateStoryDetails];
	NSLog(@"rect:%@", NSStringFromCGRect(self.view.frame));
}

- (NSMutableDictionary *)storyPositionsMap {
    static __strong NSMutableDictionary *_storyPositionsMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _storyPositionsMap = [NSMutableDictionary dictionary];
    });
    return _storyPositionsMap;
}

- (void)showFontSizePopover:(UIButton *)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (!self.popover) {
			FSPFontViewController *fontVC = [[FSPFontViewController alloc] initWithNibName:@"FSPFontViewController" bundle:nil];
			self.popover = [[UIPopoverController alloc] initWithContentViewController:fontVC];

			fontVC.delegate = self;
            [fontVC updateFontButton];
			self.popover.delegate = self;
			
			[self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		} else {
			[self.popover dismissPopoverAnimated:YES];
		}
	}
}

- (void)fontViewController:(FSPFontViewController *)viewController didSelectFontSize:(CGFloat)size
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(size) forKey:@"storyFontSize"];
    
	self.fontSize = size;
	[self updateStoryDetails];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.popover = nil;
}

- (void)shareButtonPressed:(id)sender
{
	JREngage *janrainEngageClient = [JREngage jrEngageClientWithDelegate:nil];
	NSString *sharedItemText = [NSString stringWithFormat:@"Sharing '%@'", self.story.title];
	JRActivityObject *activityObject = [JRActivityObject activityObjectWithAction:sharedItemText andUrl:nil];
	[janrainEngageClient showSocialPublishingDialogWithActivity:activityObject];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;

	fittingSize.height = CGRectGetMaxY(webView.frame) + 20;
	
    NSLog(@"size: %@", NSStringFromCGSize(fittingSize));
	self.storyScrollingContainer.contentSize = fittingSize;
	[self.delegate storyViewControllerDidFinishLoad:self];
}

@end
