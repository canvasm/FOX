//
//  FSPCTView.m
//  FoxSports
//
//  Created by greay on 5/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPCTView.h"
#import <CoreText/CoreText.h>

#define kPadding 10.0

@interface FSPCTView () {
	CTFramesetterRef framesetter;
}

@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, assign, readwrite) CGSize contentSize;
@property (nonatomic, assign) CGRect imageRect;

@end

@implementation FSPCTView

@synthesize text = _text;
@synthesize image = _image;
@synthesize font, textColor;
@synthesize contentSize;
@synthesize imageRect;

@synthesize paths = _paths;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	if (self.text) [self buildPaths];
}

- (void)dealloc
{
	if (framesetter) CFRelease(framesetter);
	framesetter = NULL;
}

- (void)setText:(NSAttributedString *)text
{
	_text = text;
	if (framesetter) {
		CFRelease(framesetter);
	}
	framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)text);

	[self buildPaths];
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	if (self.text) [self buildPaths];
}

- (void)calculateContentSize
{
	CGFloat textHeight = 0;
	
	CFIndex charIndex = 0;
	for (id path in self.paths) {
		CGFloat h = 0.0;
		CGPathRef pathRef = (__bridge CGPathRef)path;
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(charIndex, 0), pathRef, NULL);	

		CFRange frameRange = CTFrameGetVisibleStringRange(frame);
		CGRect pathBounds = CGPathGetBoundingBox(pathRef);
		CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, frameRange, NULL, CGSizeMake(pathBounds.size.width, CGFLOAT_MAX), NULL);
		
		CGPoint origins;
		CTFrameGetLineOrigins(frame, CFRangeMake(charIndex, 1), &origins);
		
		
		NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
		
		CGFloat ascent = 0.0, descent = 0.0, leading = 0.0;
		for (id line in lines) {
			CTLineRef lineRef = (__bridge CTLineRef)line;
			
			CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
			CGFloat lineHeight = ascent + leading + descent;
			h += lineHeight;
		}
		if (frame) CFRelease(frame);

		charIndex += frameRange.length;
		if (h < suggestedSize.height) {
			h = suggestedSize.height;
		}
		if (h < pathBounds.size.height && pathBounds.size.height < 99999.0) {
			h = pathBounds.size.height;
		}
		
		// ensure last line is drawn
		h += (ascent + leading + descent) * 2;

		textHeight += h;
	}

	self.contentSize = CGSizeMake(self.bounds.size.width, ceilf(textHeight));
}

- (CGSize)sizeThatFits:(CGSize)size
{
	[self calculateContentSize];
	return CGSizeMake(size.width, self.contentSize.height);
}

#define IPHONE_NEWS_IMAGE_MAX_WIDTH (146)
#define IPAD_NEWS_IMAGE_MAX_WIDTH (336)

- (void)buildPaths:(CGFloat)maxHeight
{
	NSMutableArray *paths = [NSMutableArray array];
	
	CGRect bounds = CGRectMake(0, -maxHeight, self.bounds.size.width, maxHeight);
	bounds = CGRectInset(bounds, 0.0, kPadding);
	
	CFIndex charIndex = 0;
	
	// headline and byline
	CGRect topRect;
	
	// start w/a rough estimate
	CTFontRef headlineFont = (__bridge CTFontRef)[self.text attribute:(__bridge NSString *)kCTFontAttributeName atIndex:0 effectiveRange:NULL];
	CGRectDivide(bounds, &topRect, &bounds, ceilf(CTFontGetSize(headlineFont) * 3.4), CGRectMaxYEdge);

	CGPathRef path = CGPathCreateWithRect(topRect, NULL);

	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(charIndex, 0), path, NULL);	
	CFRange frameRange = CTFrameGetVisibleStringRange(frame);
	if (frame) CFRelease(frame);
	
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, frameRange, NULL, CGSizeMake(topRect.size.width, CGFLOAT_MAX), NULL);
	topRect.size = suggestedSize;
	
	// trash the old path
	CFRelease(path);

	// and create a new one w/the suggested size
	path = CGPathCreateWithRect(topRect, NULL);
	[paths addObject:(__bridge_transfer id)path];

	charIndex += frameRange.length;
	
	// image
	CGSize imageSize = self.image.size;
    CGFloat maxWidth;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        maxWidth = IPHONE_NEWS_IMAGE_MAX_WIDTH;
    } else {
        maxWidth = IPAD_NEWS_IMAGE_MAX_WIDTH;
    }
    if (imageSize.width > maxWidth) {
        CGFloat scale = maxWidth / imageSize.width;
        imageSize.width *= scale;
        imageSize.height *= scale;
    }
	
	imageRect = CGRectZero;
	if (self.image) {
		CGRectDivide(bounds, &imageRect, &bounds, imageSize.height + kPadding * 2, CGRectMaxYEdge);
	}

	if (!CGRectEqualToRect(imageRect, CGRectZero)) {
		CGRect offsetRect;
		CGRectDivide(imageRect, &imageRect, &offsetRect, imageSize.width + kPadding, CGRectMinXEdge);

		path = CGPathCreateWithRect(offsetRect, NULL);
		
		
		frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(charIndex, 0), path, NULL);	
		frameRange = CTFrameGetVisibleStringRange(frame);
		if (frame) CFRelease(frame);
		
		suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, frameRange, NULL, CGSizeMake(offsetRect.size.width, CGFLOAT_MAX), NULL);
		offsetRect.origin = CGPointMake(offsetRect.origin.x, offsetRect.origin.y + offsetRect.size.height - suggestedSize.height - kPadding / 2);
		offsetRect.size = suggestedSize;
		
		// trash the old path
		CFRelease(path);
		
		// and create a new one w/the suggested size
		path = CGPathCreateWithRect(offsetRect, NULL);
		[paths addObject:(__bridge_transfer id)path];
		
//		charIndex += frameRange.length;
	}

	if (self.image) {
		imageRect.origin.x -= kPadding / 2;
		imageRect = CGRectInset(imageRect, kPadding / 2, kPadding);
	}
	
	CGRect textFrame = bounds;
	
	path = CGPathCreateWithRect(textFrame, NULL);
	[paths addObject:(__bridge_transfer id)path];

	self.paths = paths;
}

- (void)buildPaths
{
	[self buildPaths:CGFLOAT_MAX];

	[self calculateContentSize];
	
	[self buildPaths:self.contentSize.height];
	
	[self setNeedsDisplay];
}

- (NSUInteger)drawFromIndex:(CFIndex)index intoRectangularPath:(CGPathRef)path inContext:(CGContextRef)context
{
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(index, 0), path, NULL);	
	CTFrameDraw(frame, context);
	CFRange frameRange = CTFrameGetVisibleStringRange(frame);
	CFRelease(frame);
	
	return frameRange.length;
}	

- (void)drawRect:(CGRect)rect
{
	if (!self.text) {
		return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1.0f, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);

	CFIndex charIndex = 0;
	for (id path in [self paths]) {
		CGPathRef pathRef = (__bridge CGPathRef)path;

//		CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
//		CGContextAddPath(context, pathRef);
//		CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
//		CGContextDrawPath(context, kCGPathFillStroke);

		charIndex += [self drawFromIndex:charIndex intoRectangularPath:pathRef inContext:context];
	}
	
	if (self.image) {
		CGContextDrawImage(context, imageRect, self.image.CGImage);
	}
}

@end
