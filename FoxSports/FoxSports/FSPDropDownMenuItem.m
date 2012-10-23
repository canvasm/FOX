//
//  FSPDropDownMenuItem.m
//  FoxSports
//
//  Created by Steven Stout on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDropDownMenuItem.h"

@implementation FSPDropDownMenuItem
{
    FSPDropDownMenuAction selectionAction;
}

@synthesize menuTitle;
@synthesize selectionAction;


- (id)initWithMenuTitle:(NSString *)title selectionAction:(FSPDropDownMenuAction)action
{
    self = [super init];
    if (self) {
        self.menuTitle = title;
        self.selectionAction = action;
    }
    return self;    
}

@end
