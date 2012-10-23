//
//  FSPEventChip.m
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventChipCell.h"
#import "FSPEvent.h"
#import "FSPEventChipHeader.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPLabel.h"

static CGGradientRef
_FSPEventChipBackgroundGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        const CGFloat components[] = {242.0/255.0, 242.0/255.0, 242.0/255.0, 1.0,
            221.0/255.0, 221.0/255.0, 221.0/255.0, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

static CGGradientRef
_FSPEventChipSelectedBackgroundGradient(void)
{
    static CGGradientRef gradient = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        const CGFloat components[] = {52.0/255.0, 127.0/255.0, 197.0/255.0, 1.0,
            103.0/255.0, 164.0/255.0, 220.0/255.0, 1.0};
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGColorSpaceRelease(colorSpace);
    });
    return gradient;
}

@interface _FSPEventChipBackground : UIView
- (id)initWithFrame:(CGRect)frame selected:(BOOL)selected;
@end

@implementation _FSPEventChipBackground {
    BOOL drawAsSelected;
}

- (id)initWithFrame:(CGRect)frame selected:(BOOL)selected;
{
    self = [super initWithFrame:frame];
    if (self) {
        drawAsSelected = selected;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGGradientRef gradient = drawAsSelected ? _FSPEventChipSelectedBackgroundGradient() : _FSPEventChipBackgroundGradient();
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, self.bounds.size.height), 0);
    
    if (!drawAsSelected) {
        UIBezierPath *bottomLine = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, self.bounds.size.height-1, self.bounds.size.width, 1.0f)];
        [[UIColor colorWithWhite:0.729 alpha:1.000] set];
        [bottomLine fill];
    }    
}
@end


#pragma mark -


@interface FSPEventChipCell () {}
@property (nonatomic, weak) FSPEventChipHeader *header;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;

- (void)addHeaderView;
- (void)addBackgroundViews;

@end

@implementation FSPEventChipCell
@synthesize header = _header;
@synthesize labels = _labels;

@synthesize isAdView=_isAdView;
@synthesize adView = _adView;

- (BOOL)isStreamable;
{
    return self.header.isStreamable;
}

- (void)setAdView:(UIView *)adView
{
    _adView = adView;
    [self setNeedsDisplay];
}

- (BOOL)isInProgress;
{
    return self.header.isInProgress;
}

+ (void)registerSelfWithTableView:(UITableView *)tableView forReuseIdentifier:(NSString *)reuseIdentifier;
{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass(self) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect frame = self.frame;
        frame.size.width = 320.0;
        self.frame = frame;
    }
    
    UIFont *labelFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:16.0];
    for (UILabel *label in self.labels) {
        label.font = labelFont;
    }
    
    [self addHeaderView];
    [self addBackgroundViews];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addHeaderView];
    }
    return self;
}

- (void)addHeaderView;
{
    if (!self.header) {
        FSPEventChipHeader *newHeader = [[FSPEventChipHeader alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        [self.contentView addSubview:newHeader];
        self.header = newHeader;
    }
}

- (void)addBackgroundViews;
{
    self.backgroundView = [[_FSPEventChipBackground alloc] initWithFrame:self.bounds selected:NO];
    self.selectedBackgroundView = [[_FSPEventChipBackground alloc] initWithFrame:self.bounds selected:YES];
}


- (void)populateCellWithEvent:(FSPEvent *)event;
{
    [self.header populateWithEvent:event];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selected = NO;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *shadowColor = nil;
    if (self.selected) {
        shadowColor = [UIColor chipTextShadowSelectedColor];
    } else {
        shadowColor = [UIColor chipTextShadowUnselectedColor];
    }
    for (UILabel *label in self.labels) {
        label.shadowColor = shadowColor;
    }
    for (UILabel *label in self.header.labelsToToggleOnSelection) {
        label.shadowColor = shadowColor;
    }
}

#pragma mark -
#pragma mark Accessibility

- (NSString *)accessibilityLabel;
{
    if (self.header.isInProgress) 
        return [self inProgressAccessibilityLabel];
    else
        return [self notInProgressAccessibilityLabel];
}

- (NSString *)inProgressAccessibilityLabel;
{
    if (self.isStreamable)
        return @"Streamable in progress event";
    else
        return @"In progress event";
}

- (NSString *)notInProgressAccessibilityLabel;
{
    if (self.isStreamable)
        return [NSString stringWithFormat:@"Streamable event starting %@", self.header.gameStateLabel.text];
    else
        return [NSString stringWithFormat:@"Event starting %@", self.header.gameStateLabel.text];
}

@end
