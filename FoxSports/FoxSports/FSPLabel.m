//
//  FSPLabel.m
//  FoxSports
//
//  Created by Rowan Christmas on 6/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLabel.h"

@implementation FSPLabel

@synthesize highlightedTextShadowColor;
@synthesize normalTextShadowColor;
@synthesize highlightedFont;
@synthesize normalFont;

- (void)setHighlighted:(BOOL)highlighted;
{
    if (highlighted == self.highlighted)
        return;

    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.normalTextShadowColor && self.highlightedTextShadowColor)
            self.shadowColor = self.highlightedTextShadowColor;
        if (self.normalFont && self.highlightedFont)
            self.font = self.highlightedFont;
    } else {
        if (self.normalTextShadowColor && self.highlightedTextShadowColor)
            self.shadowColor = self.normalTextShadowColor;
        if (self.normalFont && self.highlightedFont)
            self.font = self.normalFont;
    }
}

@end
