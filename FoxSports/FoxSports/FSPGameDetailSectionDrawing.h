//
//  FSPGameDetailSectionDrawing.h
//  FoxSports
//
//  Created by Laura Savino on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

/**
 * Draws common elements for components in Column C.
 */

#import <Foundation/Foundation.h>

void FSPDrawHighlightLine(CGContextRef context, CGPoint segment[2]);

/**
 * Draws a 2-pixel high line with gray on top and white on the bottom at the 
 * bottom of the given rect.
 */
void FSPDrawGrayWhiteDividerLine(CGContextRef context, CGRect rect);

void FSPDrawBlackLine(CGContextRef context, CGPoint segment[2]);
