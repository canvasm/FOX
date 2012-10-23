//
//  FSPDropDownMenuItem.h
//  FoxSports
//
//  Created by Steven Stout on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FSPDropDownMenuAction)(id sender);

@interface FSPDropDownMenuItem : NSObject

@property (nonatomic, strong) NSString *menuTitle;
@property (readwrite, copy) FSPDropDownMenuAction selectionAction;


- (id)initWithMenuTitle:(NSString *)title selectionAction:(FSPDropDownMenuAction)action;

@end
