//
//  FSPGameHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameHeaderView.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPImageFetcher.h"
#import "UIFont+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"

CGFloat const kScoreLabelFontSizePhone = 30.0f;
CGFloat const kScoreLabelFontSizePad  = 45.0f;
CGFloat const kTimeLabelFontSizePhone = 14.0f;
CGFloat const kTimeLabelFontSizePad = 17.0f;
CGFloat const kPeriodLabelFontSizePhone = 12.0f;
CGFloat const kPeriodLabelFontSizePad = 14.0f;
CGFloat const kFinalLabelFontSizePhone = 12.0f;
CGFloat const kFinalLabelFontSizePad = 17.0f;
CGFloat const kDateTimeLabeFontSizePad = 15.0f;

@interface FSPGameHeaderView()

@property (nonatomic, strong) FSPGame *game;
@property (nonatomic, assign) CGGradientRef gradient;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, strong) IBOutlet UIButton *toggleFullScreenButton;

@property (nonatomic, weak) IBOutlet UIImageView *awayTimoutsContainer;
@property (nonatomic, weak) IBOutlet UIImageView *homeTimoutsContainer;

- (void)updateTimeouts;

@end


@implementation FSPGameHeaderView

@synthesize gradient = _gradient;

- (void)setHomeColor:(UIColor *)homeColor;
{
    if (_homeColor != homeColor) {
        _homeColor = homeColor;
        self.gradient = NULL;
    }
}

- (void)setAwayColor:(UIColor *)awayColor;
{
    if (_awayColor != awayColor) {
        _awayColor = awayColor;
        self.gradient = NULL;
    }
}

- (void)setMiddleColor:(UIColor *)middleColor;
{
    if (_middleColor != middleColor) {
        _middleColor = middleColor;
        self.gradient = NULL;
    }
}

- (void)setGradient:(CGGradientRef)gradient;
{
    if (_gradient != gradient) {
        if (_gradient)
            CGGradientRelease(_gradient);

        if (gradient)
            CGGradientRetain(gradient);
        _gradient = gradient;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    //The frame will not be adjusted
    self = nil;
    UINib *nib = [UINib nibWithNibName:@"FSPGameHeaderView" bundle:nil];
    NSArray *objs = [nib instantiateWithOwner:nil options:nil];
    self = [objs lastObject];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGFloat scoreFontSize;
    CGFloat periodFontSize;
    CGFloat timeFontSize;
    CGFloat finalFontSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        scoreFontSize = kScoreLabelFontSizePad;
        periodFontSize = kPeriodLabelFontSizePad;
        timeFontSize = kTimeLabelFontSizePad;
        finalFontSize = kFinalLabelFontSizePad;
        
        self.dateTimeChannelLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:kDateTimeLabeFontSizePad];
        self.toggleFullScreenButton.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:11.0f];
        
    } else {
        scoreFontSize = kScoreLabelFontSizePhone;
        periodFontSize = kPeriodLabelFontSizePhone;
        timeFontSize = kTimeLabelFontSizePad;
        finalFontSize = kFinalLabelFontSizePhone;
    }
    
    UIFont *scoreFont = [UIFont fontWithName:FSPUScoreRGKFontName size:scoreFontSize];
    self.awayScoreLabel.font = scoreFont;
    self.homeScoreLabel.font = scoreFont;
    self.periodLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:periodFontSize];
    self.timeLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:timeFontSize];
    self.finalLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:finalFontSize];
    
	self.awayTimoutsContainer.hidden = YES;
	self.homeTimoutsContainer.hidden = YES;

	UIImage *timeoutBackground = [UIImage imageNamed:@"timeout_background"];
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 7, 0, 8);
	self.awayTimoutsContainer.image = [timeoutBackground resizableImageWithCapInsets:insets];
	self.homeTimoutsContainer.image = [[UIImage imageWithCGImage:timeoutBackground.CGImage scale:timeoutBackground.scale orientation: UIImageOrientationUpMirrored] resizableImageWithCapInsets:insets];
	self.toggleFullScreenButton.hidden = YES;
}

- (void) dealloc
{
    self.gradient = NULL;
}


- (void)populateWithGame:(FSPGame *)game updateLogos:(BOOL)updateLogos
{
	self.game = game;
	
	if (updateLogos) {
		self.homeLogoImage.image = nil;
		self.awayLogoImage.image = nil;
		
		if (game.homeTeam.logo2URL) {
			[FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:game.homeTeam.logo2URL]
											   withCallback:^(UIImage *image) {
												   if (game == self.game) {
													   self.homeLogoImage.image = image;
												   }
											   }];
		} else {
			self.homeLogoImage.image = nil;
		}
		
		if (game.awayTeam.logo2URL) {
			[FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:game.awayTeam.logo2URL]
											   withCallback:^(UIImage *image) {
												   if (game == self.game) {
													   self.awayLogoImage.image = image;
												   }
											   }];
		} else {
			self.awayLogoImage.image = nil;
		}
		
		// Update the colors
		self.homeColor = game.homeTeamColor;
		self.awayColor = game.awayTeamColor;
	}
    if(self.game.viewType == FSPBaseballViewType || self.game.viewType == FSPNFLViewType || self.game.viewType == FSPNCAAFViewType || self.game.viewType == FSPFightingViewType) {
		self.toggleFullScreenButton.hidden = NO;
	} else {
		self.toggleFullScreenButton.hidden = YES;
	}
	

	[self setNeedsDisplay];

}

- (void)updateLabelsWithGame:(FSPGame *)game
{
	self.game = game;
	//TODO: update logos
	
    NSString *dateString = [self.game.startDate fsp_lowercaseMeridianDateString];
	
    NSString *currentGameString = @"";
    if (self.game.channelDisplayName && ![currentGameString isEqualToString:@""])
        currentGameString = [NSString stringWithFormat:@", %@", self.game.channelDisplayName];
    
    self.dateTimeChannelLabel.text = dateString ? [NSString stringWithFormat:@"%@%@", dateString, currentGameString] : @"";
	
    self.timeLabel.text = self.game.timeStatus;
	
    // Set the score if available, otherwise the team abbrev.
    if ([self.game.eventStarted boolValue]) {
        self.homeScoreLabel.text = [self.game.homeTeamScore stringValue];
        self.awayScoreLabel.text = [self.game.awayTeamScore stringValue];
    } else {
        self.homeScoreLabel.text = self.game.homeTeam.abbreviation;
        self.awayScoreLabel.text = self.game.awayTeam.abbreviation;
    }
	
    // Set the time & period if in a game.
    if ([self.game.eventStarted boolValue] && ![self.game.eventCompleted boolValue]) {
        if (self.game.viewType == FSPBaseballViewType) {
            self.periodLabel.text = [self.game.segmentDescription isEqualToString:@"T"] ? @"Top" : @"Bot";
            self.timeLabel.text = [self.game naturalLanguageStringForSegmentNumber:self.game.segmentNumber];
        } else if (self.game.viewType == FSPFightingViewType) {
            self.periodLabel.text = [self.game segmentDescription];
            self.timeLabel.text = [self.game segmentNumber];
        }else {
            self.periodLabel.text = [self.game naturalLanguageStringForSegmentNumber:self.game.segmentNumber];
            self.timeLabel.text = self.game.segmentDescription;
        }
		
        self.finalLabel.hidden = YES;
        self.periodLabel.hidden = NO;
        self.timeLabel.hidden = NO;
    } else {
        self.finalLabel.text = self.game.timeStatus.length ? self.game.timeStatus : @"VS";
        self.finalLabel.hidden = NO;
        self.periodLabel.hidden = YES;
        self.timeLabel.hidden = YES;
    }
	
	[self updateTimeouts];
}

- (void)updateTimeouts
{
	NSArray *subs = [self.awayTimoutsContainer subviews];
	for (UIView *sub in subs) {
		[sub removeFromSuperview];
	}
	subs = [self.homeTimoutsContainer subviews];
	for (UIView *sub in subs) {
		[sub removeFromSuperview];
	}

	UIImage *timeoutOn = [UIImage imageNamed:@"timeout_on"];
	UIImage *timeoutOff = [UIImage imageNamed:@"timeout_off"];

	CGFloat offset = timeoutOn.size.width - 2;

	NSInteger timeoutsRemaining = [self.game.awayTimeoutsRemaining integerValue];
	NSInteger totalTimouts = self.game.maxTimeouts;
	
	CGFloat padding = 6.0;
	
	CGSize containerSize = CGSizeMake(offset * totalTimouts + padding * 2, self.awayTimoutsContainer.frame.size.height);
	
	if (!totalTimouts) {
		self.awayTimoutsContainer.hidden = YES;
	} else {
		self.awayTimoutsContainer.hidden = NO;

		// update the frame of the timeout background for the # of timeouts in this sport
		CGRect frame = self.awayTimoutsContainer.frame;
		self.awayTimoutsContainer.frame = CGRectMake(CGRectGetMaxX(frame) - containerSize.width, CGRectGetMinY(frame), containerSize.width, containerSize.height);

		CGPoint position = CGPointMake(self.awayTimoutsContainer.frame.size.width - padding, 3);
		for (NSInteger i = 0; i < timeoutsRemaining; i++) {
			UIImageView *timeoutView = [[UIImageView alloc] initWithImage:timeoutOn];
			[self.awayTimoutsContainer addSubview:timeoutView];
			timeoutView.frame = CGRectMake(position.x - timeoutOn.size.width - offset * i, position.y, timeoutOn.size.width, timeoutOn.size.height);
		}
		for (NSInteger i = timeoutsRemaining; i < totalTimouts; i++) {
			UIImageView *timeoutView = [[UIImageView alloc] initWithImage:timeoutOff];
			[self.awayTimoutsContainer addSubview:timeoutView];
			timeoutView.frame = CGRectMake(position.x - timeoutOn.size.width - offset * i, position.y, timeoutOn.size.width, timeoutOn.size.height);
		}
	}

	timeoutOn = [UIImage imageWithCGImage:timeoutOn.CGImage scale:timeoutOn.scale orientation: UIImageOrientationUpMirrored];
	timeoutOff = [UIImage imageWithCGImage:timeoutOff.CGImage scale:timeoutOff.scale orientation: UIImageOrientationUpMirrored];
	
	timeoutsRemaining = [self.game.homeTimeoutsRemaining integerValue];
	if (!totalTimouts) {
		self.homeTimoutsContainer.hidden = YES;
	} else {
		self.homeTimoutsContainer.hidden = NO;
		
		// update the frame of the timeout background for the # of timeouts in this sport
		CGRect frame = self.homeTimoutsContainer.frame;
		self.homeTimoutsContainer.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), containerSize.width, containerSize.height);

		CGPoint position = CGPointMake(padding, 3);
		for (NSInteger i = 0; i < timeoutsRemaining; i++) {
			UIImageView *timeoutView = [[UIImageView alloc] initWithImage:timeoutOn];
			[self.homeTimoutsContainer addSubview:timeoutView];
			timeoutView.frame = CGRectMake(position.x + offset * i, position.y, timeoutOn.size.width, timeoutOn.size.height);
		}
		for (NSInteger i = timeoutsRemaining; i < totalTimouts; i++) {
			UIImageView *timeoutView = [[UIImageView alloc] initWithImage:timeoutOff];
			[self.homeTimoutsContainer addSubview:timeoutView];
			timeoutView.frame = CGRectMake(position.x + offset * i, position.y, timeoutOn.size.width, timeoutOn.size.height);
		}
	}
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    self.toggleFullScreenButton.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
    
    //Image Masking
    if (!self.maskImage)
        self.maskImage = [UIImage imageNamed:@"score-mask"];
    CGImageRef mask = self.maskImage.CGImage;
    CGContextSaveGState(contextRef);
    
    //have to flip the mask for it to work correctly
    CGContextConcatCTM(contextRef, CGAffineTransformMakeTranslation(0, self.bounds.size.height));
    CGContextConcatCTM(contextRef, CGAffineTransformMakeScale(1, -1));
    CGFloat yValue = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 10 : -2;
    CGContextClipToMask(contextRef, CGRectMake((rect.size.width - self.maskImage.size.width)/2, yValue, self.maskImage.size.width, self.maskImage.size.height), mask);
    
    //display gradient
    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = 0.0f;
    myStartPoint.y = 0.0f;
    myEndPoint.x = CGRectGetWidth(self.bounds);
    myEndPoint.y = 0.0f;
    CGContextDrawLinearGradient(contextRef, self.gradient, myStartPoint, myEndPoint, 0);
    
    CGContextRestoreGState(contextRef);
    
}

- (CGGradientRef)gradient
{
    if(!_gradient)
    {
        UIColor *home = self.homeColor ? self.homeColor : [UIColor blackColor];
        UIColor *away = self.awayColor ? self.awayColor : [UIColor blackColor];
        UIColor *middle = self.middleColor ? self.middleColor : [UIColor blackColor];

        //setup Gradient
        CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
        
        NSArray *colors = @[(id)away.CGColor, (id)middle.CGColor, (id)home.CGColor];
        const CGFloat locations[] = {0.0, 0.5, 1.0};
        _gradient = CGGradientCreateWithColors(myColorSpace, (__bridge CFArrayRef)colors, locations);
        
        CGColorSpaceRelease(myColorSpace);
    }
    return _gradient;
}

- (NSString *)accessibilityIdentifier
{
    return @"gameHeader";
}

@end
