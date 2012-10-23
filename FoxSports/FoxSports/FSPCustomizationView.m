//
//  FSPCustomizationView.m
//  FoxSports
//
//  Created by Chase Latta on 4/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPCustomizationView.h"
#import "FSPOrganization.h"
#import "UIFont+FSPExtensions.h"
#import "FSPImageFetcher.h"
#import "FSPCoreDataManager.h"

@interface FSPCustomizationView ()
@property (nonatomic, strong) FSPOrganization *organization;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIBezierPath *outerPath;
@property (nonatomic, strong, readonly) UIBezierPath *rightSidePath;
@property (nonatomic, strong, readonly) UIBezierPath *topStampPath;
@property (nonatomic, strong) UILabel *addTeamLabel;
@property (nonatomic, strong) UILabel *organizationLabel;
@property (nonatomic, strong) UIImageView *favoritedImageView;

@property (nonatomic, weak) id favoriteStateObserver;

@property (nonatomic, strong, readonly) UIImage *favoritedImage;
@property (nonatomic, strong, readonly) UIImage *notFavoritedImage;
@property (nonatomic, strong, readonly) UIImage *topHighlightMaskImage;

- (CGRect)imageViewFrame;

// Drawing Functions
- (void)drawDarkBackgroundGradient;
- (void)drawLightBackgroundGradient;
- (void)drawTopLines;
- (void)drawTopHighlight;

- (void)placeExtraViews;

- (void)updateFavoritedState;

- (void)handleTap:(UITapGestureRecognizer *)tap;

- (void)showTeamsInPopover;
- (void)showSubOrganizationsInPopover;
- (void)didToggleFavoritedState;

@end

@implementation FSPCustomizationView {
    BOOL hasTeams;
    BOOL canAdd;
    CGFloat cornerRadius;
    CGFloat imageViewPadding;
}
@synthesize organization = _organization;
@synthesize outerPath = _outerPath;
@synthesize rightSidePath = _rightSidePath;
@synthesize topStampPath = _topStampPath;
@synthesize imageView;
@synthesize addTeamLabel;
@synthesize organizationLabel;
@synthesize favoritedImageView;
@synthesize favoritedImage = _favoritedImage;
@synthesize notFavoritedImage = _notFavoritedImage;
@synthesize delegate;
@synthesize topHighlightMaskImage = _topHighlightMaskImage;
@synthesize favoriteStateObserver;

- (UIImage *)favoritedImage;
{
    if (!_favoritedImage) {
        _favoritedImage = [UIImage imageNamed:@"checkmark_green"];
    }
    return _favoritedImage;
}

- (UIImage *)notFavoritedImage;
{
    if (!_notFavoritedImage) {
        _notFavoritedImage = [UIImage imageNamed:@"empty_circle"];
    }
    return _notFavoritedImage;
}

- (UIImage *)topHighlightMaskImage;
{
    if (_topHighlightMaskImage)
        return _topHighlightMaskImage;
    
    CGFloat height = self.bounds.size.height / 2.0;
    UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width, height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat colors[] = {1.0, 1.0, 1.0, 0.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0.0, height), CGPointZero, 0);
    CGGradientRelease(gradient);
    
    _topHighlightMaskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return _topHighlightMaskImage;
}

+ (CGSize)preferedSize;
{
    return CGSizeMake(270, 90);
}


+ (id)customizationViewWithFrame:(CGRect)frame organization:(FSPOrganization *)organization;
{
    return [[self alloc] initWithFrame:frame organization:organization];
}

- (id)initWithFrame:(CGRect)frame organization:(FSPOrganization *)organization;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.organization = organization;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        cornerRadius = 10.0;
        imageViewPadding = 10.0;
        
        self.imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:self.organization.logo1URL]
                                           withCallback:^(UIImage *image) {
                                               self.imageView.image = image;
                                           }];
        
        hasTeams = [self.organization.hasTeams boolValue];
        canAdd = [self.organization.selectable boolValue];
        
        self.layer.shadowPath = [self outerPath].CGPath;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 8.0;
        self.layer.shadowOpacity = 0.65;
        self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        
        [self placeExtraViews];
        [self updateFavoritedState];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        self.favoriteStateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:FSPOrganizationDidUpdateFavoritedStateNotification object:self.organization queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self updateFavoritedState];
        }];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    [NSException raise:@"invalid initializer" format:@"FSPCustomizationView's must be initialized with initWithOrganization:"];
    return nil;
}

- (id)init;
{
    return [self initWithFrame:CGRectZero];
}

- (void)drawRect:(CGRect)rect
{
    [self drawDarkBackgroundGradient];
    [self drawLightBackgroundGradient];
    [self drawTopLines];
    [self drawTopHighlight];
}

- (void)drawDarkBackgroundGradient;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    CGPoint startPoint = CGPointZero;
    
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[8] = {0.0, 43.0/255.0, 91.0/255.0, 1.0, //top
                                0.0, 24.0/255.0, 51.0/255.0, 1.0}; // bottom
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    
    CGContextSaveGState(ctx);
    [self.outerPath addClip];
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
}

- (void)drawLightBackgroundGradient;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    CGPoint startPoint = CGPointZero;
    
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[8] = {0.0, 59.0/255.0, 125.0/255.0, 1.0, // Top
            0.0, 38.0/255.0, 80.0/255.0, 1.0}; // Bottom
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    
    CGContextSaveGState(ctx);
    [self.rightSidePath addClip];
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
}

- (void)drawTopLines;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [self.outerPath addClip];
    [self.topStampPath setLineWidth:1.0];
    [[UIColor colorWithRed:0.0 green:83.0/255.0 blue:175.0/255.0 alpha:1.0] set];
    
    CGContextTranslateCTM(ctx, 1, 1);
    [self.topStampPath stroke];
    
    [[UIColor colorWithRed:12.0/255.0 green:12.0/255.0 blue:12.0/255.0 alpha:1.0] set];
    CGContextTranslateCTM(ctx, -1, -1);
    [self.topStampPath stroke];
    CGContextRestoreGState(ctx);
}

- (void)drawTopHighlight;
{
    UIImage *maskImage = [self topHighlightMaskImage];
    CGRect maskRect = CGRectZero;
    maskRect.size = maskImage.size;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, maskRect, maskImage.CGImage);
    
    UIBezierPath *path = [self outerPath];
    [path setLineWidth:1.0];

    [[UIColor colorWithRed:0.0 green:83.0/255.0 blue:175.0/255.0 alpha:1.0] set];
    [path stroke];
    
    CGContextRestoreGState(ctx);
}

#pragma mark - Frames
- (CGRect)imageViewFrame;
{
    CGRect containerRect = CGRectMake(0, 0, 85, 85);
    return CGRectInset(containerRect, imageViewPadding, imageViewPadding);
}

#pragma mark - Paths
- (UIBezierPath *)outerPath;
{
    if (_outerPath)
        return _outerPath;
    
    _outerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    return _outerPath;
}

- (UIBezierPath *)rightSidePath;
{
    if (_rightSidePath)
        return _rightSidePath;
    
    CGRect remainder = CGRectNull;
    CGRect slice = CGRectNull;
    CGRectDivide(self.bounds, &slice, &remainder, CGRectGetMaxX([self imageViewFrame]) + imageViewPadding, CGRectMinXEdge);
    remainder = CGRectIntegral(remainder);
    _rightSidePath = [UIBezierPath bezierPathWithRoundedRect:remainder byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    return _rightSidePath;
}

- (UIBezierPath *)topStampPath;
{
    if (_topStampPath)
        return _topStampPath;
    
    // These points need to be on half pixel boundaries so our drawing can be pixel aligned.
    UIBezierPath *innerPath = [UIBezierPath bezierPath];
    CGFloat imageViewRightSideX = floor(CGRectGetMaxX([self imageViewFrame]) + imageViewPadding) + .5;
    [innerPath moveToPoint:CGPointMake(imageViewRightSideX, -1)];
    [innerPath addLineToPoint:CGPointMake(imageViewRightSideX, self.bounds.size.height)];
    
    if (hasTeams) {
        CGFloat midPointY = floorf(CGRectGetMidY(self.bounds)) + .5;
        [innerPath moveToPoint:CGPointMake(imageViewRightSideX, midPointY)];
        [innerPath addLineToPoint:CGPointMake(self.bounds.size.width, midPointY)];
    }
    
    _topStampPath = innerPath;
    return _topStampPath;
}

#pragma mark - Other Views
- (void)placeExtraViews;
{
    CGFloat imageViewRightSideX = floor(CGRectGetMaxX([self imageViewFrame]) + imageViewPadding);
    static CGFloat padding = 10.0;
    
    if (canAdd && !self.favoritedImageView) {
        self.favoritedImageView = [[UIImageView alloc] initWithImage:self.notFavoritedImage];
        [self addSubview:self.favoritedImageView];
    }
        
    CGRect favoritedImageViewFrame = self.favoritedImageView.frame;
    favoritedImageViewFrame.origin = CGPointMake(imageViewRightSideX + padding, 0.0);
    self.favoritedImageView.frame = favoritedImageViewFrame;

    
    CGRect orgLabelFrame;
    CGFloat orgOriginX;
    CGFloat orgWidth;
    if (canAdd) {
        orgOriginX = imageViewRightSideX + self.favoritedImageView.bounds.size.width + 15;
    } else {
        orgOriginX = imageViewRightSideX + padding;
    }
    orgWidth = self.bounds.size.width - orgOriginX;
    orgLabelFrame = CGRectMake(orgOriginX, 0.0, orgWidth, 20.0);
    
    self.organizationLabel = [[UILabel alloc] initWithFrame:orgLabelFrame];
    self.organizationLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.organizationLabel];
    
    if (hasTeams) {
        // Place the label for the teams
        CGFloat teamLabelWidth = self.bounds.size.width - (imageViewRightSideX + padding);
        CGRect teamLabelFrame = CGRectMake(imageViewRightSideX + padding + 2.0, 0, teamLabelWidth, orgLabelFrame.size.height);
        
        self.addTeamLabel = [[UILabel alloc] initWithFrame:teamLabelFrame];
        self.addTeamLabel.text = @"Add Team";
        self.addTeamLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16];
        self.addTeamLabel.backgroundColor = [UIColor clearColor];
        self.addTeamLabel.textColor = [UIColor whiteColor];
        
        [self.addTeamLabel sizeToFit];
        CGPoint center = self.addTeamLabel.center;
        center.y = floorf(3.0 * self.bounds.size.height / 4.0) + 4.0;
        self.addTeamLabel.center = center;
        
        [self addSubview:self.addTeamLabel];
    }
}

- (void)updateFavoritedState;
{
    if ([self.organization.favorited boolValue] && canAdd) {
        self.organizationLabel.text = @"Added";
        self.organizationLabel.textColor = [UIColor colorWithRed:139/255.0 green:180/255.0 blue:226/255.0 alpha:1.0];
        self.organizationLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16.0];
        self.favoritedImageView.image = self.favoritedImage;
    } else {
        self.organizationLabel.text = self.organization.name;
        self.organizationLabel.textColor = [UIColor whiteColor];
        self.organizationLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16];
        if (canAdd) {
            self.favoritedImageView.image = self.notFavoritedImage;
        }
    }
    
    [self.organizationLabel sizeToFit];
    CGFloat orgCenterY;
    if (hasTeams) {
        orgCenterY = floorf(self.bounds.size.height / 4.0);
    } else {
        orgCenterY = floorf(self.bounds.size.height / 2.0);
    }
    orgCenterY += 4.0;
    
    CGPoint center = self.organizationLabel.center;
    center.y = orgCenterY;
    self.organizationLabel.center = center;
    self.organizationLabel.frame = CGRectIntegral(self.organizationLabel.frame);
    
    center = self.favoritedImageView.center;
    center.y = self.organizationLabel.center.y - 2.0;
    self.favoritedImageView.center = center;
    self.favoritedImageView.frame = CGRectIntegral(self.favoritedImageView.frame);
}

#pragma mark - Touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    CGRect ignoreRect = CGRectInset([self imageViewFrame], -imageViewPadding, -imageViewPadding);
    return !CGRectContainsPoint(ignoreRect, [touch locationInView:self]);
}

- (void)handleTap:(UITapGestureRecognizer *)tap;
{
    BOOL didTapTeams = NO;
    if (hasTeams) {
        // handle the bi-level nature of the view
        CGPoint location = [tap locationInView:self];
        if (location.y > CGRectGetMidY(self.bounds)) {
            [self showTeamsInPopover];
            didTapTeams = YES;
        }
    } 
    
    if (!didTapTeams) {
        if (canAdd) {
            [self didToggleFavoritedState];
        } else {
            [self showSubOrganizationsInPopover];
        }
    }
}

- (void)showTeamsInPopover;
{
    if ([self.delegate respondsToSelector:@selector(customizationViewWantsToShowTeams:)])
        [self.delegate customizationViewWantsToShowTeams:self];
}

- (void)showSubOrganizationsInPopover;
{
    if ([self.delegate respondsToSelector:@selector(customizationViewWantsToShowSubOrganizations:)])
        [self.delegate customizationViewWantsToShowSubOrganizations:self];
}

- (void)didToggleFavoritedState;
{
    BOOL isFavorited = [self.organization.favorited boolValue];
    if ([self.delegate respondsToSelector:@selector(customizationView:willChangeFavoritedState:newState:)])
        [self.delegate customizationView:self willChangeFavoritedState:isFavorited newState:!isFavorited];
    
    [self.organization updateFavoriteState:!isFavorited];
    [self updateFavoritedState];

    [[FSPCoreDataManager sharedManager] synchronizeSaving];
    
    if ([self.delegate respondsToSelector:@selector(customizationView:didChangeFavoritedState:)])
        [self.delegate customizationView:self didChangeFavoritedState:!isFavorited];
}

@end
