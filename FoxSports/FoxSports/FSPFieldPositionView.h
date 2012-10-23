//
//  FSPFieldPositionView.h
//  FoxSports
//
//  Created by Chase Latta on 1/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPFieldPositionView : UIView

@property (nonatomic) BOOL selected;

/**
 A number between 0 and 100 indicating the position on the field.
 */
@property (nonatomic) NSUInteger yardagePosition;

/**
 Indicates that there was a scoringPlay and the indicator should represent this.
 */
@property (nonatomic) BOOL scoringPlay;

@end
