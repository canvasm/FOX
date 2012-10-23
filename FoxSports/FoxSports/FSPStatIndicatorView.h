//
//  FSPStatIndicatorView.h
//  FoxSports
//
//  Created by Matthew Fay on 8/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FSPLeftDirection,
    FSPRightDirection
} FSPDirection;

@class FSPTeam;

@interface FSPStatIndicatorView : UIView

- (id)initWithTeam:(FSPTeam *)team withNumber:(NSNumber *)stat withDirection:(FSPDirection)direction;

@end
