//
//  UILabel+FSPExtensions.m
//  FoxSports
//
//  Created by Laura Savino on 4/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "UILabel+FSPExtensions.h"

@implementation UILabel (FSPExtensions)

- (void)fsp_indicateNoData;
{
    if(self.text == nil || [self.text isEqualToString:@""])
        self.text = @"--";
}

@end
